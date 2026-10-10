#!/bin/zsh
# Builds or updates Telas in place, retaining its identity between builds.
set -e
cd "$(dirname "$0")"

# Optional local configuration is deliberately excluded from Git.
[[ -f .telas-build.env ]] && source .telas-build.env
DEFAULT_APP=build/Strato.app
[[ "$1" == "--install" ]] && DEFAULT_APP=/Applications/Strato.app
APP="${TELAS_APP_PATH:-$DEFAULT_APP}"
SIGN_IDENTITY="${TELAS_SIGN_IDENTITY:-$(security find-identity -v -p codesigning | awk '/Apple Development:/{print $2;exit}')}"
if [[ -z "$SIGN_IDENTITY" ]]; then
  echo "No signing identity: set TELAS_SIGN_IDENTITY. Refusing an ad-hoc signature that resets permissions."
  exit 1
fi
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp Resources/Strato.icns "$APP/Contents/Resources/Strato.icns"
cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleName</key><string>Strato</string>
<key>CFBundleIconFile</key><string>Strato.icns</string>
<key>CFBundleIdentifier</key><string>${TELAS_BUNDLE_ID:-io.github.MehdiAlizadehGitHub.strato}</string>
<key>CFBundleExecutable</key><string>Strato</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleShortVersionString</key><string>0.1.0</string>
<key>LSMinimumSystemVersion</key><string>14.0</string>
<key>LSUIElement</key><true/>
</dict></plist>
PLIST

BIN=$(mktemp /tmp/telas-build.XXXXXX)
trap 'rm -f "$BIN"' EXIT
swiftc -O -parse-as-library -import-objc-header Sources/VirtualDisplay.h Sources/RegionLayout.swift Sources/Telas.swift -o "$BIN"
cp "$BIN" "$APP/Contents/MacOS/Strato"

# Keep the same certificate, bundle ID and application path across updates.
xattr -cr "$APP"
codesign -s "$SIGN_IDENTITY" --force "$APP"
codesign --verify --deep --strict "$APP"
echo "Built $APP"

if [[ "$1" == "--install" ]]; then
  echo "Updated $APP. Quit and reopen this same application to use the new build."
fi
