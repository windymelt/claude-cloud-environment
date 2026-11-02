#!/usr/bin/env bash
# Claude Code クラウド環境のセットアップ入口。
# 環境の Setup script 欄から、コミットハッシュ固定でこのファイルを取得して実行する。
set -euo pipefail

REPO="${CLAUDE_ENV_REPO:-windymelt/claude-cloud-environment}"
REF="${CLAUDE_ENV_REF:?CLAUDE_ENV_REF (commit hash) must be set}"
BASE="https://raw.githubusercontent.com/$REPO/$REF"

run() {
  echo "==> $1"
  curl -fsSL --retry 4 --retry-delay 2 "$BASE/$1" | bash
}

run setup-claude-md.sh
run setup-proton-pass.sh
run setup-sdkman.sh
run setup-scala.sh
