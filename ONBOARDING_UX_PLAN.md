# Anchor Onboarding UX Plan

Last updated: 2026-07-08

## Direction

Anchor's first-run experience should feel calm, useful, and inclusive. The onboarding must explain that Anchor is a panic-time communication aid without presenting itself as diagnosis, treatment, emergency rescue, or medical care.

## Dribbble-Informed Candidate Directions

Reference searches:

- https://dribbble.com/search/onboarding%20mental%20health%20app
- https://dribbble.com/search/wellness%20app%20onboarding
- https://dribbble.com/search/breathing%20app%20onboarding

Chosen direction:

- Soft 3D wellness illustrations with tactile, warm materials.
- Large image-led pages with short localizable UI copy outside the image.
- Calm progress pips and one primary action per step.
- Gentle spring/float motion, with Reduce Motion respected.

Rejected direction:

- Heavy crisis simulation.
- Text embedded inside illustrations.
- Medical, emergency, alarm, hospital, or diagnosis-coded visuals.
- Mascot-heavy experiences that could feel too playful for a sensitive context.

## Flow

1. A steady place
   - Purpose: explain that Anchor helps when speaking is hard.
   - Image: a woman and a man grounded safely in separate protective bubbles.

2. Prepared words
   - Purpose: show that the user prepares a support card in advance.
   - Image: a generated phone-in-hands illustration with the Shield screen integrated into the phone.

3. Support handoff
   - Purpose: connect the app to diversity and mutual support.
   - Image: diverse hands holding an anchor compass together.

4. Make it reachable
   - Purpose: let the user add a support contact and set quick access.
   - Image: same support visual with native setup actions layered in SwiftUI.

## Generated Assets

All generated onboarding images are intentionally text-free so they can be reused across localizations.

- `Assets.xcassets/OnboardingGrounded.imageset/OnboardingGrounded.png`
- `Assets.xcassets/OnboardingPrepared.imageset/OnboardingPrepared.png`
- `Assets.xcassets/OnboardingTogether.imageset/OnboardingTogether.png`

Constraints used for generation:

- No text, letters, numbers, logos, or watermarks.
- No medical cross, siren, hospital, alarm, or emergency iconography.
- Calm cream, pale mint, muted teal, soft blue, and warm coral palette.

## Implementation Notes

- `SetupWizardView` now uses a page-based SwiftUI onboarding flow.
- Each onboarding page is constrained to a single non-scrolling screen.
- Text remains outside generated images for localization.
- The second page uses the selected generated image with the Shield screen integrated into the phone, matching the requested app-story visual direction.
- Motion uses spring page transitions, floating image motion, animated progress pips, and pressed card feedback.
- `accessibilityReduceMotion` disables decorative motion.
- Final step keeps useful setup actions: support contact and Quick Access.
