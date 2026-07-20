# Anchor Today Submission Plan

Last updated: 2026-07-08

## Goal For Today

Submit Anchor to App Review today if the app can be archived and uploaded successfully.

Important distinction:

- Today goal: submit to App Review.
- Not fully controllable today: App Review approval and App Store release timing.

## Confirmed Product Decisions

- Launch scope: worldwide.
- Language for first submission: English-first unless localization is completed immediately.
- Device scope: iPhone-only for v1 to keep screenshot and QA requirements focused.
- Positioning: panic-time communication aid.
- Concept: diversity, mutual support, "One for all. All for one."
- Monetization: cautious partial monetization later; keep v1 core support flow free.
- No in-app ads for v1.

## Highest App Review Risks

1. Medical/mental-health claims.
   - Mitigation: say communication aid, not treatment/diagnosis.
2. Emergency-service replacement confusion.
   - Mitigation: include clear limitation notes in metadata, app review notes, and privacy policy.
3. Background audio / Now Playing behavior.
   - Mitigation: explain in App Review notes that it supports the Lock Screen card.
4. Sensitive local data.
   - Mitigation: privacy policy says local storage, no account, no server upload.
5. SwiftPM / Swift Playgrounds archive friction.
   - Mitigation: try archive first; if blocked, migrate using `NATIVE_IOS_MIGRATION_PLAN.md`.

## Existing Screenshot Inventory

Existing folder:

```text
../ScreenShout_AnchorVer_1.0
```

Current inventory:

- 41 PNG screenshots.
- All detected as `1170x2532`.
- Captured from iPhone 16e simulator on 2026-03-25.

Use these only if the UI still matches current copy. Because the app copy changed from Emergency Contact to Support Contact, screenshots showing old text should be replaced.

## Submission Checklist

### Code / Build

- [x] Run `Scripts/validate_ios_project.sh`.
- [x] Run `Scripts/validate_ios_project.sh --build` (static checks passed; the
      sandboxed optional probe warning was separately cleared with normal Xcode access).
- [x] Record the final Xcode build/archive probes in `BUILD_PROBE_RESULTS.md`.
- [x] Build the Release configuration for iOS Simulator.
- [x] Install and launch the Release build in iOS Simulator.
- [x] Configure development signing/provisioning for `com.Ryunosuke.AnchorBuildWeek`.
- [x] Build for generic iOS device.
- [x] Archive with Apple Development signing for physical-device verification.
- [ ] Re-archive with App Store distribution signing.
- [ ] If archive fails because of SwiftPM format, migrate using `NATIVE_IOS_MIGRATION_PLAN.md`.
- [ ] Upload the distribution-signed build to App Store Connect.

### App Store Connect

- [ ] Create/update app record.
- [ ] Set worldwide availability.
- [ ] Set app category, likely Lifestyle for v1.
- [ ] Add age rating.
- [x] Prepare age rating answers in `AGE_RATING_ANSWERS.md`.
- [ ] Add privacy policy URL.
- [x] Prepare static privacy policy HTML in `StoreWeb/privacy.html`.
- [x] Prepare static support page HTML in `StoreWeb/support.html`.
- [x] Prepare hosting guide in `STORE_WEB_HOSTING_GUIDE.md`.
- [x] Prepare App Privacy answers in `APP_PRIVACY_ANSWERS.md`.
- [ ] Enter App Privacy details in App Store Connect.
- [ ] Add support URL.
- [ ] Add screenshots.
- [ ] Add description, subtitle, keywords, promotional text.
- [ ] Add App Review notes.

### Screenshots

Minimum desired story:

1. Home / Deploy Shield
2. Studio / prepare support card
3. Shield / large readable card
4. QR / scan without internet
5. Support Contact
6. Journal or Learn

Because v1 is iPhone-only, capture iPhone screenshots only for today's submission path.

Screenshot captions should avoid treatment claims:

- Prepare before words are hard
- Show what helps during panic
- Share support instructions by QR
- Keep a trusted support contact close
- Reflect privately after hard moments
- Learn calm ways to support someone

### App Review Notes

Use the draft in `APP_STORE_METADATA_DRAFT.md`.

Must mention:

- Panic-time communication aid.
- Not medical advice, diagnosis, treatment, monitoring, or emergency service replacement.
- Contacts access is optional.
- Data is local.
- Background audio / Now Playing supports Lock Screen card visibility.

### Monetization

For fastest v1 submission:

- [ ] No in-app purchases unless already configured and verified.
- [ ] Keep core features free.
- [ ] Add monetization after approval in a later version.

## Competitor / Adjacent App Notes

Known adjacent categories:

- Panic/anxiety self-help and breathing apps.
- SOS/panic-button apps that message contacts.
- AAC / non-speaking communication apps.
- Medical ID / emergency QR information tools.

Anchor should not claim uniqueness based on there being no adjacent apps. Instead, position around its specific combination:

- Panic-time prepared support card.
- QR instructions.
- Lock Screen card.
- Trusted support contact.
- Calm supporter guidance.
- Local-first, account-free setup.

## Go / No-Go

Go today if:

- Static validation passes.
- Archive/upload succeeds.
- Screenshots match current UI.
- Privacy policy URL and support URL are ready.
- App Review notes are complete.

No-go today if:

- App cannot archive/upload.
- Screenshots show outdated Emergency Contact copy.
- Privacy policy URL is not publishable.
- A core flow crashes on device.
