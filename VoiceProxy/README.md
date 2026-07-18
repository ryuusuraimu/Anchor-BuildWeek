# Anchor VoiceProxy

This small Node 20+ service keeps the OpenAI API key outside the iOS app. It accepts only prepared Shield text and a supported voice, then returns AAC audio from OpenAI's speech endpoint.

## Local development

From `Anchor-BuildWeek.swiftpm`:

```sh
node --env-file=.env.local VoiceProxy/server.mjs
```

The debug iOS build connects to `http://127.0.0.1:8787/v1/speech`. The API key stays in `.env.local`, which is ignored by source control.

Do not include `.env.local` when sharing or archiving the project folder. This directory is not currently a Git working tree, so `.gitignore` alone does not protect a manually created ZIP.

Run the contract tests with:

```sh
node --test VoiceProxy/contract.test.mjs
```

## Production boundary

Do not ship the OpenAI key in the app. Deploy this service behind HTTPS, rate limiting, monitoring, and app/device attestation, then inject the production endpoint through the `AnchorVoiceProxyURL` Info.plist key. The Shield screen itself never calls this service; audio is generated in advance and saved on device.
