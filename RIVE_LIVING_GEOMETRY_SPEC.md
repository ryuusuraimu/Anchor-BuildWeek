# Anchor Tidal Aperture — Rive authoring and native production contract

## Purpose

Tidal Aperture is an ambient, responsive material system for Anchor's calm-state
surfaces. It is allowed on **Home** and the optional **Reset** only. It must never be
loaded by Shield, where legibility and predictable stillness take priority.

The motion should feel authored and emotionally warm, not like a generic wellness
gradient. Its central idea is **a signal making room**: five translucent membranes and
one dark aperture enter from outside the right edge, leaving the left reading field open.
There is no centered icon, spinner, particle field, or concentric loading motif.

## File contract

- File: `Resources/AnchorLivingGeometry.riv`
- Editable vector source: `Design/Rive/AnchorTidalAperture.svg`
- Rive editor project: `AnchorLivingGeometryPro`
- Default artboard: `AnchorLivingGeometry`
- Default state machine: `LivingGeometry`
- Transparent artboard background; SwiftUI owns the full-screen base gradient.
- Logical design size: 390 × 844. The geometry is right-edge anchored and intentionally
  cropped; the left 58% remains a quiet reading field.
- No text, audio, raster images, personal data, network assets, or embedded gestures.

## State-machine inputs

| Input | Type | Values | Purpose |
| --- | --- | --- | --- |
| `theme` | Number | `0` Grounded, `1` Luminous | Morphs material weight and palette |
| `mode` | Number | `0` Home, `1` Reset | Selects 28-second ambient or 8-second breath behavior |
| `engagement` | Number | `0...1` | Opens the signal orbit when Start is pressed or Reset is active |

Runtime control stays in `LivingGeometryField.swift`. Native Canvas playback follows the
display refresh schedule, while the optional Rive bridge is capped at 60 fps. Playback
pauses with the app scene and Reset pause state and is bypassed entirely when Reduce
Motion is enabled.

## Motion direction

### Home / Grounded

- Five mineral membranes drift on a seamless 28-second loop.
- Maximum travel is 3.2 pt horizontal and 5.2 pt vertical; maximum rotation is 0.56°.
- The coral seam appears once and never flashes.
- Engagement deepens the aperture by 1.8% and shifts it inward by 4 pt while pressed.

### Home / Luminous

- The same authored membrane geometry uses opaline lavender, mineral teal, and ivory.
- Each layer receives a different fraction of the base transform to create restrained
  optical parallax; a glint travels only 2.6 pt.
- Highlights never loop around a center and never resemble progress or loading.

### Reset

- One complete breath cycle is exactly eight seconds: four seconds opening, then four
  seconds returning. Fifth-order smootherstep easing gives zero velocity and acceleration
  at the turnarounds; separate horizontal and vertical scale prevents balloon-like motion.
- Layer delay is depth-based and never exceeds 0.048 seconds in Reset.
- Pausing freezes the current frame. Resuming continues from that frame.
- The motion never instructs the person to match it perfectly; the visible copy remains
  “Follow your own pace.”

## Accessibility and review gates

- Reduce Motion: do not instantiate Rive or a timeline; show the deterministic Canvas still.
- VoiceOver: artwork is hidden and never receives focus.
- Touch: artwork has hit testing disabled; existing buttons own every interaction.
- Shield: no Rive import, view, timeline, implicit animation, or theme dependency.
- Photosensitivity: no flash, full-field luminance jump, rapid alternating contrast, or
  more than three high-contrast transitions per second.
- Performance: display-synchronized native rendering, 60 fps optional Rive cap, pause
  while inactive, no remote file loading.

## Production status

The iOS dependency and optional runtime bridge are implemented and type-checked against
RiveRuntime 6.20.1. The signed-in Rive Editor project contains the original artboard,
layer names, `HomeAmbient` timeline, and default `LivingGeometry` state machine. Rive's
current workspace requires an upgrade for runtime `.riv` export, so the app does not
depend on that export.

The production implementation is the matching original SwiftUI Canvas geometry in
`ResponsiveShelterField.swift`. It is fully vector, offline, display-synchronized,
suspended while inactive, and verified in Simulator. If a compatible `.riv` is exported
later and placed at the file-contract path, `LivingGeometryField` selects it automatically.
