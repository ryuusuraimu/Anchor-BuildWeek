# Anchor Native iOS Migration Plan

Last updated: 2026-07-08

## Why This Exists

Anchor is currently a Swift Playgrounds-style SwiftPM iOS application using `AppleProductTypes` in `Package.swift`.

That format is convenient for early prototyping, but it can become limiting when the project needs:

- Reliable command-line builds
- Xcode scheme discovery
- Simulator automation
- Archive/export automation
- App Store release signing
- CI-style validation
- XcodeBuildMCP automation

If these limitations continue to slow the release path, Anchor should migrate to a standard native Xcode iOS project.

## Current State

- Current format: SwiftPM iOS application manifest
- App target name: `AppModule`
- App name: `Anchor`
- Bundle identifier: `com.Ryunosuke.Anchor`
- Team identifier: `V7F5K95K4G`
- Display version: `1.0`
- Build version: `2`
- Minimum iOS: `17.0`
- Supported devices for v1: iPhone
- Orientation: portrait
- Assets: `Assets.xcassets`
- Resources: `Resources`
- Extra plist: `InfoPlist_Additions.plist`

## Decision Criteria

Stay on SwiftPM / Swift Playgrounds format if:

- Xcode can archive and upload reliably.
- App Store Connect submission does not require extra project customization.
- Local development remains comfortable.
- XcodeBuildMCP or command-line automation is not required for the near-term release.

Migrate to native Xcode project if:

- `xcodebuild` cannot reliably list, build, or archive the app.
- Simulator automation and screenshot capture are needed inside Codex.
- Signing, entitlements, archive/export, or App Store delivery becomes awkward.
- TestFlight work requires repeatable build scripts.
- The project needs multiple configurations, schemes, targets, tests, or extensions.

## Recommended Migration Shape

Create a sibling native Xcode project rather than mutating the current SwiftPM package in place.

Suggested structure:

```text
Anchor Project
├── Anchor.swiftpm
│   └── current source of truth until migration is verified
└── Anchor.xcodeproj
    └── native iOS app project
```

Alternative structure after migration is complete:

```text
Anchor
├── AnchorApp
├── Features
├── Services
├── Resources
├── Assets.xcassets
├── Anchor.xcodeproj
└── Package.swift, optional only for reusable modules
```

## Migration Steps

1. Create a new native iOS App project in Xcode.
2. Use SwiftUI lifecycle.
3. Set bundle identifier to `com.Ryunosuke.Anchor`.
4. Set team identifier/signing to the existing Apple Developer team.
5. Set minimum deployment target to iOS 17.0 or the confirmed target.
6. Copy or reference source directories:
   - `App`
   - `Features`
   - `Services`
7. Copy or reference assets/resources:
   - `Assets.xcassets`
   - `Resources`
   - `InfoPlist_Additions.plist` values
8. Preserve app icon and accent color.
9. Add required frameworks:
   - SwiftUI
   - UIKit
   - ContactsUI
   - AVFoundation
   - MediaPlayer
   - AppIntents
   - CoreImage
   - UserNotifications
10. Add App Intents files to the app target.
11. Confirm `@main` remains in `App/MyApp.swift`.
12. Build and fix target membership/import issues.
13. Run smoke tests:
   - First launch setup
   - Home
   - Studio
   - Shield
   - QR
   - Contact picker/manual contact
   - Journal empty state and entry creation
   - Learn
   - Settings
   - App Shortcuts
   - Lock Screen / Now Playing on real iPhone
14. Archive and validate.
15. Only after native project is verified, decide whether to retire or keep `Anchor.swiftpm`.

## Validation After Migration

Required CLI checks:

```bash
xcodebuild -list -project Anchor.xcodeproj
xcodebuild -scheme Anchor -destination 'platform=iOS Simulator,name=iPhone 16' build
```

If XcodeBuildMCP is available:

- List simulators.
- Set session defaults.
- Build and run.
- Capture screenshots.
- Describe UI.
- Capture logs for Shield / Now Playing / Contacts flows.

## Risks

- Target membership mistakes can cause missing symbols or resources.
- Asset catalog naming must match current `Package.swift` expectations.
- Info.plist settings must be copied carefully, especially Contacts permission and background audio.
- App Intents may require target membership and availability checks.
- Signing and bundle ID must match the App Store Connect record.
- If files are copied instead of referenced, source divergence can happen.

## Recommendation For Anchor

For the next release pass:

1. Continue with `Anchor.swiftpm` while static release-readiness checks are passing.
2. Attempt a real Xcode archive from the current project.
3. If archive/upload is unreliable, migrate to a native Xcode project before investing more in TestFlight, screenshots, or App Store automation.
