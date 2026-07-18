# Anchor Product Requirements

Last updated: 2026-07-18

## Launch Decision

Anchor v1 will launch globally as a panic-time communication aid.

For the first public release, Anchor is iPhone-only. iPad support should be revisited after the iPhone release is approved and larger layouts can be verified carefully.

The product concept is diversity and mutual support:

> One for all. All for one.

Anchor should help people prepare short, clear support instructions before a panic or overwhelm moment happens, so nearby people can understand how to help without forcing the user to explain everything in the moment.

## Positioning

Primary positioning:

- Panic-time communication aid
- Prepared support card
- QR-based support instructions
- Trusted support contact
- Calm communication and reflection tools

Do not position as:

- Medical device
- Diagnosis tool
- Treatment tool
- Panic attack cure
- Emergency service replacement
- Guaranteed safety product

## Target Users

Primary users:

- People who may find it difficult to speak, decide, or explain what they need during panic, anxiety, sensory overload, shutdown, or emotional overwhelm.

Secondary users:

- Friends, family, partners, classmates, coworkers, staff, or nearby supporters who want to help calmly and respectfully.

## Global Launch Notes

Anchor will be prepared for worldwide availability, but the first public version should stay English-first unless localization is completed before submission.

Global risk areas:

- Medical and emergency-service claims vary by region.
- Mental health apps can receive heightened review scrutiny.
- Some countries may be sensitive to emergency, health, or safety claims.
- Accessibility and diversity positioning should be respectful and not imply a protected group is dangerous, helpless, or defined by a condition.
- Privacy wording must be clear because the app can store sensitive support text, journal entries, and contact information locally.

## Competitive / Adjacent Landscape

Anchor overlaps with several categories but should avoid copying their positioning:

- Panic/anxiety apps: breathing, grounding, self-help, CBT-style tools.
- SOS/panic-button apps: sending alerts, location, or messages to contacts.
- AAC apps: communication support for non-speaking users.
- Medical ID / ICE / QR info tools: showing medical or emergency information.

Anchor's differentiator:

- Prepared communication card for panic or overwhelm moments.
- QR support instructions that work without internet.
- Lock Screen visibility through Now Playing while Shield is active.
- Supporter guidance that emphasizes calm, consent, dignity, and low cognitive load.
- Local-first storage and no account requirement.
- A deliberately prepared AI voice that remains optional and never makes Shield depend
  on a network connection.

## Monetization Direction

Anchor should not feel exploitative or gated during a sensitive moment.

Recommended v1 monetization stance:

- Free core crisis/panic-time communication function.
- No ads inside the app.
- No paywall in front of Shield, QR, basic support card, or support contact.
- Consider paid optional features later:
  - Additional Shield themes
  - More saved versions/history
  - Export/print packs
  - Advanced customization
  - Supporter education packs
  - Optional donation / supporter plan

Avoid:

- Charging during urgent use.
- Blocking prepared support instructions behind a paywall.
- Monetizing by selling sensitive data or adding third-party advertising SDKs.
- Making medical outcome claims to justify pricing.

## Today Launch Strategy

Because the desired launch timeline is today, the fastest realistic path is:

1. Finalize release-safe positioning and metadata.
2. Run static validation.
3. Build/archive in Xcode or migrate only if SwiftPM format blocks archive/upload.
4. Upload to App Store Connect.
5. Use existing screenshots if they still match the current UI; otherwise capture the minimum required set.
6. Submit for review with detailed App Review notes.
7. Delay paid features until after v1 is approved unless already implemented and verified.

## v1 Must-Haves

- Shield support card works.
- QR card works.
- Support contact works manually.
- Contacts permission is optional.
- Journal starts empty.
- No demo data.
- No account required.
- Privacy policy published.
- AI voice is disclosed, generated only after an explicit calm-state action, and cached
  before Shield can use it.
- The OpenAI API key is isolated behind a production HTTPS proxy and is never bundled in
  the iOS application.
- App Review notes explain limitations and background audio / Now Playing.
- Metadata and screenshots match the app.
- No claims that Anchor treats, diagnoses, prevents, or stops panic attacks.

## v1 Nice-To-Haves

- Japanese localization.
- Additional languages for global launch.
- Paid optional customization.
- More polished screenshot captions.
- Native Xcode project migration for stronger automation.

## Open Questions

- Exact price model after v1 approval.
- Whether to launch English-only globally or add Japanese before submission.
- When to reintroduce iPad support after the first iPhone release.
- Whether to mention Lock Screen / Now Playing in public metadata or only in App Review notes.
- Whether to keep the app category as Lifestyle or Health & Fitness.
