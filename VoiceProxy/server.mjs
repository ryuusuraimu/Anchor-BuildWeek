import { createServer } from "node:http";
import { buildOpenAIRequest, validateSpeechRequest } from "./contract.mjs";

const host = process.env.HOST ?? "127.0.0.1";
const port = Number.parseInt(process.env.PORT ?? "8787", 10);
const openAIKey = process.env.OPENAI_API_KEY;
const proxyToken = process.env.ANCHOR_VOICE_PROXY_TOKEN;
const maximumBodyBytes = 32 * 1_024;

if (!openAIKey) {
  throw new Error("OPENAI_API_KEY is required.");
}

function sendJSON(response, status, value) {
  const body = JSON.stringify(value);
  response.writeHead(status, {
    "Content-Type": "application/json; charset=utf-8",
    "Content-Length": Buffer.byteLength(body),
    "Cache-Control": "no-store",
  });
  response.end(body);
}

async function readJSON(request) {
  const chunks = [];
  let byteCount = 0;

  for await (const chunk of request) {
    byteCount += chunk.length;
    if (byteCount > maximumBodyBytes) {
      const error = new Error("Request is too large.");
      error.status = 413;
      throw error;
    }
    chunks.push(chunk);
  }

  try {
    return JSON.parse(Buffer.concat(chunks).toString("utf8"));
  } catch {
    const error = new Error("Valid JSON is required.");
    error.status = 400;
    throw error;
  }
}

function isAuthorized(request) {
  if (!proxyToken) return true;
  return request.headers.authorization === `Bearer ${proxyToken}`;
}

const server = createServer(async (request, response) => {
  const url = new URL(request.url ?? "/", `http://${request.headers.host ?? host}`);

  if (request.method === "GET" && url.pathname === "/health") {
    sendJSON(response, 200, { ok: true });
    return;
  }

  if (request.method !== "POST" || url.pathname !== "/v1/speech") {
    sendJSON(response, 404, { error: "Not found." });
    return;
  }

  if (!isAuthorized(request)) {
    sendJSON(response, 401, { error: "Unauthorized." });
    return;
  }

  try {
    const validation = validateSpeechRequest(await readJSON(request));
    if (!validation.ok) {
      sendJSON(response, 400, { error: validation.error });
      return;
    }

    const openAIResponse = await fetch("https://api.openai.com/v1/audio/speech", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${openAIKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(buildOpenAIRequest(validation.value)),
      signal: AbortSignal.timeout(60_000),
    });

    if (!openAIResponse.ok) {
      const upstreamError = await openAIResponse.json().catch(() => null);
      const upstreamCode =
        typeof upstreamError?.error?.code === "string" ? upstreamError.error.code : undefined;
      console.error(
        `OpenAI speech request failed with status ${openAIResponse.status}${
          upstreamCode ? ` (${upstreamCode})` : ""
        }.`,
      );
      sendJSON(response, 502, {
        error: "Voice generation is temporarily unavailable.",
        ...(upstreamCode ? { code: upstreamCode } : {}),
      });
      return;
    }

    const audio = Buffer.from(await openAIResponse.arrayBuffer());
    response.writeHead(200, {
      "Content-Type": "audio/aac",
      "Content-Length": audio.length,
      "Cache-Control": "no-store",
      "X-Content-Type-Options": "nosniff",
    });
    response.end(audio);
  } catch (error) {
    const status = Number.isInteger(error?.status) ? error.status : 500;
    if (status === 500) {
      console.error(`Voice proxy request failed: ${error?.name ?? "UnknownError"}.`);
    }
    sendJSON(response, status, {
      error: status === 500 ? "Voice generation is temporarily unavailable." : error.message,
    });
  }
});

server.listen(port, host, () => {
  console.log(`Anchor VoiceProxy listening on http://${host}:${port}`);
});
