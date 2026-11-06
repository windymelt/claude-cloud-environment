#!/usr/bin/env bash
# Cosense (Scrapbox) の MCP サーバー scrapbox-cosense-mcp を、全セッションで使えるようにする。
# - PAT は Proton Pass の「Claude Code」ボールト「Cosense PAT」アイテムの PAT 欄から、
#   MCP サーバー起動時に取り出す (このスクリプトや設定ファイルには書かない)。
# - ユーザー単位の MCP 設定 (~/.claude.json の mcpServers) に cosense として登録する。
set -euo pipefail

WRAPPER=/usr/local/bin/cosense-mcp

cat > "$WRAPPER" <<'EOF'
#!/usr/bin/env bash
# scrapbox-cosense-mcp を起動するラッパー。stdout は MCP の通信路なので、ここでは何も出力しない。
set -euo pipefail

export PROTON_PASS_KEY_PROVIDER=fs PROTON_PASS_SESSION_DIR=/tmp/pass-agent
PASS_CLI="$(command -v pass-cli || echo "$HOME/.local/bin/pass-cli")"

"$PASS_CLI" info >/dev/null 2>&1 || "$PASS_CLI" login >/dev/null 2>&1 || true
COSENSE_MCP_PAT="$(PROTON_PASS_AGENT_REASON='Start Cosense MCP server' \
  "$PASS_CLI" item view --vault-name 'Claude Code' --item-title 'Cosense PAT' --field PAT 2>/dev/null || true)"
if [ -z "$COSENSE_MCP_PAT" ]; then
  # PAT が無いと非公開プロジェクトはエラーにならず 0 件に見えるため、ここで止めて失敗を表に出す
  echo "cosense-mcp: Proton Pass から Cosense PAT を取得できませんでした" >&2
  exit 1
fi
export COSENSE_MCP_PAT
unset COSENSE_SID

export COSENSE_PROJECT_NAME="${COSENSE_PROJECT_NAME:-windymelt}"
export COSENSE_PROJECT_ALLOW_LIST="${COSENSE_PROJECT_ALLOW_LIST-windymelt,windymelt-20168004}"

# 依存パッケージ (@jsr/cosense__std など) は JSR にしか無いので、@jsr スコープだけ JSR を見る
exec env 'npm_config_@jsr:registry=https://npm.jsr.io' npx -y scrapbox-cosense-mcp
EOF
chmod 755 "$WRAPPER"
echo "Wrote $WRAPPER"

# ~/.claude.json の mcpServers に cosense を登録する (他の設定は残す)
python3 -I - "$HOME/.claude.json" "$WRAPPER" <<'EOF'
import json, os, sys
path, wrapper = sys.argv[1], sys.argv[2]
data = {}
if os.path.exists(path):
    with open(path) as f:
        data = json.load(f)
data.setdefault("mcpServers", {})["cosense"] = {"type": "stdio", "command": wrapper, "args": [], "env": {}}
with open(path, "w") as f:
    json.dump(data, f, indent=2)
EOF
echo "Registered MCP server 'cosense' in $HOME/.claude.json"
