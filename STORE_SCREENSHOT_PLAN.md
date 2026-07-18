# Anchor Store Screenshot Plan

Last updated: 2026-07-08

## Decision

Do not use the current screenshot set as-is for the v1 worldwide submission.

The existing screenshots are visually strong and have the correct iPhone portrait size, but they were captured before the launch copy pass. At least two reviewed screenshots still show outdated language:

- `Emergency Contact`
- `Panic Attack`
- `Autism Meltdown`

Those are now intentionally removed from the app UI for App Review and global launch safety.

## Existing Inventory

Folder:

```text
../ScreenShout_AnchorVer_1.0
```

Observed:

- 41 PNG files.
- iPhone portrait screenshots.
- Size detected earlier: `1170x2532`.
- Captured from iPhone 16e simulator on 2026-03-25.

## Required Recapture Set

Capture at least 6 iPhone screenshots after rebuilding the latest app copy:

1. Home
   - Show Shield readiness and support contact readiness.
   - Avoid any old `Emergency Contact` label.
2. Studio
   - Show editable panic/overwhelm support instructions.
   - Use softer chips such as `Panicking`, `Overwhelmed`, `Need quiet`, `Cannot speak clearly`.
3. Shield
   - Show the large readable support card.
   - Prefer text that says panic or overwhelm without claiming treatment.
4. QR
   - Show QR sharing for support instructions.
   - Use `Shield Mode`, not `Emergency Mode`.
5. Support Contact
   - Show trusted support contact setup.
   - Use `Support Contact`, not `Emergency Contact`.
6. Learn or Journal
   - Show calm supporter guidance or private reflection.
   - Avoid medical claims.
   - Prefer the refreshed screens that include the `AnchorCalmIllustration` visual panel.

## Capture Helper

After the latest build is installed and the simulator is showing the target screen, save named screenshots with:

```bash
Scripts/anchor_simulator_loop.sh store-shot home
Scripts/anchor_simulator_loop.sh store-shot studio
Scripts/anchor_simulator_loop.sh store-shot shield
Scripts/anchor_simulator_loop.sh store-shot qr
Scripts/anchor_simulator_loop.sh store-shot support-contact
Scripts/anchor_simulator_loop.sh store-shot learn
```

Screenshots are saved to:

```text
StoreScreenshots/
```

## Visual Asset Direction

The app now includes a generated calm illustration asset:

```text
Assets.xcassets/AnchorCalmIllustration.imageset/AnchorCalmIllustration.png
```

Use this style for preparation, learning, reflection, and store creative.

Do not add decorative images to the active Shield card unless they clearly improve readability. During panic or overwhelm, text clarity remains the primary UX requirement.

## iPad

Anchor v1 is iPhone-only to keep screenshot and QA requirements focused for the first public release.

Revisit iPad support after the first iPhone release is approved and larger layouts can be checked carefully.

## Caption Direction

Use captions that describe communication support, not symptom treatment:

- Prepare before words are hard
- Show what helps during panic
- Share support instructions by QR
- Keep a trusted support contact close
- Reflect privately after hard moments
- Learn calm ways to support someone

Avoid:

- Stop panic attacks
- Treat anxiety
- Cure panic
- Emergency replacement
- Medical ID alternative

## Same-Day Shortcut

If a full recapture is not possible today:

1. Review all 41 existing screenshots manually.
2. Use only screenshots with no outdated sensitive text.
3. Prioritize Home/Shield/QR/Learn if their text is clean.
4. Replace the full set in the next TestFlight/App Review pass.

This is a fallback only. The preferred path is to recapture after the current code changes.
