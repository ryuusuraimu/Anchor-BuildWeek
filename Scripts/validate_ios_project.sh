#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

fail() {
  printf 'ERROR: %s\n' "$1" >&2
  exit 1
}

for path in Anchor.xcodeproj App Features Services Assets.xcassets Info.plist PrivacyInfo.xcprivacy; do
  [[ -e "$path" ]] || fail "Required Xcode project path not found: $path"
done
[[ -f Anchor.xcodeproj/xcshareddata/xcschemes/Anchor.xcscheme ]] || fail "Shared Anchor scheme is missing"
[[ -f Assets.xcassets/AppIcon.appiconset/Contents.json ]] || fail "AppIcon catalog entry is missing"
[[ -f Resources/HomeHero.jpg ]] || fail "Resources/HomeHero.jpg is missing"
[[ -f VoiceProxy/server.mjs && -f VoiceProxy/contract.mjs && -f VoiceProxy/contract.test.mjs && -f VoiceProxy/.env.example ]] || fail "VoiceProxy files are incomplete"
[[ ! -e Package.swift ]] || fail "Playgrounds Package.swift must be removed"
[[ ! -e InfoPlist_Additions.plist ]] || fail "Legacy InfoPlist_Additions.plist must be removed"

if command -v plutil >/dev/null 2>&1; then
  plutil -lint Info.plist PrivacyInfo.xcprivacy
fi

rg -q '@main' App/MyApp.swift && rg -q 'struct MyApp: App' App/MyApp.swift || fail "MyApp.swift is not the SwiftUI app entry point"
rg -q 'com.Ryunosuke.AnchorBuildWeek' Anchor.xcodeproj/project.pbxproj || fail "Bundle identifier is missing"
rg -q 'IPHONEOS_DEPLOYMENT_TARGET = 17.0' Anchor.xcodeproj/project.pbxproj || fail "iOS deployment target must be 17.0"
rg -q 'TARGETED_DEVICE_FAMILY = 1' Anchor.xcodeproj/project.pbxproj || fail "Target must be iPhone-only"
rg -q 'ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon' Anchor.xcodeproj/project.pbxproj || fail "AppIcon build setting is missing"
rg -q 'NSContactsUsageDescription' Info.plist || fail "Contacts permission is missing"
rg -q 'NSLocalNetworkUsageDescription' Info.plist || fail "Local Network permission is missing"
rg -q 'UIBackgroundModes' Info.plist && rg -q '<string>audio</string>' Info.plist || fail "Background Audio mode is missing"
rg -q 'UIInterfaceOrientationPortrait' Info.plist || fail "Portrait orientation is missing"
rg -q 'HomeHero.jpg' Anchor.xcodeproj/project.pbxproj || fail "HomeHero resource is not registered in the project"
rg -q 'PrivacyInfo.xcprivacy' Anchor.xcodeproj/project.pbxproj || fail "Privacy manifest is not registered in the project"
rg -q 'Assets.xcassets' Anchor.xcodeproj/project.pbxproj || fail "Asset catalog is not registered in the project"
if rg -n 'VoiceProxy|BuildWeekScreenshots' Anchor.xcodeproj/project.pbxproj; then
  fail "VoiceProxy or README screenshots must not be included in the app target"
fi
if rg -n '\.module' App Features Services -g '*.swift'; then
  fail "SwiftPM-only Bundle.module references remain"
fi

for image in \
  BuildWeekScreenshots/2026-07-20/01-home-current.png \
  BuildWeekScreenshots/2026-07-20/02-prepare-complete-current.png \
  BuildWeekScreenshots/2026-07-20/03-shield-current.png \
  BuildWeekScreenshots/2026-07-20/04-shield-qr-current.png \
  BuildWeekScreenshots/2026-07-20/05-voice-settings-current.png \
  BuildWeekScreenshots/2026-07-20/06-reset-current.png; do
  [[ -f "$image" ]] || fail "README screenshot is missing: $image"
done

if command -v xcodebuild >/dev/null 2>&1; then
  xcodebuild -project Anchor.xcodeproj -list
  if xcodebuild -showsdks | rg -q 'iOS Simulator SDKs:'; then
    BUILD_ROOT="${TMPDIR:-/tmp}/anchor-portfolio-derived-data"
    xcodebuild \
      -project Anchor.xcodeproj \
      -scheme Anchor \
      -sdk iphonesimulator \
      -configuration Debug \
      -derivedDataPath "$BUILD_ROOT" \
      -quiet \
      CODE_SIGNING_ALLOWED=NO \
      build
    APP_PRODUCT="$BUILD_ROOT/Build/Products/Debug-iphonesimulator/Anchor.app"
    [[ -d "$APP_PRODUCT" ]] || fail "Simulator app bundle was not produced"
    for resource in Assets.car HomeHero.jpg PrivacyInfo.xcprivacy; do
      [[ -f "$APP_PRODUCT/$resource" ]] || fail "App bundle resource is missing: $resource"
    done
    if find "$APP_PRODUCT" -iname '*VoiceProxy*' -o -iname '*BuildWeekScreenshots*' | rg -q .; then
      fail "VoiceProxy or README screenshots were bundled into the app"
    fi
  else
    printf 'iOS Simulator SDK unavailable; build not run.\n'
  fi
else
  printf 'Xcode is not installed; Xcode project build not verified.\n'
fi

printf 'Xcode project validation passed.\n'
