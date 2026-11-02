#!/usr/bin/env bash
# SDKMAN をインストールする (インストール済みならスキップ)
set -euo pipefail

if [ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
  echo "SDKMAN already installed, skipping"
  exit 0
fi
curl -fsSL --retry 4 --retry-delay 2 https://get.sdkman.io | bash
