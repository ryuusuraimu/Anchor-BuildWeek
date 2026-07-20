# Anchor VoiceProxy

This small Node 20+ service keeps the OpenAI API key outside the iOS app. It accepts only prepared Shield text and a supported voice, then returns AAC audio from OpenAI's speech endpoint.

## Local development

From `Anchor-BuildWeek.swiftpm`:

```sh
node --env-file=.env.local VoiceProxy/server.mjs
```

The debug iOS Simulator build connects to `http://127.0.0.1:8787/v1/speech`. Start the proxy before tapping **Preview** or **Create offline reading**:

```sh
node --env-file=.env.local VoiceProxy/server.mjs
```

`127.0.0.1` points to the Mac when the app runs in Simulator. On a physical iPhone,
bind the proxy to the Mac's LAN interface and pass the Mac's reachable address through
the Xcode launch argument (or an `AnchorVoiceProxyURL` Info.plist value):

```sh
HOST=0.0.0.0 PORT=8787 node --env-file=.env.local VoiceProxy/server.mjs
```

Then launch with `-voiceProxyURL http://<mac-lan-ip>:8787/v1/speech`. For production,
use HTTPS; never expose the API key or an unauthenticated proxy to the public internet.
The API key stays in `.env.local`, which is ignored by source control.

Do not include `.env.local` when sharing or archiving the project folder. This directory is not currently a Git working tree, so `.gitignore` alone does not protect a manually created ZIP.

Run the contract tests with:

```sh
node --test VoiceProxy/contract.test.mjs
```

## Production boundary

Do not ship the OpenAI key in the app. Deploy this service behind HTTPS, rate limiting, monitoring, and app/device attestation, then inject the production endpoint through the `AnchorVoiceProxyURL` Info.plist key. The Shield screen itself never calls this service; audio is generated in advance and saved on device.
