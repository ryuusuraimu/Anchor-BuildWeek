#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

RUN_BUILD=0
if [[ "${1:-}" == "--build" ]]; then
  RUN_BUILD=1
fi

section() {
  printf '\n== %s ==\n' "$1"
}

fail() {
  printf 'ERROR: %s\n' "$1" >&2
  exit 1
}

warn() {
  printf 'WARN: %s\n' "$1" >&2
}

require_tool() {
  command -v "$1" >/dev/null 2>&1 || fail "Missing required tool: $1"
}

section "Tooling"
require_tool rg
require_tool plutil
require_tool xcodebuild
require_tool swift

xcodebuild -version
swift --version

section "Project shape"
[[ -f Package.swift ]] || fail "Package.swift not found"
[[ -f InfoPlist_Additions.plist ]] || fail "InfoPlist_Additions.plist not found"
[[ -f PrivacyInfo.xcprivacy ]] || fail "PrivacyInfo.xcprivacy not found"
[[ -d App ]] || fail "App directory not found"
[[ -d Features ]] || fail "Features directory not found"
[[ -d Assets.xcassets ]] || fail "Assets.xcassets directory not found"

if rg -q 'import AppleProductTypes' Package.swift; then
  printf 'Detected Swift Playgrounds iOS application manifest.\n'
else
  warn "Package.swift does not import AppleProductTypes; update validation assumptions if project format changed."
fi

rg -q 'bundleIdentifier: "com\.Ryunosuke\.AnchorBuildWeek"' Package.swift \
  || fail "Expected bundle identifier not found"
rg -q 'displayVersion: "1\.1"' Package.swift \
  || warn "Expected displayVersion 1.1 not found; confirm release version before submission."
rg -q 'bundleVersion: "1"' Package.swift \
  || warn "Expected Build Week bundleVersion 1 not found; confirm build number before submission."
rg -q '\.iOS\("17\.0"\)' Package.swift \
  || warn "Expected iOS 17.0 platform not found; confirm minimum OS."
rg -q '\.phone' Package.swift \
  || fail "Expected iPhone device family for v1"
rg -q '\.process\("PrivacyInfo\.xcprivacy"\)' Package.swift \
  || fail "PrivacyInfo.xcprivacy should be processed as a target resource"
if rg -n '\.pad|UISupportedInterfaceOrientations~ipad' Package.swift InfoPlist_Additions.plist >/tmp/anchor_validate_match.txt; then
  cat /tmp/anchor_validate_match.txt >&2
  fail "v1 should be iPhone-only; remove iPad device family/orientation settings"
fi

section "Info.plist"
plutil -lint InfoPlist_Additions.plist
rg -q 'NSContactsUsageDescription' InfoPlist_Additions.plist \
  || fail "Missing Contacts usage description"
rg -q 'trusted support contact' InfoPlist_Additions.plist \
  || fail "Contacts usage description should mention trusted support contact"

section "Privacy manifest"
plutil -lint PrivacyInfo.xcprivacy
rg -q 'NSPrivacyTracking' PrivacyInfo.xcprivacy \
  || fail "Privacy manifest should declare tracking status"
rg -q '<false/>' PrivacyInfo.xcprivacy \
  || fail "Privacy manifest should declare tracking disabled"
rg -q 'NSPrivacyCollectedDataTypes' PrivacyInfo.xcprivacy \
  || fail "Privacy manifest should declare collected data types"
rg -q 'NSPrivacyCollectedDataTypeOtherUserContent' PrivacyInfo.xcprivacy \
  || fail "Privacy manifest should disclose prepared Shield wording sent for voice generation"
rg -q 'NSPrivacyCollectedDataTypePurposeAppFunctionality' PrivacyInfo.xcprivacy \
  || fail "Voice-generation user content should be limited to app functionality"
rg -q 'NSPrivacyAccessedAPICategoryUserDefaults' PrivacyInfo.xcprivacy \
  || fail "Privacy manifest should include UserDefaults accessed API reason"
rg -q 'CA92\.1' PrivacyInfo.xcprivacy \
  || fail "Privacy manifest should include the UserDefaults reason code"
rg -q 'Clear Local Data' Features/Settings/Views/SettingsView.swift \
  || fail "Settings should include a Clear Local Data control"
rg -q 'clearLocalData' Features/Settings/Views/SettingsView.swift \
  || fail "Settings should implement local data clearing"
rg -q 'clearAll' Features/Journal/Services/JournalStorage.swift \
  || fail "Journal storage should support clearing local entries"
rg -q 'anchor.supportContacts.v2' Features/Contact/Stores/EmergencyContactStore.swift \
  || fail "Support Relay should persist multiple contacts with the v2 storage key"
rg -q 'clearPersistedData' Features/Contact/Stores/EmergencyContactStore.swift \
  || fail "Support Relay should clear both current and legacy contact storage"
rg -Fq '@Published var contacts: [EmergencyContact]' Features/Contact/Stores/EmergencyContactStore.swift \
  || fail "Support Relay store should publish multiple contacts"
rg -q 'Support Relay' Features/Shield/Views/ShieldView.swift \
  || fail "Shield should expose Support Relay controls"
rg -q 'Next support contact' Features/Shield/Views/ShieldView.swift \
  || fail "Shield should expose an accessible next-contact action"
rg -Fq 'Call \(contact.name)' Features/Shield/Views/ShieldView.swift \
  || fail "Shield should expose a large named call action"
rg -Fq 'Move \(contact.name) earlier' Features/Contact/Views/EmergencyContactCard.swift \
  || fail "Support Relay ordering should expose accessible move-earlier actions"

section "Build Week experience"
[[ -f Features/BuildWeek/Design/BuildWeekDesignSystem.swift ]] \
  || fail "Build Week design system not found"
[[ -f Features/BuildWeek/Design/HumanSignalHomeField.swift ]] \
  || fail "Human Signal Home field not found"
[[ -f Features/BuildWeek/Design/ResponsiveShelterField.swift ]] \
  || fail "Responsive Shelter field not found"
[[ -f Features/BuildWeek/Design/LivingGeometryField.swift ]] \
  || fail "Living Geometry Rive bridge not found"
[[ -f Features/BuildWeek/Views/BuildWeekHomeView.swift ]] \
  || fail "Build Week home not found"
[[ -f Features/BuildWeek/Views/ResponsiveResetView.swift ]] \
  || fail "Responsive Reset not found"
[[ -f Features/BuildWeek/Views/ResponsiveThemePickerView.swift ]] \
  || fail "Responsive Shelter theme picker not found"
[[ -f Features/BuildWeek/Views/OneMinuteAnchorView.swift ]] \
  || fail "One-Minute Anchor flow not found"
[[ -f Features/BuildWeek/Views/BuildWeekShieldView.swift ]] \
  || fail "Build Week Shield not found"
[[ -f Features/BuildWeek/Views/BuildWeekAftercareView.swift ]] \
  || fail "Optional Build Week aftercare flow not found"
[[ -f Features/BuildWeek/Views/BuildWeekContactEditor.swift ]] \
  || fail "Build Week contact editor not found"
rg -q 'case home, shield, prepare' App/MainTabView.swift \
  || fail "Build Week navigation should expose only Home, Shield, and Prepare tabs"
rg -q 'BuildWeekHomeView' App/MainTabView.swift \
  || fail "Main tab should route to Build Week home"
rg -q 'case grounded' App/SettingsStore.swift \
  || fail "Responsive Shelter should include the Grounded theme"
rg -q 'case luminous' App/SettingsStore.swift \
  || fail "Responsive Shelter should include the Luminous theme"
rg -q 'LivingGeometryField' Features/BuildWeek/Views/BuildWeekHomeView.swift \
  || fail "Home should use the Living Geometry visual field"
rg -Fq 'Text("You have\na way to ask.")' Features/BuildWeek/Views/BuildWeekHomeView.swift \
  || fail "Home should preserve the final Human Signal editorial message"
rg -q 'Reset atmosphere' Features/BuildWeek/Views/BuildWeekHomeView.swift \
  || fail "Home should identify the theme control as Reset-only"
rg -q 'HumanSignalHomeField' Features/BuildWeek/Design/LivingGeometryField.swift \
  || fail "Resting Living Geometry should use the light Human Signal field"
rg -q 'accessibilityReduceMotion' Features/BuildWeek/Design/HumanSignalHomeField.swift \
  || fail "Human Signal Home should respect Reduce Motion"
rg -q 'scenePhase == \.active' Features/BuildWeek/Design/HumanSignalHomeField.swift \
  || fail "Human Signal Home motion should stop when the app is inactive"
rg -Fq 'TimelineView(.animation)' Features/BuildWeek/Design/HumanSignalHomeField.swift \
  || fail "Human Signal Home motion should remain display-synchronized"
rg -q 'ResponsiveResetView' Features/BuildWeek/Views/BuildWeekHomeView.swift \
  || fail "Home should expose the two-minute responsive reset"
rg -q 'Choose your Reset' Features/BuildWeek/Views/ResponsiveThemePickerView.swift \
  || fail "Theme picker should present atmospheres as Reset-only"
rg -q 'Home stays light\. Shield stays static and high contrast\.' Features/BuildWeek/Views/ResponsiveThemePickerView.swift \
  || fail "Theme picker should state the Home and Shield safety boundary"
if rg -n 'RiveRuntime|rive-ios' Package.swift >/tmp/anchor_validate_match.txt; then
  cat /tmp/anchor_validate_match.txt >&2
  fail "The shipping target should not link an unused Rive runtime without a bundled .riv asset"
fi
rg -q 'AnchorLivingGeometry' Features/BuildWeek/Design/LivingGeometryField.swift \
  || fail "Living Geometry should look for the bundled Anchor Rive asset"
rg -q 'ResponsiveShelterField' Features/BuildWeek/Design/LivingGeometryField.swift \
  || fail "Living Geometry should keep the native Canvas fallback"
rg -q 'accessibilityReduceMotion' Features/BuildWeek/Design/LivingGeometryField.swift \
  || fail "Living Geometry should respect Reduce Motion before loading Rive"
rg -Fq 'setPreferredFramesPerSecond(preferredFramesPerSecond: 60)' Features/BuildWeek/Design/LivingGeometryField.swift \
  || fail "Rive Living Geometry should retain its 60 fps cap"
rg -Fq 'setInput("engagement"' Features/BuildWeek/Design/LivingGeometryField.swift \
  || fail "Living Geometry should expose the interaction intensity contract"
rg -q 'accessibilityReduceMotion' Features/BuildWeek/Design/ResponsiveShelterField.swift \
  || fail "Responsive Shelter motion should respect Reduce Motion"
rg -q 'scenePhase == \.active' Features/BuildWeek/Design/ResponsiveShelterField.swift \
  || fail "Responsive Shelter motion should stop when the app is inactive"
rg -Fq 'TimelineView(.animation)' Features/BuildWeek/Design/ResponsiveShelterField.swift \
  || fail "Responsive Shelter motion should remain synchronized to the display"
rg -q 'phaseOrigin: motionOrigin' Features/BuildWeek/Views/ResponsiveResetView.swift \
  || fail "Reset motion should use a session-relative breathing clock"
rg -q 'frozenMotionPhase' Features/BuildWeek/Views/ResponsiveResetView.swift \
  || fail "Reset should preserve its visual phase while paused"
if rg -n 'ResponsiveShelterField|LivingGeometryField|RiveRuntime|TimelineView|\.animation\(' Features/BuildWeek/Views/BuildWeekShieldView.swift >/tmp/anchor_validate_match.txt; then
  cat /tmp/anchor_validate_match.txt >&2
  fail "Build Week Shield must remain static and independent of Shelter motion"
fi
rg -q 'Label\("Home"' App/MainTabView.swift \
  || fail "Home should be the first primary tab"
rg -q 'Label\("Shield"' App/MainTabView.swift \
  || fail "A one-tap Shield launcher should remain in the primary tab bar"
rg -q '\.tag\(AppTab\.shield\)' App/MainTabView.swift \
  || fail "The central Shield launcher should use the Shield tab selection"
rg -q 'OneMinuteAnchorView' App/MainTabView.swift \
  || fail "Prepare tab should route to One-Minute Anchor"
rg -q 'Label\("Prepare"' App/MainTabView.swift \
  || fail "Prepare should remain in the primary tab bar"
rg -Uq '(?s)BuildWeekHomeView.*Label\("Home".*Label\("Shield".*OneMinuteAnchorView.*Label\("Prepare"' App/MainTabView.swift \
  || fail "Primary tabs should remain ordered Home, central Shield, then Prepare"
rg -q 'showShield = true' App/MainTabView.swift \
  || fail "Selecting the Shield tab should open the global one-tap Shield"
rg -q '\.sheet\(isPresented: \$showAftercare\)' Features/BuildWeek/Views/BuildWeekHomeView.swift \
  || fail "Aftercare should be an optional Home sheet, not a required tab"
rg -q 'BuildWeekAftercareView' Features/BuildWeek/Views/BuildWeekHomeView.swift \
  || fail "Home should expose the optional aftercare check-in"
if rg -n 'BuildWeekAftercareView|LearnView\(|JournalView\(|StudioView\(' App/MainTabView.swift >/tmp/anchor_validate_match.txt; then
  cat /tmp/anchor_validate_match.txt >&2
  fail "Aftercare and legacy Learn, Journal, or Studio views must not appear in the primary tab route"
fi
if rg -n 'StudioView\(|showAdvancedStudio|Open advanced editor' Features/BuildWeek/Views/OneMinuteAnchorView.swift >/tmp/anchor_validate_match.txt; then
  cat /tmp/anchor_validate_match.txt >&2
  fail "Prepare should not expose the legacy advanced editor"
fi
rg -q 'BuildWeekContactEditor' Features/BuildWeek/Views/OneMinuteAnchorView.swift \
  || fail "Prepare should use the low-burden Build Week contact editor"
rg -q 'Who should Anchor offer to call\?' Features/BuildWeek/Views/BuildWeekContactEditor.swift \
  || fail "Contact editor should keep the single-question Human Signal hierarchy"
rg -q 'PRIVATE ON THIS DEVICE' Features/BuildWeek/Views/BuildWeekContactEditor.swift \
  || fail "Contact editor should explain local privacy"
rg -Fq 'JournalStorage.shared.addEntry' Features/BuildWeek/Views/BuildWeekAftercareView.swift \
  || fail "Aftercare should save its optional check-in to local JournalStorage"
rg -q 'Nothing to solve right now\.' Features/BuildWeek/Views/BuildWeekAftercareView.swift \
  || fail "Aftercare should preserve the low-pressure editorial message"
rg -q 'I still need my Shield' Features/BuildWeek/Views/BuildWeekAftercareView.swift \
  || fail "Aftercare should keep a direct Shield fallback"
rg -q 'BuildWeekShieldView' App/ContentView.swift \
  || fail "Global Shield route should use Build Week Shield"
rg -q 'HoldToCloseButton' Features/BuildWeek/Views/BuildWeekShieldView.swift \
  || fail "Build Week Shield should preserve hold-to-close"
rg -q '\.accessibilityAction' Features/Shield/Views/HoldToCloseButton.swift \
  || fail "Hold-to-close should expose a standard VoiceOver accessibility action"
if rg -n '"en-US"' Features/BuildWeek/Views/BuildWeekShieldView.swift >/tmp/anchor_validate_match.txt; then
  cat /tmp/anchor_validate_match.txt >&2
  fail "Build Week Shield speech should detect the prepared text language instead of forcing en-US"
fi
rg -Fq 'Call \(contact.name)' Features/BuildWeek/Views/BuildWeekShieldView.swift \
  || fail "Build Week Shield should expose a large named call action"
rg -q 'Next support contact' Features/BuildWeek/Views/BuildWeekShieldView.swift \
  || fail "Build Week Shield should expose accessible relay navigation"
rg -q 'autoCycleEnabled: false' Features/BuildWeek/Views/BuildWeekShieldView.swift \
  || fail "Build Week Shield should not automatically cycle crisis instructions"
if rg -n 'A NOTE FROM ME|Thank you for helping\.|Show QR support card.*arrow\.right' Features/BuildWeek/Views/BuildWeekShieldView.swift >/tmp/anchor_validate_match.txt; then
  cat /tmp/anchor_validate_match.txt >&2
  fail "Build Week Shield should keep the primary reading path free of redundant editorial furniture"
fi
rg -q 'private func qrButton' Features/BuildWeek/Views/BuildWeekShieldView.swift \
  || fail "Build Week Shield should keep QR available outside the primary reading path"
rg -q 'SignalSafetyBand' Features/BuildWeek/Views/BuildWeekShieldView.swift \
  || fail "Build Week Shield should give Safety a distinct visual hierarchy"
rg -q 'SignalGuidanceSheet' Features/BuildWeek/Views/BuildWeekShieldView.swift \
  || fail "Build Week Shield should keep What helps and Please avoid in one guidance sheet"
[[ -f Features/BuildWeek/Views/BuildWeekVoiceSettingsView.swift ]] \
  || fail "Build Week voice settings not found"
[[ -f Features/Shield/Services/ShieldVoiceLibrary.swift ]] \
  || fail "Prepared Shield voice library not found"
rg -q 'Create offline reading' Features/BuildWeek/Views/BuildWeekVoiceSettingsView.swift \
  || fail "Voice settings should offer intentional offline preparation"
rg -q 'AI-generated by OpenAI' Features/BuildWeek/Views/BuildWeekVoiceSettingsView.swift \
  || fail "Voice settings should disclose that OpenAI voices are AI-generated"
rg -q 'cachedSpeechURL' Features/BuildWeek/Views/BuildWeekShieldView.swift \
  || fail "Build Week Shield should use only prepared voice audio"
if rg -n 'URLSession|generateShieldVoice|/v1/speech' Features/BuildWeek/Views/BuildWeekShieldView.swift Features/Shield/Logic/ShieldEngine.swift >/tmp/anchor_validate_match.txt; then
  cat /tmp/anchor_validate_match.txt >&2
  fail "Shield presentation and playback must remain network-independent"
fi
rg -q 'URLSessionConfiguration\.ephemeral' Features/Shield/Services/ShieldVoiceLibrary.swift \
  || fail "Prepared voice generation should use an ephemeral URL session"
rg -q 'applicationSupportDirectory' Features/Shield/Services/ShieldVoiceLibrary.swift \
  || fail "Prepared Shield audio should be stored locally before use"
rg -q 'Practice only\. No phone call is placed\.' Features/BuildWeek/Views/BuildWeekShieldView.swift \
  || fail "Practice Shield should explicitly prevent real phone calls"
rg -q 'debugContactsOverride' Features/BuildWeek/Views/BuildWeekShieldView.swift \
  || fail "Build Week Shield should expose nonpersistent visual-review scenarios"
rg -q 'contactsOverride' Features/Shield/Views/ShieldQRCodeView.swift \
  || fail "Shield QR should use the same nonpersistent review contact state"
rg -q 'settings\.increaseBrightnessOnShieldCard' Features/Shield/Views/ShieldQRCodeView.swift \
  || fail "Shield QR brightness should respect the person's saved preference"
if rg -n 'NO SUPPORT CONTACT SET|cross\.case\.fill|speaker\.slash\.fill' Features/BuildWeek/Views/BuildWeekShieldView.swift >/tmp/anchor_validate_match.txt; then
  cat /tmp/anchor_validate_match.txt >&2
  fail "Build Week Shield should avoid public setup errors, medical tiles, and disabled-looking speech controls"
fi
if rg -n 'applyEmergencyBrightness\(enabled: true\)|Generated:' Features/Shield/Views/ShieldQRCodeView.swift >/tmp/anchor_validate_match.txt; then
  cat /tmp/anchor_validate_match.txt >&2
  fail "Shield QR should avoid forced brightness and unstable generated timestamps"
fi

section "Production content checks"
FORBIDDEN_PATTERNS=(
  'generateDemoData'
  'Demo entry for January'
  'Successfully set up Anchor today'
  '200M\+'
  'Panic in \\\(\\.applicationName\\\)'
  'Panic Attack'
  'Autism Meltdown'
  'Dissociation'
  'Emergency Mode'
  'Emergency Setup'
  'Add Emergency Contact'
  'That.s rude'
  'Are you okay\?'
  'ANCHOR Emergency Protocol'
  'Text\("Emergency Contact"\)'
  'title: "Emergency Contact"'
  'emergency use'
  'quickly set an emergency contact'
  'Stop panic attacks'
  'Treat panic'
  'Cure panic'
  'MEDICAL ALERT'
  'PhotosUI'
  'UIImageWriteToSavedPhotosAlbum'
  'NSPhoto'
  'Save Wallpaper'
  'Firebase'
  'AdMob'
  'AppTrackingTransparency'
  'UserNotifications'
  'UNUserNotificationCenter'
)

for pattern in "${FORBIDDEN_PATTERNS[@]}"; do
  if rg -n "$pattern" App Features Services InfoPlist_Additions.plist Package.swift >/tmp/anchor_validate_match.txt 2>/dev/null; then
    cat /tmp/anchor_validate_match.txt >&2
    fail "Forbidden production pattern found: $pattern"
  fi
done

if rg -n 'URLSession' App Features Services --glob '!Features/Shield/Services/ShieldVoiceLibrary.swift' >/tmp/anchor_validate_match.txt; then
  cat /tmp/anchor_validate_match.txt >&2
  fail "Network access is allowed only in the calm-state prepared voice library"
fi

section "Store launch artifacts"
[[ -f STORE_LAUNCH_PLAN.md ]] || fail "STORE_LAUNCH_PLAN.md not found"
[[ -f APP_STORE_METADATA_DRAFT.md ]] || fail "APP_STORE_METADATA_DRAFT.md not found"
[[ -f PRIVACY_POLICY_DRAFT.md ]] || fail "PRIVACY_POLICY_DRAFT.md not found"
[[ -f ADS_LAUNCH_PLAN.md ]] || fail "ADS_LAUNCH_PLAN.md not found"
[[ -f IOS_DEVELOPMENT_WORKFLOW.md ]] || fail "IOS_DEVELOPMENT_WORKFLOW.md not found"
[[ -f PRODUCT_REQUIREMENTS.md ]] || fail "PRODUCT_REQUIREMENTS.md not found"
[[ -f TODAY_SUBMISSION_PLAN.md ]] || fail "TODAY_SUBMISSION_PLAN.md not found"
[[ -f BUILD_PROBE_RESULTS.md ]] || fail "BUILD_PROBE_RESULTS.md not found"
[[ -f STORE_SCREENSHOT_PLAN.md ]] || fail "STORE_SCREENSHOT_PLAN.md not found"
[[ -f XCODEBUILDMCP_ADOPTION.md ]] || fail "XCODEBUILDMCP_ADOPTION.md not found"
[[ -f RELEASE_READINESS_STATUS.md ]] || fail "RELEASE_READINESS_STATUS.md not found"
[[ -f UI_LAYOUT_AUDIT.md ]] || fail "UI_LAYOUT_AUDIT.md not found"
[[ -f StoreWeb/privacy.html ]] || fail "StoreWeb/privacy.html not found"
[[ -f StoreWeb/support.html ]] || fail "StoreWeb/support.html not found"
[[ -f STORE_WEB_HOSTING_GUIDE.md ]] || fail "STORE_WEB_HOSTING_GUIDE.md not found"
[[ -f APP_STORE_CONNECT_RUNBOOK.md ]] || fail "APP_STORE_CONNECT_RUNBOOK.md not found"
[[ -f APP_PRIVACY_ANSWERS.md ]] || fail "APP_PRIVACY_ANSWERS.md not found"
[[ -f AGE_RATING_ANSWERS.md ]] || fail "AGE_RATING_ANSWERS.md not found"
[[ -x Scripts/anchor_simulator_loop.sh ]] || fail "Scripts/anchor_simulator_loop.sh should exist and be executable"
[[ -f Assets.xcassets/AnchorCalmIllustration.imageset/AnchorCalmIllustration.png ]] \
  || fail "AnchorCalmIllustration image asset not found"
rg -q 'Build for iOS' IOS_DEVELOPMENT_WORKFLOW.md \
  || fail "iOS workflow should reference Codex Build for iOS"
rg -q 'panic-time communication aid' PRODUCT_REQUIREMENTS.md \
  || fail "Product requirements should capture panic-time communication positioning"
rg -q 'Submit Anchor to App Review today' TODAY_SUBMISSION_PLAN.md \
  || fail "Today submission plan should capture the same-day submission goal"
rg -q 'Static release-readiness validation passes' BUILD_PROBE_RESULTS.md \
  || fail "Build probe results should summarize validation status"
rg -q 'Do not use the current screenshot set as-is' STORE_SCREENSHOT_PLAN.md \
  || fail "Screenshot plan should capture the recapture decision"
rg -q 'XcodeBuildMCP workflow' XCODEBUILDMCP_ADOPTION.md \
  || fail "XcodeBuildMCP adoption plan should capture the simulator workflow"
rg -q 'Release Blockers' RELEASE_READINESS_STATUS.md \
  || fail "Release readiness status should capture remaining blockers"
rg -q 'visible simulator build is stale' UI_LAYOUT_AUDIT.md \
  || fail "UI layout audit should capture stale simulator screenshot caveat"
rg -q 'Data Not Linked to You' APP_PRIVACY_ANSWERS.md \
  || fail "App privacy answers should disclose voice-generation user content"
rg -q 'App Store age rating' AGE_RATING_ANSWERS.md \
  || fail "Age rating answers should capture App Store questionnaire guidance"
rg -q 'Privacy Policy URL' STORE_WEB_HOSTING_GUIDE.md \
  || fail "Store web hosting guide should capture App Store URL usage"
rg -q 'Final Pre-Submit Gate' APP_STORE_CONNECT_RUNBOOK.md \
  || fail "App Store Connect runbook should include a final pre-submit gate"

section "Store copy consistency"
rg -q 'support contact' APP_STORE_METADATA_DRAFT.md \
  || fail "App Store metadata should mention support contact"
rg -q 'overwhelm support' APP_STORE_METADATA_DRAFT.md \
  || fail "App Store keyword draft should use overwhelm support"
if rg -n '^support card,.*(panic attack relief|panic cure|emergency contact)' APP_STORE_METADATA_DRAFT.md >/tmp/anchor_validate_match.txt; then
  cat /tmp/anchor_validate_match.txt >&2
  fail "App Store keyword draft still contains outdated launch keywords"
fi
if rg -n 'Initial keyword themes:.*(panic attack relief|panic cure|emergency contact)' STORE_LAUNCH_PLAN.md >/tmp/anchor_validate_match.txt; then
  cat /tmp/anchor_validate_match.txt >&2
  fail "Store launch plan still contains outdated ad keyword themes"
fi
if rg -n '^- (crisis card|emergency contact|medical ID alternative|panic attack relief|panic cure)$' ADS_LAUNCH_PLAN.md >/tmp/anchor_validate_match.txt; then
  cat /tmp/anchor_validate_match.txt >&2
  fail "Ads launch plan still contains outdated positive keyword targets"
fi

section "Swift file inventory"
SWIFT_COUNT="$(rg --files -g '*.swift' | wc -l | tr -d ' ')"
printf 'Swift files: %s\n' "$SWIFT_COUNT"
[[ "$SWIFT_COUNT" -gt 0 ]] || fail "No Swift files found"

section "Optional build probe"
if [[ "$RUN_BUILD" -eq 1 ]]; then
  MODULE_CACHE="${TMPDIR:-/tmp}/anchor-module-cache"
  CLONED_PACKAGES="${TMPDIR:-/tmp}/anchor-cloned-packages"
  mkdir -p "$MODULE_CACHE" "$CLONED_PACKAGES"

  set +e
  CLANG_MODULE_CACHE_PATH="$MODULE_CACHE" \
    SWIFTPM_MODULECACHE_OVERRIDE="$MODULE_CACHE" \
    xcodebuild \
      -list \
      -clonedSourcePackagesDirPath "$CLONED_PACKAGES"
  BUILD_STATUS=$?
  set -e

  if [[ "$BUILD_STATUS" -ne 0 ]]; then
    warn "xcodebuild project probe failed. In a sandboxed Codex session this can be caused by SwiftPM/Xcode cache or CoreSimulator permissions rather than app code."
    warn "If the probe keeps failing here, open the package in Xcode/Swift Playgrounds for Archive, or migrate to a native Xcode iOS project."
  else
    printf 'xcodebuild project probe succeeded.\n'
  fi
else
  printf 'Skipped. Run Scripts/validate_ios_project.sh --build to attempt xcodebuild probing.\n'
fi

section "Result"
printf 'Anchor iOS project validation passed for static release-readiness checks.\n'
