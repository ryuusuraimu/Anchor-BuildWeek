# Support Relay Design

Last updated: 2026-07-08

## Purpose

Support Relay lets the user save multiple trusted support contacts and call them in a clear order from Shield.

The feature is designed for panic or overwhelm moments, where looking at the screen, reading dense UI, or recovering from a mistaken tap may be difficult.

## Apple Platform Constraint

iOS apps can open a `tel:` URL for a selected phone number, but the system controls the final call confirmation. Anchor should not attempt automatic chained calling.

Therefore Support Relay is intentionally manual:

1. The user taps one large call button.
2. iOS asks before placing the call.
3. If that person is unavailable, the user returns to Anchor and taps `Next`.
4. Anchor moves to the next support contact in the saved order.

## Accessibility Requirements

- Shield shows one current relay contact at a time.
- The primary call button is large and located near the bottom.
- The current relay position is shown as `Contact N of M`.
- `Next` is separate from `Call` to reduce accidental calls.
- Home shows the relay order and allows moving contacts earlier or later.
- All call, edit, move earlier, and move later actions have explicit accessibility labels.

## Implementation

- `EmergencyContactStore` now persists `[EmergencyContact]`.
- The previous single-contact storage key is migrated into the new relay list.
- Clear Local Data removes both the current Support Relay key and the previous single-contact key.
- `EmergencyContactStore.contact` remains as a compatibility accessor for the primary contact.
- `ShieldView` uses `activeRelayIndex` to show and call the current relay contact.
- `EmergencyContactCard` displays the relay order and provides add, call, edit, move earlier, and move later actions.
- `Scripts/validate_ios_project.sh` includes regression checks for the relay store, Shield Call/Next controls, and accessible ordering actions.
- Picking from Contacts while adding creates a new relay contact. Picking from Contacts while editing preserves that contact's ID and updates it instead of appending a duplicate.
