# Anchor App Privacy Answers

Last updated: 2026-07-18

## Recommendation

If the OpenAI voice feature is enabled in the submitted build, do **not** select `Data Not Collected`.

Recommended App Store Connect disclosure:

```text
Data Not Linked to You
  User Content
    Other User Content
      Purpose: App Functionality

Data Used to Track You
  None
```

Reason: a person can deliberately send prepared Shield wording to the Anchor VoiceProxy and OpenAI speech API to generate a selected voice. The app has no account or user identifier, does not use this content for tracking, and does not send contacts or journal entries.

## Evidence Checked

- Local storage through `UserDefaults` and Application Support
- `PrivacyInfo.xcprivacy` declares Other User Content for App Functionality, not linked and not tracked
- Optional Contacts picker through `ContactsUI`
- One constrained `URLSession` client in `ShieldVoiceLibrary`
- No network request in `BuildWeekShieldView` or `ShieldEngine`
- No analytics, advertising, attribution, location, camera, or microphone SDKs
- Generated Shield AAC is excluded from device backup and removed by Clear Local Data

## Contacts Permission

Anchor asks for Contacts access only when the person chooses the system contact picker. The selected name, phone number, and label stay on device and are not sent to the voice service.

## User Content

Journal entries stay on device. **Preview** sends only a fixed built-in sample. Prepared Shield wording is sent only after the person taps **Create offline reading**. It is used to generate requested speech and is not linked to an Anchor account.

OpenAI's current API data controls say API data is not used for model training by default unless the customer opts in. The `/v1/audio/speech` endpoint has up to 30 days of abuse-monitoring retention by default and no application-state retention. Recheck these terms and the production host's logging behavior immediately before submission.

## Tracking

Answer:

```text
No, we do not use this app to track users.
```

## Third-Party Processing

OpenAI processes the prepared Shield wording solely to return generated audio. The production privacy policy must identify this processing and link the applicable OpenAI privacy/data-control terms.

## Important Maintenance Rule

Revisit these answers before submission if analytics, ads, accounts, crash reporting, cloud sync, additional external APIs, or any identifier linked to voice requests is added.
