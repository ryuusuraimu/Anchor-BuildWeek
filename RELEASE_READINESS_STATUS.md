# Anchor Build Week Release Readiness

Last updated: 2026-07-18

## Current Status

The Build Week app is a **code- and simulator-verified release candidate**. The active
three-tab experience, Human Signal visual system, preparation flow, static Shield,
Support Relay, QR, contact editing, Reset, and optional Aftercare are implemented.
Selectable OpenAI speech is implemented behind a key-isolating VoiceProxy and prepared
for offline Shield playback, but live voice generation is blocked by API quota.

This status does not claim public-release completion: physical-device accessibility,
Release signing/archive, and a complete manual interaction pass remain outside the
current simulator evidence.

## Completed

- Rebuilt Home around one editorial message and one dominant Shield action.
- Added the native Human Signal Canvas field for the light Home surface.
- Refined Reset into a breath-synchronized dark field with pause/resume and two
  Reset-only atmospheres.
- Rebuilt Prepare as a five-question, one-at-a-time flow with an editorial completion
  review.
- Rebuilt the trusted-person editor without card-heavy or medical visual language while
  preserving existing persistence and Contacts selection.
- Rebuilt Aftercare as a skippable, private body-state check-in with direct Shield
  fallback.
- Preserved Shield as a static, deterministic, offline support card.
- Added 13 selectable OpenAI voices, calm-state preview/preparation, local AAC caching,
  and immediate iOS device-voice fallback when no prepared file exists.
- Kept the OpenAI key outside the app and limited networking to the calm-state prepared
  voice library; Shield itself performs no request.
- Preserved hold-to-close, read aloud, QR, brightness/screen-awake behavior, Practice,
  and manual multi-contact Support Relay.
- Kept legacy Learn, Journal, and Studio source compiled for compatibility but outside
  the active Build Week navigation.
- Added stable debug routes for reproducible screenshot states without writing review
  data to saved contacts.
- Updated the README and Build Week design record to the final Human Signal direction.

## Verification Performed

- `xcrun swift-format lint --strict` passed for every Swift file changed in the final
  pass.
- `Scripts/validate_ios_project.sh` passed all static release-readiness checks on
  2026-07-18.
- `xcodebuild -scheme AnchorBuildWeek` succeeded for the iOS Simulator target
  `2B3DE9BF-5CDC-4BF5-BB73-8EB3FA184545`.
- Standard-size visual review completed for Home, Reset, Prepare, contact editing,
  Aftercare, Reset atmosphere selection, Shield, and QR.
- Shield state review completed for no contact, multi-contact relay, long prepared copy,
  and QR.
- Maximum Dynamic Type review completed for Prepare completion, contact editing,
  Aftercare, Shield Relay, long-copy Shield, and Voice & reading.
- VoiceProxy contract tests passed. A live request reached OpenAI and was authenticated,
  but returned `insufficient_quota` before audio could be generated.
- Reduce Motion debug verification produced identical full-PNG pairs for Home and the
  paused Reset.

Reviewed images are listed in `BUILD_WEEK_DESIGN_NOTES.md` and the four primary screens
appear in `README.md`.

## Known Warning

Xcode reports one non-blocking warning:

```text
Skipping duplicate build file in Compile Sources build phase: Assets.xcassets
```

The Swift Playgrounds-generated package still builds successfully. Because
`Package.swift` is marked auto-generated, this warning was recorded instead of applying
a fragile manual manifest rewrite.

## Release Blockers

1. Run on a physical iPhone and verify touch reachability, phone handoff, speech, QR
   scanning, brightness restoration, and screen-awake restoration.
2. Perform a complete VoiceOver listening-order and action pass; screenshots cannot
   verify spoken order or announcements.
3. Configure Release signing, archive, and confirm installation from the archived build.
4. Complete a manual persistence pass: add/reorder/edit contacts, relaunch, edit Shield
   copy, save Aftercare, and clear local data.
5. Initialize or copy this source into the submission Git repository; the current
   `Anchor-BuildWeek.swiftpm` folder is not itself a Git working tree.
6. Record the sub-three-minute demo and complete the Devpost submission evidence.
7. Add API billing or raise the project usage limit, deploy VoiceProxy behind HTTPS with
   rate limiting and app/device attestation, then verify Cedar AAC generation and offline
   Shield playback on a physical iPhone.

## Recommended Next Action

Resolve the OpenAI API quota and perform the physical-iPhone voice/offline playback
check before recording the final Build Week demo.
