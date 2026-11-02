#!/usr/bin/env bash
# ユーザーのグローバル CLAUDE.md を配置する (既存の内容は上書きされる)
set -euo pipefail

mkdir -p "$HOME/.claude"
cat > "$HOME/.claude/CLAUDE.md" <<'EOF'
## Proton Pass
- クレデンシャルが必要になったら、まず次を実行してから使い方を読むこと:
  export PROTON_PASS_KEY_PROVIDER=fs PROTON_PASS_SESSION_DIR=/tmp/pass-agent
  pass-cli info >/dev/null 2>&1 || pass-cli login
  pass-cli agent instructions
EOF
echo "Wrote $HOME/.claude/CLAUDE.md"
