import assert from "node:assert/strict";
import test from "node:test";
import { buildOpenAIRequest, validateSpeechRequest } from "./contract.mjs";

test("accepts prepared text and a supported voice", () => {
  const result = validateSpeechRequest({ text: "  Please speak softly.  ", voice: "Cedar" });

  assert.deepEqual(result, {
    ok: true,
    value: { text: "Please speak softly.", voice: "cedar" },
  });
});

test("rejects empty text and unknown voices", () => {
  assert.equal(validateSpeechRequest({ text: "", voice: "cedar" }).ok, false);
  assert.equal(validateSpeechRequest({ text: "Help", voice: "unknown" }).ok, false);
});

test("builds the constrained OpenAI speech request", () => {
  const request = buildOpenAIRequest({ text: "Please speak softly.", voice: "marin" });

  assert.equal(request.model, "gpt-4o-mini-tts");
  assert.equal(request.voice, "marin");
  assert.equal(request.response_format, "aac");
  assert.match(request.instructions, /calmly/);
});
