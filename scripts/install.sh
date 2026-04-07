#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_BUNDLE="$SCRIPT_DIR/../build/TogglMac.app"

echo "Building TogglMac..."
bash "$SCRIPT_DIR/build-app.sh"

echo ""
echo "Installing to /Applications/..."
cp -R "$APP_BUNDLE" /Applications/TogglMac.app

echo ""
echo "Successfully installed: /Applications/TogglMac.app"
echo "You can now launch TogglMac from your Applications folder or Spotlight."
