# Anchor App Store Connect Runbook

Last updated: 2026-07-08

## App Record

- Platform: iOS
- Name: Anchor
- Bundle ID: `com.Ryunosuke.Anchor`
- SKU: `anchor-ios`
- Version: `1.0`
- Device support: iPhone
- Availability: worldwide
- Primary category: Lifestyle
- Price: Free for v1

## Build

Upload an archive built from:

- Marketing version: `1.0`
- Build number: `2`
- Team ID: `V7F5K95K4G`

If Xcode archive fails because of the SwiftPM / Swift Playgrounds project format, follow `NATIVE_IOS_MIGRATION_PLAN.md`.

## URLs

Publish the files in `StoreWeb/`, then enter:

- Privacy Policy URL: public URL for `privacy.html`
- Support URL: public URL for `support.html`
- Marketing URL: optional for v1

## Metadata

Use `APP_STORE_METADATA_DRAFT.md`.

Recommended fields:

- Subtitle: `Prepared support for hard moments`
- Promotional text: `Prepare a clear support card, QR message, trusted contact, breathing session, and private journal before a stressful moment happens.`
- Keywords: `support card,panic communication,overwhelm support,anxiety support,breathing,grounding,journal,support contact,QR card,calm`

## App Privacy

Use `APP_PRIVACY_ANSWERS.md`.

Recommended v1 answer:

- Data collection: Data Not Collected
- Tracking: No

Only use this if the submitted build still has:

- No analytics
- No ads
- No external network calls
- No account system
- No server sync
- No photo save/access
- `PrivacyInfo.xcprivacy` included in the submitted app bundle
- Settings includes Clear Local Data for on-device Shield, journal, contact, history, and preference data

## Additional Compliance Answers

Use these only if the submitted build still matches the current v1 scope.

- Advertising Identifier: No
- Third-party advertising SDKs: No
- Tracking: No
- Sign in required: No
- User-generated public content: No
- In-app purchases: No for v1
- Push notifications: No for v1
- Location access: No
- Camera access: No
- Microphone access: No
- Photo Library access: No
- Custom encryption: No custom encryption added by Anchor

For Export Compliance, answer according to the exact App Store Connect questionnaire shown at submission time. Current v1 code does not add custom cryptography or external networking.

## Age Rating

Use `AGE_RATING_ANSWERS.md`.

Anchor mentions panic and overwhelm but does not provide medical diagnosis, treatment, or emergency response.

## Screenshots

Use new iPhone screenshots captured after rebuilding the latest UI.

Minimum sequence:

1. Home
2. Studio
3. Shield
4. QR
5. Support Contact
6. Learn or Journal with the refreshed illustration panel

Do not use screenshots that show:

- `Emergency Contact`
- `Emergency Mode`
- `Panic Attack`
- `Autism Meltdown`
- `Dissociation`

## App Review Notes

Use the App Review Notes section in `APP_STORE_METADATA_DRAFT.md`.

Make sure notes explain:

- Anchor is a communication aid.
- Anchor is not medical advice, diagnosis, treatment, monitoring, or emergency service replacement.
- Contacts access is optional.
- Data is local-first in v1.
- Background audio / Now Playing supports the Lock Screen Shield card.

Paste-ready notes:

```text
Anchor is a personal preparation and communication aid. It lets users prepare a short support card and QR message that can be shown to someone nearby when explaining their needs is difficult.

Anchor does not diagnose, treat, monitor, measure, or replace emergency services. It does not provide medical advice. If a user is in immediate danger, they should contact local emergency services or a trusted person nearby.

Contacts access is optional and is used only when the user chooses a trusted support contact. The selected contact is stored locally on device. Journal entries and Shield card content are also stored locally on device. Anchor does not require an account and does not send this information to a server.

While Shield is active, Anchor uses audio background mode / Now Playing so the prepared Lock Screen card can remain visible and navigable from the Lock Screen. The audio is not user-facing content; it supports the Lock Screen card experience.
```

## Final Pre-Submit Gate

Submit only after:

- `Scripts/validate_ios_project.sh` passes.
- A fresh build/archive succeeds.
- Latest UI screenshots are captured.
- Privacy and support URLs are live.
- App Privacy answers match the submitted build.
- Review notes match the submitted build.
