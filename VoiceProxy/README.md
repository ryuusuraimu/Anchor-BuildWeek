# Anchor VoiceProxy

VoiceProxy keeps the OpenAI API key outside the iOS app. It accepts prepared Shield text and a supported voice, then returns AAC audio from the OpenAI speech endpoint. It uses Node.js built-in modules and has no npm package dependencies.

## Local setup

Use Node.js 20 or newer. Copy `.env.example` to `.env.local` and add your own key to the local copy:

```sh
cp VoiceProxy/.env.example VoiceProxy/.env.local
node --env-file=VoiceProxy/.env.local VoiceProxy/server.mjs
```

The Simulator connects to `http://127.0.0.1:8787/v1/speech`. For a physical iPhone, run the proxy on a reachable Mac address and configure the app's `-voiceProxyURL` launch argument. Use HTTPS for any deployed endpoint; do not expose a public unauthenticated proxy.

`.env.local` is ignored by Git. Never commit keys or tokens. The checked-in `.env.example` contains placeholders only.

## Contract test

This test validates request input and the OpenAI speech request shape without contacting OpenAI:

```sh
node --test VoiceProxy/contract.test.mjs
```

## App boundary

Speech is generated during preparation when requested. The resulting AAC file is saved on device. Shield plays the saved file without contacting this service and falls back to the iOS system voice when no file is ready.
