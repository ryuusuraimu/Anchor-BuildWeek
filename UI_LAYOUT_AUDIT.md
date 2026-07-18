# Anchor Build Week UI Layout Audit

Last updated: 2026-07-18

## Scope

This audit covers every surface reachable from the active Build Week route:

- Home and its Check in / Reset atmosphere sheets
- Reset
- Shield, Support Relay, and QR
- Prepare completion and trusted-person editing

Legacy Studio, Learn, Journal, and older settings views remain compiled for data and
source compatibility but are not reachable from the three-tab navigation.

Historical note: the original visible simulator build is stale and its older screenshots
must not be used as evidence for the current Build Week interface.

## Final Findings

### Home

- The primary hierarchy is unambiguous: one editorial message, one Shield action, two
  quiet utilities.
- The membrane stays outside the left reading field and does not look like a tappable
  object.
- The bottom navigation remains distinct from content without floating over an active
  control.
- The three-dot menu is the correct place for low-frequency Aftercare and Reset
  atmosphere choices.

### Reset

- Timer, breathing instruction, Shield escape, Pause, and End session fit one standard
  iPhone viewport.
- Motion follows the breathing clock and freezes while paused.
- The dark atmosphere is clearly separated from the light Home surface.
- Reset atmosphere copy now states that Home and Shield do not change.

### Prepare

- One-question pacing prevents a dense form from becoming the default experience.
- The completion view preserves the whole support-card hierarchy and keeps Practice and
  Edit actions fixed above the tab bar.
- The trusted-person editor is naturally scrollable at standard and maximum Dynamic
  Type; Cancel and Save remain available in the sheet header.

### Aftercare

- The former medical-gauge/ECG presentation was removed.
- Direct Shield fallback precedes the body-state choices.
- Three choices form one continuous list rather than three competing cards.
- The note is optional and the sheet can be dismissed without saving.

### Shield

- Standard prepared copy fits in one viewport with no relay contact.
- Multi-contact Relay keeps Call and Next separate in a fixed lower dock.
- No-contact mode exposes no public setup warning or disabled-looking call control.
- Long-copy mode remains scrollable without changing Shield's static design.
- QR is large, high contrast, offline, and explicitly excludes phone numbers.
- At maximum Dynamic Type, fixed Support Relay actions remain reachable while the
  prepared instructions scroll behind the dock.

## Reviewed Evidence

Primary set:

- `BuildWeekScreenshots/v25-home-final.png`
- `BuildWeekScreenshots/v25-reset-final.png`
- `BuildWeekScreenshots/v25-shield-final.png`
- `BuildWeekScreenshots/v25-prepare-final.png`

Supporting set:

- `BuildWeekScreenshots/v23-contact-editor.png`
- `BuildWeekScreenshots/v23-aftercare-selected.png`
- `BuildWeekScreenshots/v23-aftercare-saved.png`
- `BuildWeekScreenshots/v23-reset-atmosphere.png`
- `BuildWeekScreenshots/v23-contact-editor-axxxl.png`
- `BuildWeekScreenshots/v23-aftercare-selected-axxxl.png`
- `BuildWeekScreenshots/v24-shield-no-contact.png`
- `BuildWeekScreenshots/v24-shield-relay.png`
- `BuildWeekScreenshots/v24-shield-long-copy.png`
- `BuildWeekScreenshots/v24-shield-qr.png`
- `BuildWeekScreenshots/v24-shield-relay-axxxl.png`
- `BuildWeekScreenshots/v24-shield-long-copy-axxxl.png`

## Unverified by Screenshots

- VoiceOver spoken order, labels, hints, and close announcement
- Physical-device phone and QR handoff
- Brightness and screen-awake restoration after every dismissal path
- Persistence after a full add/edit/reorder/relaunch sequence
- Small-device behavior below the reviewed simulator viewport

These are release QA gates, not claims made from visual evidence.
