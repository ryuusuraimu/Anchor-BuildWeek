# Anchor Build Week — Human Signal design

Last updated: 2026-07-18

This folder is an independent Build Week copy. The original `Anchor.swiftpm` project is
unchanged by this redesign.

## Central idea

Anchor has two visual states with different responsibilities:

- **Shelter** is the calm, expressive space used while the person is preparing or
  recovering.
- **Signal** is the static, high-contrast Shield handed to another person when words
  are difficult.

The shared signature is one translucent, folded **Human Signal** membrane. It is not a
logo, medical illustration, orb, mascot, or decorative dashboard object. On Home it
enters from outside the right edge so the reading area stays quiet. On Reset it becomes
deeper and darker. It never appears in Shield.

## Final screen system

### Home

- One editorial sentence: **You have a way to ask.**
- One dominant action: **Open Shield**.
- Reset and Prepare appear as two quiet rows below the primary action.
- The three-dot menu contains only secondary actions: Check in and Reset atmosphere.
- The light native Canvas membrane drifts over 32 seconds and responds subtly to Shield
  button engagement.
- Reduce Motion replaces the timeline with one deterministic still.

### Reset

- A two-minute breathing clock drives one eight-second in/out rhythm.
- Pause freezes the timer and the current membrane phase; resuming continues from that
  point.
- Shield remains reachable from the header without ending the Reset.
- Grounded and Luminous are Reset atmospheres only. Home remains light and Shield stays
  static and high contrast.

### Prepare

- One question at a time, five prompts, no chatbot transcript or advanced editor.
- A thin line communicates progress without percentage pressure.
- Suggested answers are flat editorial choices rather than competing cards.
- Completion shows the complete support card at realistic density with two actions:
  practice or edit.
- The trusted-person editor uses the same warm surface, serif question hierarchy, and
  local-privacy language.

### Shield

- Warm near-black background, ivory text, one coral signal line.
- The first message dominates; Safety precedes What helps and Please avoid.
- Close, Read aloud, and QR are always visible utilities.
- Support Relay appears only when a callable or recoverable contact action exists.
- **Next contact** is separate from the large **Call** button. There is no automatic
  contact cycling and practice cannot open a phone URL.
- QR works offline, contains the prepared guidance, and excludes phone numbers.
- No AI, network request, microphone capture, automatic decision, gradient, glass,
  theme, or decorative animation is loaded by Shield.

### Aftercare

- Optional Home sheet; never a tab, gate, streak, or required task.
- **I still need my Shield** stays prominent.
- Three plain-language body states replace medical gauges and ECG imagery.
- One optional sentence can be saved locally through `JournalStorage`.
- The person may close without recording anything.

## Accessibility contract

- Crisis call action: 72 pt minimum height.
- Shield utilities: 48 pt minimum target; other controls: 44 pt minimum target.
- Shield uses capped display type for the headline while actionable copy follows Dynamic
  Type.
- Accessibility sizes remain scrollable and keep the active Support Relay action fixed.
- Closing Shield requires a 1.5-second hold for touch, with a standard VoiceOver
  accessibility action so the gesture is not mandatory.
- Read aloud detects the prepared-text language instead of forcing an English voice.
- Meaning is never encoded by color alone.
- Home, Reset, Prepare, contact editing, and Aftercare remain usable at
  `accessibility-extra-extra-extra-large`.
- Shield is static, deterministic, and offline-capable at every text size.

## Storage and safety boundary

Existing keys and data models remain compatible, including `shield_config_v3` and
`anchor.supportContacts.v2`. The Build Week contact editor preserves the existing
multi-contact ordering and persistence semantics. Debug screenshot scenarios inject
review data in memory and do not overwrite saved contacts.

AI support remains a future calm-time extension. It is not part of this release
candidate and must never become a dependency of Shield.

## Reviewed screenshot set

Primary screens:

- `BuildWeekScreenshots/v25-home-final.png`
- `BuildWeekScreenshots/v25-reset-final.png`
- `BuildWeekScreenshots/v25-shield-final.png`
- `BuildWeekScreenshots/v25-prepare-final.png`

Secondary screens:

- `BuildWeekScreenshots/v23-contact-editor.png`
- `BuildWeekScreenshots/v23-aftercare-selected.png`
- `BuildWeekScreenshots/v23-aftercare-saved.png`
- `BuildWeekScreenshots/v23-reset-atmosphere.png`

Shield matrix:

- `BuildWeekScreenshots/v24-shield-no-contact.png`
- `BuildWeekScreenshots/v24-shield-relay.png`
- `BuildWeekScreenshots/v24-shield-long-copy.png`
- `BuildWeekScreenshots/v24-shield-qr.png`
- `BuildWeekScreenshots/v24-shield-relay-axxxl.png`
- `BuildWeekScreenshots/v24-shield-long-copy-axxxl.png`

Dynamic Type and Reduce Motion:

- `BuildWeekScreenshots/v23-contact-editor-axxxl.png`
- `BuildWeekScreenshots/v23-aftercare-selected-axxxl.png`
- `BuildWeekScreenshots/v25-home-reduce-motion-a.png`
- `BuildWeekScreenshots/v25-home-reduce-motion-b.png`
- `BuildWeekScreenshots/v25-reset-reduce-motion-a.png`
- `BuildWeekScreenshots/v25-reset-reduce-motion-b.png`

The paired Home stills have identical complete PNG SHA-256 hashes:
`bb103124bc73d09778b361413e25fb0eecf8ded5e04ab8249fd809abe68ddb43`.
The paired paused Reset stills also match:
`2b6c6fb0e610a19a628c9ec1d3046bab9a15e2c8267a4c927e30acc9fbfa21e4`.

## Debug review routes

Debug builds can open key screens with `-showHome`, `-showShield`, `-showPrepare`,
`-showAftercare`, `-showReset`, `-showThemePicker`, and `-showContactEditor`.
Use `-showPrepare -showPrepareComplete` for the final Prepare state.

Shield states use `-showShield -shieldScenario` with `no-contact`, `one-contact`,
`relay`, `invalid-phone`, `long-copy`, `practice`, or `qr`. These routes are excluded
from release builds by `#if DEBUG`.

## Verification boundary

`Scripts/validate_ios_project.sh` statically guards the three-tab route, optional
Aftercare, local save, contact editor, VoiceOver close action, language-aware speech,
manual Support Relay, motion suspension, Reduce Motion, breathing-clock alignment, and
Shield's strict separation from decorative rendering.

Simulator screenshots and a Debug simulator build are complete. Physical-device touch,
VoiceOver listening order, Release signing/archive, and user testing remain external
release gates.
