#!/bin/zsh

set -euo pipefail

echo "Paste the Stitch API key when prompted. The value will be hidden."
/usr/bin/security add-generic-password \
  -U \
  -a "$USER" \
  -s "codex-stitch-api-key" \
  -l "Codex Stitch API Key" \
  -w
echo "Stitch API key saved to macOS Keychain."
