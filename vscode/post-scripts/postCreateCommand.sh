#!/usr/bin/env bash
set -eu -o pipefail

sudo chown vscode.vscode /workspace
${HOME}/.oh-my-zsh/tools/upgrade.sh

# Exit with success return code (0)
echo ''