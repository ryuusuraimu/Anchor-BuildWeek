export const OPENAI_VOICES = Object.freeze([
  "alloy",
  "ash",
  "ballad",
  "coral",
  "echo",
  "fable",
  "nova",
  "onyx",
  "sage",
  "shimmer",
  "verse",
  "marin",
  "cedar",
]);

const MAX_TEXT_LENGTH = 4_096;

export function validateSpeechRequest(value) {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    return { ok: false, error: "A JSON object is required." };
  }

  const text = typeof value.text === "string" ? value.text.trim() : "";
  if (!text) {
    return { ok: false, error: "Text is required." };
  }
  if (text.length > MAX_TEXT_LENGTH) {
    return { ok: false, error: `Text must be ${MAX_TEXT_LENGTH} characters or fewer.` };
  }

  const voice = typeof value.voice === "string" ? value.voice.toLowerCase() : "";
  if (!OPENAI_VOICES.includes(voice)) {
    return { ok: false, error: "The selected voice is not supported." };
  }

  return { ok: true, value: { text, voice } };
}

export function buildOpenAIRequest({ text, voice }) {
  return {
    model: "gpt-4o-mini-tts",
    voice,
    input: text,
    instructions:
      "Speak calmly, clearly, and steadily. Use a warm, grounded tone. Keep natural pauses between support instructions. Do not dramatize or sound urgent.",
    response_format: "aac",
  };
}
