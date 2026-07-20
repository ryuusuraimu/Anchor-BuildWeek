# Devpost Submission Checklist — Anchor

The Devpost project draft has been prepared at:

- Project: https://devpost.com/software/anchor-human-signal
- Hackathon: OpenAI Build Week
- Repository: https://github.com/ryuusuraimu/Anchor-BuildWeek
- Category: Apps for Your Life

## Project copy

**Name**

Anchor — Human Signal

**Tagline**

A calm, offline-first way to communicate what helps when words are hard.

**Built with**

Swift, SwiftUI, iOS, Xcode, Node.js, OpenAI API, `gpt-4o-mini-tts`, GPT-5.6, Codex

## Required fields still needed before final submission

- [ ] Public YouTube URL for the final demo (under three minutes; the current cut is 135 seconds)
- [ ] Submitter Type: Individual / Team of Individuals / Organization
- [ ] Country of Residence
- [ ] `/feedback` Codex Session ID for the main build session

Do not invent the Session ID. It must be copied from the Codex `/feedback` flow for
the session where the majority of the project was built.

## Demo requirements

The voiceover must visibly demonstrate the working app and explain:

1. The communication problem Anchor addresses.
2. Home, Prepare, Reset, Shield, Support Relay, QR, and optional voice preparation.
3. Why Shield is deterministic and remains usable offline.
4. Where Codex accelerated the SwiftUI implementation, accessibility review, testing,
   and demo production.
5. How GPT-5.6 contributed to product decisions, information hierarchy, and the
   calm-state design direction.

## Judge test path

1. Clone the repository and open the Swift Package in Xcode or Swift Playgrounds.
2. Run on an iOS Simulator or physical iPhone.
3. Open **Prepare** and complete the one-question flow.
4. Open **Shield** and verify the static high-contrast card, QR sharing, and manual
   Support Relay.
5. Optional: copy `VoiceProxy/.env.example` to `.env.local`, add the judge's own
   OpenAI key, and run the local proxy. The app still works without this optional
   service through the iOS voice fallback.

## Safety boundary

Anchor is not a medical device, diagnostic tool, emergency service, or substitute for
professional care. No API key is stored in the app or repository. Shield never makes
an AI or network request during the hard moment.
