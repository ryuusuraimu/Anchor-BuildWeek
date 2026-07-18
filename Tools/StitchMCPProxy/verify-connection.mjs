#!/usr/bin/env node

import { execFileSync } from "node:child_process";
import { userInfo } from "node:os";
import { StitchToolClient } from "@google/stitch-sdk";

const apiKey = execFileSync(
  "/usr/bin/security",
  [
    "find-generic-password",
    "-a",
    userInfo().username,
    "-s",
    "codex-stitch-api-key",
    "-w"
  ],
  {
    encoding: "utf8",
    stdio: ["ignore", "pipe", "ignore"]
  }
).trim();

const client = new StitchToolClient({ apiKey });

try {
  const result = await client.listTools();
  const names = result.tools.map((tool) => tool.name).sort();
  console.log(`Connected to Stitch MCP. ${names.length} tools available.`);
  console.log(names.join("\n"));
} finally {
  await client.close();
}
