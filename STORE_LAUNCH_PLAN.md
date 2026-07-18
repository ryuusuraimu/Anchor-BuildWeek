# Anchor Store Launch Plan

Last updated: 2026-07-08

## Goal

Anchor を App Store で公開できる品質まで仕上げ、公開後に Apple Ads などで初期広告を開始する。

## Product Positioning To Confirm

- Primary positioning: panic-time communication aid and prepared support card.
- Avoid positioning as: medical device, diagnosis tool, treatment, emergency service replacement, or guaranteed safety tool.
- Launch markets: worldwide.
- Launch languages: English-first.
- Pricing: free core v1; monetization later.
- First public version target: App Review submission as soon as archive/upload is ready.
- Device scope: iPhone-only for v1.

## App Readiness

- [ ] Run `Scripts/validate_ios_project.sh`.
- [ ] Confirm the first public feature set.
- [ ] Confirm whether Japanese localization is required for v1.
- [ ] Verify the first-launch flow on a real iPhone.
- [ ] Verify Shield card behavior while the phone is locked.
- [ ] Verify contact picking and manual contact editing.
- [ ] Verify QR generation and scanning from another device.
- [ ] Verify journaling starts empty for new users.
- [ ] Verify no debug/sample data appears in the production build.
- [ ] Verify all user-facing health or safety copy avoids diagnosis/treatment claims.
- [ ] Confirm whether Lock Screen / Now Playing behavior should remain in v1.

## App Review Risk Notes

- Anchor stores contact and journal information locally with UserDefaults.
- Contacts permission is optional and used only to choose a trusted support contact.
- Background audio mode is used for the Shield Lock Screen card via Now Playing.
- Shield is a prepared communication aid. It is not an emergency service, medical device, diagnosis tool, or treatment tool.
- If a user is in immediate danger, the app should direct them to local emergency services or a trusted person nearby.

## App Store Connect Assets

- [ ] App name.
- [ ] Subtitle.
- [ ] Promotional text.
- [ ] Description.
- [ ] Keywords.
- [ ] Support URL.
- [ ] Marketing URL, optional.
- [ ] Privacy Policy URL.
- [ ] App Review notes.
- [ ] Screenshots for required iPhone sizes.
- [ ] iPhone screenshots from the rebuilt v1 app.
- [ ] App privacy details.
- [ ] Age rating.
- [ ] Category and secondary category.

## Suggested Store Metadata Draft

### Subtitle

Prepared support cards for hard moments

### Short Description

Anchor helps you prepare simple support instructions, a QR card, a trusted contact, breathing support, and reflection tools before a stressful moment happens.

### Review Notes Draft

Anchor is a personal preparation and communication aid. It helps users prepare short support instructions and a QR card that can be shown to someone nearby. It does not diagnose, treat, monitor, or replace emergency services.

Contacts access is optional and only used when the user chooses a trusted support contact. The selected contact is saved locally on device.

The app uses background audio/Now Playing while Shield is active so the prepared card can remain visible from the Lock Screen. The audio is not user-facing content; it supports the Lock Screen card experience.

## Privacy Checklist

- [ ] Confirm no third-party analytics SDKs are present.
- [ ] Confirm no network data collection is present.
- [ ] Publish a Privacy Policy page.
- [ ] App Privacy: declare Contacts only if App Store Connect requires it for optional contact selection.
- [ ] App Privacy: declare local journal/contact storage behavior in the policy.

## TestFlight / Release Flow

- [ ] Run `Scripts/validate_ios_project.sh --build` or equivalent XcodeBuildMCP/Xcode verification.
- [ ] If SwiftPM / Swift Playgrounds format blocks reliable archive or upload, migrate using `NATIVE_IOS_MIGRATION_PLAN.md`.
- [ ] Archive with release signing.
- [ ] Upload build to App Store Connect.
- [ ] Complete TestFlight internal testing.
- [ ] Run at least one real-device smoke test.
- [ ] Submit to App Review.
- [ ] Prepare response for likely background audio / health-safety questions.

## Ads Launch

- [ ] Confirm app positioning and target keywords after store metadata is final.
- [ ] Start with Apple Ads search intent campaigns.
- [ ] Initial keyword themes: panic communication, panic support card, overwhelm support, anxiety support, support contact, safety card, breathing, grounding.
- [ ] Avoid ad copy that claims medical outcomes or emergency protection.
- [ ] Measure installs, product page conversion, and retention before scaling.
