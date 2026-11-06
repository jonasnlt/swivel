#!/usr/bin/env bash
# Builds the finished release app and puts it into dist/ for passing on:
#   dist/Swivel.app                 the app (signed ad hoc, Hardened Runtime, no test access)
#   dist/Swivel-<Version>.zip       the app as a ZIP (made with ditto, the signature stays intact)
#   dist/Swivel-<Version>.dmg       disk image with the app and an "Applications" shortcut
#   dist/SHA256SUMS.txt             checksums of the ZIP and the DMG
# Then it checks the signature, Hardened Runtime, entitlements, debug strings and sizes. Stops at the first error.
set -euo pipefail
cd "$(dirname "$0")/.."

./scripts/build.sh --release > /dev/null

APP_SRC=".build/release/Swivel.app"
VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$APP_SRC/Contents/Info.plist")
DIST="dist"
APP="$DIST/Swivel.app"
ZIP="$DIST/Swivel-$VERSION.zip"
DMG="$DIST/Swivel-$VERSION.dmg"
fail() { echo "FAIL $1" >&2; exit 1; }

rm -rf "$DIST"
mkdir -p "$DIST"
ditto "$APP_SRC" "$APP"

echo "==> Checking: $APP"
plist() { /usr/libexec/PlistBuddy -c "Print :$1" "$APP/Contents/Info.plist"; }
[[ "$(plist CFBundleIdentifier)" == "io.github.jonasnlt.swivel" ]] || fail "bundle ID $(plist CFBundleIdentifier)"
[[ "$(plist CFBundleName)" == "Swivel" ]] || fail "Name $(plist CFBundleName)"
echo "  ok   bundle ID io.github.jonasnlt.swivel, version $VERSION (build $(plist CFBundleVersion))"
codesign --verify --strict --deep "$APP" || fail "signature invalid"
SIGNATURE=$(codesign -d --verbose=2 "$APP" 2>&1)
grep -q "flags=0x10002(adhoc,runtime)" <<< "$SIGNATURE" || { echo "$SIGNATURE"; fail "not signed ad hoc with Hardened Runtime"; }
[[ -z "$(codesign -d --entitlements - "$APP" 2>/dev/null)" ]] || fail "has entitlements"
echo "  ok   signature valid, ad hoc, Hardened Runtime, no entitlements"
# Test access, debug switches and old names: debug builds only (the markers are long enough that a release build would contain them as text).
BINARY="$APP/Contents/MacOS/Swivel"
for TEXT in SWIVEL-DEBUG-TEST-ACCESS SWIVEL-DEBUG-REGULAR-APP SWIVEL_LOG_DIRECTORY SWIVEL_SCREENSHOTS SWIVEL_DEBUG_DRAG SWIVEL_TEST UMWANDLER; do
  if LC_ALL=C grep -a -q "$TEXT" "$BINARY"; then fail "debug string in the release build: $TEXT"; fi
done
if LC_ALL=C grep -a -q "AppIcon-Dev" "$APP/Contents/Info.plist"; then fail "debug icon in the release build"; fi
echo "  ok   no debug strings (test access, switches, old names)"
# Published: no paths from a home folder, license texts included (GPL-3.0 and the Satsuma MIT notice).
if LC_ALL=C grep -a -r -l "/Users/" "$APP" >/dev/null; then fail "path from /Users/ in the app: $(LC_ALL=C grep -a -r -l "/Users/" "$APP" | head -3)"; fi
cmp -s LICENSE "$APP/Contents/Resources/LICENSE.txt" || fail "GPL-3.0 text missing in the app"
[[ -f "$APP/Contents/Resources/LICENSES/Satsuma-MIT.txt" ]] || fail "Satsuma MIT notice missing in the app"
echo "  ok   no paths from /Users/, license texts included"

echo "==> ZIP"
ditto -c -k --sequesterRsrc --keepParent "$APP" "$ZIP"

echo "==> DMG"
STAGING=$(mktemp -d "${TMPDIR:-/tmp}/swivel-dmg.XXXXXX")
trap 'rm -rf "$STAGING"' EXIT
ditto "$APP" "$STAGING/Swivel.app"
ln -s /Applications "$STAGING/Applications"
hdiutil create -quiet -volname "Swivel $VERSION" -srcfolder "$STAGING" -fs HFS+ -format UDZO -ov "$DMG"
hdiutil verify -quiet "$DMG" || fail "DMG damaged"

echo "==> Checksums"
(cd "$DIST" && shasum -a 256 "$(basename "$ZIP")" "$(basename "$DMG")" > SHA256SUMS.txt && shasum -a 256 -c SHA256SUMS.txt > /dev/null) || fail "checksums"

echo "==> LaunchServices"
# Don't leave dist/Swivel.app registered with macOS: otherwise the Finder services show up twice in the right-click menu (next to
# /Applications/Swivel.app). Unregister it and have the services list read again.
LSREGISTER=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister
"$LSREGISTER" -u "$PWD/$APP" 2>/dev/null || true
/System/Library/CoreServices/pbs -update 2>/dev/null || true
if "$LSREGISTER" -dump 2>/dev/null | grep -q "^path: *$PWD/$APP "; then echo "  note: $APP is still registered with LaunchServices"; else echo "  ok   $APP unregistered, services read again"; fi

echo "==> Sizes"
du -sh "$APP" | sed 's/^/  /'
ls -lh "$ZIP" "$DMG" | awk '{print "  " $5 "\t" $9}'
echo "Done: $DIST"
