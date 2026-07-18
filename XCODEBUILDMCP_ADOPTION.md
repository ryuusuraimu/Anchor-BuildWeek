# Anchor XcodeBuildMCP Adoption

Last updated: 2026-07-08

## Decision

Adopt the Build iOS Apps / XcodeBuildMCP workflow as Anchor's preferred simulator debugging loop.

Current state:

- Build iOS Apps skill files are present locally in the Codex plugin cache.
- The local plugin MCP definition points to `xcodebuildmcp@latest`.
- XcodeBuildMCP tools are not currently exposed in this chat's callable tool list.
- Anchor can still use the same loop today through `xcodebuild` and `xcrun simctl`.
- In sandboxed Codex turns, simulator commands may require an elevated/out-of-sandbox run because Xcode writes to SwiftPM caches, DerivedData, and CoreSimulator logs.

## Local Plugin Definition Found

Path:

```text
/Users/pario/.codex/.tmp/plugins/plugins/build-ios-apps/.mcp.json
```

MCP server:

```json
{
  "mcpServers": {
    "xcodebuildmcp": {
      "command": "npx",
      "args": ["-y", "xcodebuildmcp@latest", "mcp"],
      "env": {
        "XCODEBUILDMCP_ENABLED_WORKFLOWS": "simulator,ui-automation,debugging,logging"
      }
    }
  }
}
```

## Preferred Workflow When XcodeBuildMCP Is Exposed

Use the `ios-debugger-agent` pattern:

1. List simulators.
2. Pick or reuse a booted simulator.
3. Set session defaults:
   - workspace/project path: `Anchor.swiftpm`
   - scheme: `Anchor`
   - simulator: chosen UDID
   - configuration: `Debug`
4. Build and run.
5. Describe UI before tapping.
6. Prefer labels or accessibility identifiers over raw coordinates.
7. Capture screenshots for visual proof.
8. Capture logs when debugging runtime behavior.
9. Attach debugger only for crashes, hangs, or state that cannot be explained from UI/logs.

Expected MCP tools include:

- `list_sims`
- `session-set-defaults`
- `build_run_sim`
- `describe_ui`
- `tap`
- `type_text`
- `gesture`
- `screenshot`
- `start_sim_log_cap`
- `stop_sim_log_cap`

## Current Anchor Fallback

Until XcodeBuildMCP tools are exposed, use:

```bash
Scripts/anchor_simulator_loop.sh smoke
```

This performs:

1. Simulator build.
2. Simulator boot.
3. App install.
4. App launch.
5. Screenshot capture.

If the command fails with SwiftPM cache, DerivedData, or CoreSimulator permission errors, rerun it from a local terminal or a Codex turn that allows out-of-sandbox command execution.

Default target:

- Scheme: `Anchor`
- Simulator: `iPhone 17e`
- OS: `26.5`
- Bundle ID: `com.Ryunosuke.Anchor`

Override example:

```bash
DEVICE_NAME="iPhone 17 Pro" DEVICE_OS="26.5" Scripts/anchor_simulator_loop.sh smoke
```

## Anchor QA Uses

Use this loop for every meaningful UI change:

- First launch onboarding
- Setup skip and completion
- Home readiness state
- Studio editing and save
- Shield display
- QR view
- Support Contact setup
- Learn
- Journal empty state and entry creation
- Settings

Use screenshots as evidence for:

- App Store screenshot readiness
- Accessibility and contrast checks
- Copy changes around panic/overwhelm/support language
- Regression checks after refactors

## Current Known Visual Issue

The first simulator launch showed low contrast red example chips on the dark onboarding screen.

Fix before final App Store screenshots.
