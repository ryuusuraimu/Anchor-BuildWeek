# Anchor

Anchor is an iPhone app built with SwiftUI that helps a person prepare support information before a stressful moment. It is a portfolio project exploring how a focused interface can make it easier to communicate when speaking or making decisions feels difficult. It is not a medical device, diagnostic tool, or emergency service.

## The problem

In a high-stress moment, navigating a complex app or explaining personal needs can be difficult. Anchor moves setup into a calm moment and keeps the prepared support card available with a direct Shield action.

## Implementation

This portfolio snapshot includes work on:

- SwiftUI app routing and a three-tab Home, Shield, and Prepare experience
- A short guided Reset with Reduce Motion support
- A preparation flow for a local support card and ordered support contacts
- A static, high-contrast Shield with QR sharing and explicit contact actions
- Optional local aftercare notes
- VoiceProxy request validation and a contract test for optional speech generation
- App privacy declarations and iOS permission descriptions

Codex/GPT-5.6 was used as a development aid for iteration on SwiftUI, accessibility states, the VoiceProxy contract, verification scripts, and the demonstration. The repository contains the implementation and reviewable project files.

## Main flows

- **Prepare:** enter support wording and contacts one question at a time; data is stored on the device.
- **Shield:** show the prepared support card, share its limited QR payload, or work through contacts one at a time. Shield does not generate AI content or make a network request.
- **Reset:** use a guided breathing rhythm, with motion reduced according to the system accessibility setting.
- **Aftercare:** optionally save a short check-in locally.
- **Voice:** optionally generate an AAC reading during preparation through VoiceProxy. The file is cached locally for later use.

## Technology and architecture

- Swift 5, SwiftUI, iOS 17+, and a native Xcode iOS app project
- Feature-oriented source folders under `Features/`, with app routing in `App/`
- Shared iOS services in `Services/`, app media in `Assets.xcassets/`, and bundled resources in `Resources/`
- Node.js 20+ VoiceProxy, using built-in Node modules and the OpenAI speech API

The iOS app sends prepared text and a selected voice to the configured VoiceProxy only when the person requests speech creation during preparation. The proxy holds the OpenAI key server-side and returns AAC audio. No key belongs in the app or repository. Shield reads the cached audio when available and falls back to an iOS system voice. Prepared instructions and QR sharing remain available offline; speech generation itself requires a network connection and a configured proxy.

## Screenshots

| Home | Prepare | Shield |
|---|---|---|
| ![Home screen](BuildWeekScreenshots/2026-07-20/01-home-current.png) | ![Prepare screen](BuildWeekScreenshots/2026-07-20/02-prepare-complete-current.png) | ![Shield screen](BuildWeekScreenshots/2026-07-20/03-shield-current.png) |

| Shield QR | Voice settings | Reset |
|---|---|---|
| ![Shield QR screen](BuildWeekScreenshots/2026-07-20/04-shield-qr-current.png) | ![Voice settings](BuildWeekScreenshots/2026-07-20/05-voice-settings-current.png) | ![Reset screen](BuildWeekScreenshots/2026-07-20/06-reset-current.png) |

These are simulator captures dated 2026-07-20.

## Run the app

1. Clone this repository.
2. Open `Anchor.xcodeproj` in Xcode.
3. Select an iOS 17 or newer iPhone Simulator.
4. Build and run the `Anchor` scheme.

The Xcode target does not require a fixed Developer Team for Simulator builds.

## Run VoiceProxy contract checks

Node.js 20 or newer is required. The test checks request validation and construction locally; it does not contact OpenAI.

```sh
node --test VoiceProxy/contract.test.mjs
```

To try speech generation, copy `VoiceProxy/.env.example` to `VoiceProxy/.env.local`, add a personal key to the local file, and run:

```sh
node --env-file=VoiceProxy/.env.local VoiceProxy/server.mjs
```

Keep the proxy private for local development. A public deployment needs HTTPS, authentication, rate limiting, and monitoring. The checked-in `.env.example` contains placeholders only.

## Project structure

```text
Anchor.xcodeproj/      Native Xcode project and shared Anchor scheme
App/                    App entry, routing, tabs, and settings
Features/               Feature views, models, stores, and presentation logic
Assets.xcassets/        App icon and interface artwork
Resources/              App bundle resources
Services/               Shared iOS integrations
Scripts/                Project validation and simulator workflow helpers
StoreWeb/               Privacy and support page source
VoiceProxy/             Key-isolating speech proxy and contract test
BuildWeekScreenshots/   Current simulator captures used above
```

`Scripts/validate_ios_project.sh` checks the native Xcode project, plist/privacy settings, README screenshots, and VoiceProxy placeholders. When Xcode and the iOS Simulator SDK are available, it lists the project and builds the `Anchor` scheme without code signing. The VoiceProxy contract tests run separately with Node.js.

## Status

This is a Build Week portfolio snapshot. The native Xcode project built successfully for the iOS Simulator SDK during this migration check (Xcode 27, signing disabled). Physical-device installation, VoiceOver listening-order review, and App Store distribution signing have not been verified.

## License

All rights reserved. See [LICENSE](LICENSE).
