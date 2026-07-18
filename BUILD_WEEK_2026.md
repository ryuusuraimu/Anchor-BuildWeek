# Anchor — OpenAI Build Week 2026

Last updated: 2026-07-18

## Objective

Win first place in the **Apps for Your Life** category by making Anchor meaningfully easier and safer to prepare for people who may struggle to look at a screen, speak, decide, or recover from a mistaken tap during panic or overwhelm.

The Build Week version must be a real extension of the existing project, not a relabeling of work completed before the submission period.

## Competition Facts

- Submission period: July 13, 2026 at 9:00 AM PT through July 21, 2026 at 5:00 PM PT.
- Target category: Apps for Your Life.
- First-place prize: USD 15,000, OpenAI developer promotion, up to two Dev Day/Exchange passes, a meeting with the Codex team, and one year of Pro.
- Required: working project, project description, category selection, public YouTube demo under three minutes, code repository, README, and the primary `/feedback` Codex Session ID.
- The demo voiceover must explain the product, how Codex was used, and how GPT-5.6 was used.
- Existing projects are allowed only when they are meaningfully extended during the submission period. Only the new work is evaluated.

## Judging Lens

1. **Technological Implementation** — substantial, working use of Codex.
2. **Design** — a complete and coherent runnable product, not a proof of concept.
3. **Potential Impact** — credible evidence that a real audience has a real problem and that the demonstrated product addresses it.
4. **Quality of the Idea** — creativity plus genuine understanding of the problem space.

## Pre-Build-Week Baseline

The following existed before the submission period and must not be presented as new Build Week work:

- SwiftUI iPhone app shell and four-tab navigation.
- Prepared Shield support card.
- Offline QR support instructions.
- Studio editing flow.
- Breathing, Journal, Learn, and Setup experiences.
- Local-first storage and Clear Local Data.
- Support Relay with multiple trusted contacts and manual Call / Next behavior.
- Lock Screen / Now Playing support while Shield is active.
- Existing visual system, illustrations, store documents, and release validation scripts.

## Human Constraint

The defining constraint is not “make a wellness app.” It is:

> In the hardest moment, the person may be unable to read the screen, explain what is happening, compare options, or correct a mistaken action.

Therefore:

- AI must help primarily **before** the hard moment, not become a dependency during it.
- Shield must remain deterministic, fast, and usable without an AI response.
- AI output must never be treated as diagnosis, treatment, emergency instruction, or a source of truth.
- The user must review and explicitly accept every generated support instruction.
- Sensitive text must not be sent without a clear opt-in and a preview of what will be shared.

## Implemented Submission Direction

The current release candidate intentionally does **not** embed generative AI. The user
chose to finish the non-AI product first so the panic-time experience could be judged on
clarity, accessibility, and reliability rather than an unfinished service dependency.

The implemented Build Week extension is **Human Signal**:

- a new three-tab Home / Shield / Prepare route;
- a native interactive Canvas identity for calm-state Home and Reset;
- a five-question One-Minute Anchor preparation flow;
- a simplified trusted-person editor and optional Aftercare check-in;
- a redesigned one-screen Shield with manual Support Relay and offline QR;
- reproducible Dynamic Type, Reduce Motion, and Shield scenario review states.

Codex and GPT-5.6 were used as the product-design, implementation, critique, and QA
partner. They are not presented as a runtime feature of this build.

## Deferred AI Product Directions

The following directions were explored but are not implemented in the release candidate.
They remain future calm-time possibilities and must not become a Shield dependency.

### A. Safe — Clear My Card

The user writes or dictates a rough description while calm. GPT-5.6 turns it into a short, readable draft with four fixed sections:

- What may be happening
- What helps me
- What to avoid
- Who to contact

The user reviews each line, edits it, and chooses whether to save it locally.

**Strength:** highly feasible and directly improves setup friction.

**Weakness:** an AI writing assistant alone may feel familiar unless the stress-readability system is distinctive and measurable.

### B. Differentiated — Support Rehearsal

After creating a Shield, GPT-5.6 simulates how three different nearby supporters might interpret it: a friend, a stranger, and venue staff. Anchor flags ambiguity, accidental pressure, consent problems, and sentences that require too much reading.

The product never tells the user what their symptoms mean. It tests whether their prepared communication is understandable.

**Strength:** turns AI into a communication design partner and shows deeper understanding of both sides of the moment.

**Weakness:** it is less immediate unless paired with a strong before/after editing flow.

### C. Ambitious — One-Minute Anchor

The user answers a calm, one-question-at-a-time interview. GPT-5.6 produces a complete Shield draft and a separate supporter-facing card. A local stress-readability pass then checks length, action count, negative wording, and visual density before the user accepts it.

The final Shield is saved on-device and remains available offline. No generation happens in Shield mode.

**Strength:** a memorable end-to-end experience with a clear transformation: a difficult personal story becomes a usable support interface in one minute.

**Weakness:** highest implementation and privacy-design scope.

## Future Direction (not in the current build)

Build **One-Minute Anchor** as the central experience, with **Support Rehearsal** as its final review step.

This combination is stronger than a generic chatbot because GPT-5.6 is used for a task that needs nuanced language understanding, perspective-taking, and structured transformation, while the panic-time experience remains deterministic and low-risk.

The memorable product sentence is:

> Tell Anchor what a hard moment feels like. Leave with one card another person can understand.

## Future AI Experience (not in the current build)

1. From Studio, tap **Make this easier**.
2. Read a plain privacy explanation before any text is shared.
3. Answer one prompt at a time, with typing or dictation:
   - What might someone notice?
   - What usually helps?
   - What can make it worse?
   - Is there anything important they should know?
4. Preview exactly what will be sent to GPT-5.6.
5. Generate a structured draft.
6. Review each sentence using **Keep**, **Edit**, or **Remove**.
7. Run Support Rehearsal and show only concrete clarity issues.
8. Preview the final Shield at realistic size.
9. Save locally. Shield remains available without AI or network access.

## Visual Direction

The AI setup experience should feel like a quiet editor, not a chatbot:

- One question per screen.
- No message bubbles.
- A visible four-step progression without percentage anxiety.
- Large text and one primary action.
- Warm neutral surfaces with the current orange accent reserved for commitment actions.
- Generated sentences shown as physical “strips” that can be kept, edited, or removed.
- A final full-screen Shield preview that shifts the experience from preparation to confidence.

Avoid gradients that imply magic, animated sparkles, “AI-powered” badges, and conversational filler.

## Safety and Privacy Contract

- Opt-in only; no background generation.
- Show the outgoing text before sending.
- Do not send contact phone numbers, journal history, or saved Shield history.
- Ask the model to rewrite user-provided preferences, not invent medical guidance.
- Use a strict structured response schema.
- Reject or remove diagnoses, medication changes, emergency guarantees, and fabricated facts.
- Require human review before saving.
- Store only the accepted final card locally.
- Keep the existing manual Studio flow fully functional.

## Future Technical Shape (not implemented)

- iOS client: new preparation flow, structured draft model, review UI, local validation, and offline persistence.
- Server boundary: a minimal authenticated proxy so no OpenAI API key is embedded in the app.
- OpenAI: Responses API with GPT-5.6 and structured output.
- Reliability: timeouts, cancellation, retry with preserved input, and a manual fallback.
- Testability: deterministic mock response and sample story for judges, with no real personal data required.

Adding a server or production dependency requires explicit approval before implementation.

## Build Week Evidence Log

All qualifying work must be recorded below with date, commit, Codex session, and verification result.

| Date | New work | Evidence | Verification |
|---|---|---|---|
| 2026-07-15 | Competition requirements, baseline, three UX directions, and recommended architecture documented | Current Codex task; `BUILD_WEEK_2026.md` | Document reviewed against Devpost requirements |
| 2026-07-17 | Human Signal Home and breath-synchronized Reset implemented with native Canvas; Shield kept outside the motion system | `Features/BuildWeek/Design`; `Features/BuildWeek/Views` | Simulator build and visual review |
| 2026-07-18 | Prepare, contact editing, Aftercare, and final primary navigation unified; Shield and accessibility matrices captured | `BuildWeekScreenshots/v23-*` through `v25-*` | Static validator passed; simulator build succeeded; reviewed at standard and maximum Dynamic Type |

## Definition of Done

- A judge can build and run the Build Week experience.
- The demo shows preparation becoming a complete, supporter-readable Shield in about one minute.
- Shield visibly works without AI or a network connection.
- Dynamic Type and Reduce Motion have simulator evidence; VoiceOver and physical-device
  behavior are checked before recording the final demo.
- README separates the active Build Week route from legacy compiled features.
- The repository contains a clear Codex/GPT-5.6 implementation and QA record without
  claiming runtime AI.
- The public demo is under three minutes and narrates the product, how Codex was used,
  and how GPT-5.6 contributed to design and implementation.
- Devpost is no longer an Untitled draft and is explicitly submitted to Apps for Your Life.
