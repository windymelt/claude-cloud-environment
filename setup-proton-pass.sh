#!/usr/bin/env bash
# Proton Pass CLI (pass-cli) をインストールする
set -euo pipefail

curl -fsSL --retry 4 --retry-delay 2 https://proton.me/download/pass-cli/install.sh | bash
