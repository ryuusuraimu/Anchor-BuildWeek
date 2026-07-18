# Anchor Build Probe Results

Last updated: 2026-07-18

## Prepared OpenAI voice — 2026-07-18

- Added a dependency-free Node VoiceProxy that validates prepared text and the 13
  supported voices before calling `gpt-4o-mini-tts` for AAC output.
- Added Cedar-default voice selection, preview, intentional offline preparation, local
  hashed AAC caching, AI disclosure, and Clear Local Data removal.
- Shield reads only a pre-generated local file and falls back to
  `AVSpeechSynthesizer`; it performs no network request or generation.
- VoiceProxy contract tests and static validation passed. The iPhone 17e Simulator build
  succeeded, and Voice & reading was screenshot-inspected at standard and maximum
  Dynamic Type.
- The end-to-end request reached OpenAI but returned HTTP 429 with
  `insufficient_quota`. A successful AAC response and physical-device audio playback
  remain unverified until API billing or usage limits are resolved.

## Display-synchronized Fluid Aperture — 2026-07-18

- Replaced the fixed 30/60 fps native schedule with SwiftUI's display-synchronized
  animation timeline. Standard displays render at 60Hz and ProMotion displays can update
  at 120Hz.
- Switched Canvas from asynchronous nonlinear rendering to synchronous linear-color
  rendering, removing the possible one-frame presentation delay.
- Replaced shared uniform scaling with depth-specific poses: two-harmonic Home drift,
  separate X/Y deformation, fifth-order Reset easing, and at most 0.048 seconds of
  Reset inter-layer lag.
- Reset pause now preserves `engagement = 1`, preventing the aperture from snapping to
  a different geometry on Pause before the phase is frozen.
- All 70 Swift files type-checked against RiveRuntime 6.20.1, compiled, linked, signed,
  installed, and launched on iPhone 17e Simulator.
- The final Reset recording is 28.777 seconds at a nominal 120.097 fps. Aperture-region
  pixel hashing inspected 3,456 frames and found zero consecutive duplicate frames.
- Two Reduce Motion frames captured five seconds apart were byte-identical with SHA-256
  `600834ff3dcac44276f62f1df07b9d064b06a45dc934487e7cce968e76973766`.
  The Simulator accessibility setting was restored after verification.
- Shield was launched directly and screenshot-inspected; it remains static and does not
  load the calm-state animation surface.
- `swift-format lint --strict` and `Scripts/validate_ios_project.sh` passed.

## Tidal Aperture production motion — 2026-07-17

- Replaced the generic wave/orbit Canvas field with an original, right-edge-anchored
  five-membrane Tidal Aperture in `ResponsiveShelterField.swift`.
- Home uses a 28-second, 30 fps micro-parallax loop. Reset uses a mathematically exact
  eight-second expansion/return loop and preserves the existing pause clock.
- All 70 Swift files type-checked against the real RiveRuntime 6.20.1 simulator
  framework, then compiled, linked, signed, installed, and launched on iPhone 17e.
- Luminous Home and Reset screenshots were inspected. A Reset recording spans more than
  one complete breath cycle. Shield was launched directly and remained static with no
  calm-state field present.
- With Simulator Reduce Motion enabled, two complete PNG frames captured five seconds
  apart were byte-identical and shared SHA-256
  `1e89922b809fd0e73e30013f18312f79655d1ccc20b8fc64306f99acc006c994`.
  The setting was restored to disabled after the test.
- `Scripts/validate_ios_project.sh` passed all static release-readiness checks.
- The editable Rive project was authored, but `.riv` runtime export is gated by the
  current Rive workspace plan. The production app uses the matching native vector
  implementation and does not rely on the editor, network, or a paid export.

## Living Geometry integration — 2026-07-17

- RiveRuntime is pinned to 6.20.1 through Swift Package Manager.
- The official 6.20.1 XCFramework archive matched the published package checksum:
  `19866d9265d0e1010d5d28ad49e37ebe582d48bae868087c521ab3c513c32219`.
- All app sources type-checked against the real RiveRuntime simulator framework.
- Home Start pressure and Reset state are connected to the shared `engagement`
  contract. The Rive player pauses with Reset and scene inactivity and is capped at
  30 fps.
- Reduce Motion bypasses Rive and uses a deterministic Canvas still. The native Canvas
  implementation also remains the automatic fallback until the original
  `AnchorLivingGeometry.riv` export is added.
- Shield remains outside the Rive/Canvas calm-state motion surface.
- The Rive-linked direct Simulator app launched successfully on iPhone 17e. Luminous
  Home, two Reset motion phases, unchanged Shield, and two Reduce Motion frames were
  captured and inspected. The Reduce Motion app content remained visually identical;
  only the system clock changed between frames.
- A 10-second Luminous Reset recording captured more than one complete eight-second
  breath cycle, and Home remained naturally scrollable at
  `accessibility-extra-extra-extra-large`.

The final Rive asset and simulator visual capture remain unverified because the Rive
Editor is currently waiting for account login. See `RIVE_LIVING_GEOMETRY_SPEC.md` for
the exact artboard and state-machine contract.

`xcodebuild -list` still reaches the package manifest but returns the existing blocker:

```text
Missing or empty JSON output from manifest compilation for anchor-buildweek.swiftpm
```

This did not affect the direct Rive-linked compile, signing, install, or Simulator launch,
but the standard Swift Playgrounds package build remains unconfirmed.

## Summary

The Responsive Shelter source compiles as one complete 68-file iOS module, and its
Grounded Home, Luminous Home, two-minute Reset, and unchanged static Shield were
launched and screenshot-verified on an iPhone 17e simulator.

Static release-readiness validation passes, including the Responsive Shelter contracts.
The normal Swift Playgrounds package build is not currently confirmed: Xcode reaches
manifest resolution but returns an empty JSON result for the package manifest in this
environment. That prevents claiming a clean release build from this run even though the
complete Swift source module compiles and runs in Simulator.

The remaining release blockers are a repeatable package build plus App Store
signing/provisioning for device/archive builds.

## Responsive Shelter verification — 2026-07-17

- Direct `swiftc` type-check passed for all 68 files in `App`, `Features`, and
  `Services`, targeting arm64 iOS Simulator 17.0 with the iOS 26.5 SDK.
- A full simulator executable was compiled from those same sources, ad-hoc signed in a
  temporary app bundle, installed, and launched on iPhone 17e.
- Standard and `accessibility-extra-extra-extra-large` screenshots were inspected for
  Home and Reset. The first accessibility pass exposed wrapping and control overflow;
  adaptive layouts were implemented and the corrected screenshots were recaptured.
- Responsive Shelter animation was recorded on iPhone 17e Simulator for Grounded Home,
  Luminous Home, and the breathing-clock-aligned Luminous Reset. Two Reduce Motion
  screenshots captured five seconds apart had identical SHA-256 hashes, confirming the
  rendered Home background was static under the Simulator accessibility setting.
- Shield remains independent of the Responsive Shelter field and retains manual,
  separate **Next support contact** and **Call** actions.
- `Scripts/validate_ios_project.sh` passed all static checks, including plist/privacy
  linting and the new theme, Reduce Motion, and static-Shield guards.
- `Scripts/validate_ios_project.sh --build` repeated the manifest-resolution blocker
  below during its optional `xcodebuild -list` probe.

Observed package-build blocker:

```text
Missing or empty JSON output from manifest compilation for anchor-buildweek.swiftpm
```

## Historical build probe — 2026-07-08

The historical result recorded that Static release-readiness validation passes in the
then-configured shell. The current 2026-07-17 limitations above supersede that claim
for this run.

### Completed

Command:

```bash
Scripts/validate_ios_project.sh --build
```

Result:

- Tooling detected: Xcode 26.6, Swift 6.3.3.
- Swift Playgrounds iOS manifest detected.
- `InfoPlist_Additions.plist` is valid.
- Production content checks passed.
- Store launch artifacts exist.
- Store copy consistency checks passed.
- Swift inventory currently finds 60 Swift files after release-surface cleanup.
- Static release-readiness checks passed.
- `xcodebuild -list` detects workspace `Anchor` and scheme `Anchor`.
- iOS Simulator build succeeded for `iPhone 17e, OS 26.5`.
- Simulator install succeeded.
- Simulator launch succeeded for bundle identifier `com.Ryunosuke.Anchor`.
- Screenshot capture succeeded to `anchor-simulator-check.png`.

### Remaining Blocker

Generic iOS device build currently fails because a matching provisioning profile is not available to command-line Xcode.

Observed blocker:

```text
No profiles for 'com.Ryunosuke.Anchor' were found:
Xcode couldn't find any iOS App Development provisioning profiles matching 'com.Ryunosuke.Anchor'.
```

This is expected until signing is configured in Xcode or command-line provisioning is allowed.

### Sandbox Probe

After the latest visual polish pass, a normal sandboxed Codex run can still complete static validation, but cannot access CoreSimulator or SwiftPM cache paths required for a fresh simulator build.

Observed sandbox blockers:

```text
CoreSimulatorService connection became invalid.
cannot open file '/Users/pario/Library/Caches/org.swift.swiftpm/.../anchor.swiftpm.dia'
Operation not permitted
```

These errors are environment-permission issues, not current evidence of app-code failure.

Running plain SwiftPM manifest inspection is not a reliable verifier for this project shape. With cache paths redirected to `/private/tmp`, `swift package dump-package` reaches manifest compilation but fails with:

```text
no such module 'AppleProductTypes'
```

That is expected for a Swift Playgrounds iOS application manifest outside the Xcode/Playgrounds build path. Use Xcode or `Scripts/anchor_simulator_loop.sh smoke` as the authoritative build verifier.

### UI Observation

The first launched screen showed onboarding in the prior elevated simulator run. Since then, the low-contrast negative example chips were updated, and the generated Anchor illustration was added to Home, Learn, and Journal. Recapture simulator screenshots after a fresh elevated build before submitting.

### Decision

Proceed with the current SwiftPM / Swift Playgrounds project for the immediate App Store attempt.

Switch to the native Xcode migration plan if:

- Xcode cannot archive the SwiftPM app even after signing is configured.
- App Store upload/signing is unreliable.
- Repeatable simulator automation becomes too awkward in the SwiftPM format.

See `NATIVE_IOS_MIGRATION_PLAN.md`.

## Next Human-In-The-Loop Check

Open `Anchor.swiftpm` in Xcode and try:

1. Select the Apple Developer team.
2. Enable automatic signing if needed.
3. Create or download a provisioning profile for `com.Ryunosuke.Anchor`.
4. Build a generic iOS/device target.
5. Archive.
6. Validate archive.
7. Upload to App Store Connect.

If the archive fails, capture the first concrete Xcode error and continue with the migration plan.
