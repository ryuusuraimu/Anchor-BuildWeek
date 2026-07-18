# Anchor iOS Development Workflow

Last updated: 2026-07-08

This project will follow OpenAI Codex's official "Build for iOS" use case as the baseline for iOS development.

Official reference:

- https://developers.openai.com/codex/use-cases/native-ios-apps

The core workflow is:

- Treat Anchor v1 as an existing iPhone SwiftUI project.
- Keep the build loop CLI-first.
- Prefer Apple's `xcodebuild` where the project shape allows it.
- Use XcodeBuildMCP when scheme discovery, simulator control, screenshots, logs, or UI automation become available.
- Use focused SwiftUI / Build iOS Apps skills for UI patterns, App Intents, performance, refactors, and simulator debugging.
- After each change, run the smallest validation step that proves the touched contract, then expand to broader checks.

Default local validation command:

```bash
Scripts/validate_ios_project.sh
```

Optional build probe:

```bash
Scripts/validate_ios_project.sh --build
```

Default simulator smoke check:

```bash
Scripts/anchor_simulator_loop.sh smoke
```

## Skill Sources Used

The official page points to Build iOS Apps / SwiftUI-focused skills. In this Codex session, the following local skill files were found, read, and adopted:

- `build-ios-apps/skills/swiftui-ui-patterns/SKILL.md`
- `build-ios-apps/skills/ios-app-intents/SKILL.md`
- `build-ios-apps/skills/ios-debugger-agent/SKILL.md`
- `build-ios-apps/skills/ios-simulator-browser/SKILL.md`

Environment notes:

- These skills were found in the local Codex plugin cache.
- Tool discovery did not expose the Build iOS Apps plugin as an installable/callable plugin in this session.
- The active tool list does not currently expose XcodeBuildMCP, which `ios-debugger-agent` prefers for simulator build/run/debug operations.
- Until XcodeBuildMCP is available, use the same workflow intent with `Scripts/anchor_simulator_loop.sh`, local Xcode, `xcodebuild`, `xcrun simctl`, and real-device verification where possible.
- See `XCODEBUILDMCP_ADOPTION.md` for the MCP adoption plan and fallback command loop.
- If the SwiftPM / Swift Playgrounds project format blocks reliable release automation, use `NATIVE_IOS_MIGRATION_PLAN.md` to move Anchor to a standard native Xcode iOS project.

## Development Rules For Anchor

### SwiftUI UI Work

- Follow existing Anchor patterns before introducing new architecture.
- Prefer focused SwiftUI subviews over large mixed-responsibility views.
- Keep state as local as possible.
- Use `@State`, `@Binding`, `@Observable`, and `@Environment` according to ownership.
- Use enum-driven sheets for mutually exclusive modal flows.
- Avoid adding a new reference model when value state is enough.
- Preserve the current iOS 17+ SwiftUI / Observation direction unless a file already uses legacy `ObservableObject` for a clear reason.

### App Intents / Shortcuts

- Expose only high-value actions to the system.
- Keep shortcut phrases direct, narrow, and user-task oriented.
- Avoid medical, emergency-service, or diagnosis-like phrasing.
- Keep App Intents thin and route into app services or `AppRouter` where needed.
- Validate any changed intent by building and testing from Shortcuts/Siri when the build toolchain is available.

### Build And Run Workflow

Official target workflow:

1. Discover project schemes/targets.
2. Build from the terminal.
3. Launch in simulator or on device.
4. Capture screenshots or UI state when visual proof matters.
5. Keep iteration agentic and avoid relying on manual Xcode GUI steps except where the project format requires it.

Preferred when XcodeBuildMCP becomes available:

1. List simulators and choose a booted device.
2. Set project/session defaults.
3. Build and run the app.
4. Confirm launch with UI inspection or screenshot.
5. Capture logs when diagnosing runtime issues.

Current fallback:

1. Use the narrowest available command-line check first.
2. Run `Scripts/validate_ios_project.sh` after code or release-readiness edits.
3. Use `Scripts/validate_ios_project.sh --build` when the environment may support an Xcode project probe.
4. Use `Scripts/anchor_simulator_loop.sh smoke` for build/install/launch/screenshot evidence.
5. If the Swift Playgrounds `AppleProductTypes` manifest cannot be handled by command-line Xcode, open/build the SwiftPM iOS application in Xcode or Swift Playgrounds.
6. Build for a current iPhone simulator or real iPhone.
7. Verify first-launch onboarding.
8. Verify Home, Studio, Shield, QR, Contact, Learn, Journal, and Settings.
9. Verify App Shortcuts from Shortcuts where available.
10. Verify Lock Screen / Now Playing Shield behavior on a real iPhone.

### Simulator Browser / Preview Workflow

Use `ios-simulator-browser` when a simulator UDID and browser mirror tools are available:

1. Start the simulator mirror for a specific simulator UDID.
2. Open the printed local URL in the Codex in-app browser.
3. Capture proof that the simulator frame is rendering.
4. Keep the mirror process alive only while actively using it.

For Anchor, this is useful for screenshot QA and visual iteration once simulator access is available.

## Release Verification Checklist

- [ ] `Scripts/validate_ios_project.sh` passes.
- [ ] `Scripts/anchor_simulator_loop.sh smoke` passes.
- [ ] Build succeeds in Xcode or XcodeBuildMCP.
- [ ] If SwiftPM format blocks archive/upload automation, decide on native Xcode migration using `NATIVE_IOS_MIGRATION_PLAN.md`.
- [ ] App launches on a current iPhone simulator.
- [ ] App launches on a real iPhone before App Store submission.
- [ ] First-launch setup can be completed and skipped.
- [ ] Shield opens from Home.
- [ ] Studio edits persist into Shield.
- [ ] QR code scans from another device.
- [ ] Trusted contact can be added manually.
- [ ] Optional Contacts permission flow works.
- [ ] Journal starts empty for a new user.
- [ ] App Shortcuts compile and appear as expected.
- [ ] Lock Screen / Now Playing behavior works on real device.
- [ ] No demo data or placeholder text appears in production.
- [ ] Store metadata matches the actual app.

## Current Tooling Gap

The official Codex iOS workflow recommends XcodeBuildMCP for deeper automation once scheme discovery, simulator control, screenshots, logs, and UI interaction matter. The project should use XcodeBuildMCP if it becomes available in this Codex session.

At the time this workflow was written, tool discovery did not expose:

- `mcp__XcodeBuildMCP__list_sims`
- `mcp__XcodeBuildMCP__session-set-defaults`
- `mcp__XcodeBuildMCP__build_run_sim`
- `mcp__XcodeBuildMCP__describe_ui`
- `mcp__XcodeBuildMCP__screenshot`

Until those are available, build verification must be done with local Xcode/Swift Playgrounds or best-effort command-line checks.
