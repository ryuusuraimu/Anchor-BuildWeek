#!/usr/bin/env node

import { execFileSync } from "node:child_process";
import { userInfo } from "node:os";
import { StitchProxy } from "@google/stitch-sdk";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

const keychainService = "codex-stitch-api-key";

function readApiKey() {
  if (process.env.STITCH_API_KEY) {
    return process.env.STITCH_API_KEY;
  }

  try {
    return execFileSync(
      "/usr/bin/security",
      [
        "find-generic-password",
        "-a",
        userInfo().username,
        "-s",
        keychainService,
        "-w"
      ],
      {
        encoding: "utf8",
        stdio: ["ignore", "pipe", "ignore"]
      }
    ).trim();
  } catch {
    console.error(
      `Stitch API key is missing. Store it in macOS Keychain under service '${keychainService}'.`
    );
    process.exit(1);
  }
}

const proxy = new StitchProxy({
  apiKey: readApiKey(),
  timeout: 300_000
});
const transport = new StdioServerTransport();

await proxy.start(transport);
