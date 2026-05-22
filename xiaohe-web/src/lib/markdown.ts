import { marked } from "marked";
import DOMPurify from "dompurify";

/**
 * Render markdown → sanitized HTML.
 *
 * Notes for streaming use:
 *  - Called on every typewriter frame, so it must be cheap. marked + DOMPurify
 *    over a ~500-char string is well under 1ms on modern hardware.
 *  - marked itself ignores unclosed inline markers (a trailing `**` won't
 *    suddenly become <strong>), so partial output during typewriter is safe.
 *  - Raw HTML in the source still survives marked; DOMPurify is what actually
 *    keeps a malicious assistant response (or a future tool that echoes user
 *    text) from injecting <script>.
 */
marked.setOptions({
  gfm: true,
  breaks: true,
});

/**
 * Streaming-safe markdown render.
 *
 * Problem: while we're typewriter-revealing AI text character by character, a
 * partial input like "...建议是 **手" leaves marked with an unopened bold
 * marker. Different marked versions either swallow the trailing fragment or
 * render literal `**手`, neither of which the user reads as "the AI is still
 * typing the bold word". Same story for ``` code fences that haven't closed
 * yet, and for trailing unfinished markdown list rows.
 *
 * Fix: before parsing, do an "optimistic close" — find unpaired inline markers
 * and append their closers temporarily. Each frame re-parses, so once the
 * real closer arrives, the speculative one becomes redundant and is dropped
 * (since the real one is now in the input).
 *
 * We skip counting markers that sit inside fenced or inline code so we don't
 * try to "close" the `**` inside a code snippet.
 */
function closeStreamingMarkers(src: string): string {
  let s = src;

  // (1) unclosed ``` fenced code block — close it on a new line
  const fenceCount = (s.match(/```/g) ?? []).length;
  if (fenceCount % 2 === 1) {
    s += s.endsWith("\n") ? "```" : "\n```";
  }

  // (2) build a mask of code regions to ignore when counting inline markers.
  //     mask[i] === true means index i is inside fenced/inline code.
  const mask = new Array<boolean>(s.length).fill(false);
  const fenceRe = /```[\s\S]*?```/g;
  for (let m; (m = fenceRe.exec(s)); ) {
    for (let i = m.index; i < m.index + m[0].length; i++) mask[i] = true;
  }
  const inlineCodeRe = /`[^`\n]+`/g;
  for (let m; (m = inlineCodeRe.exec(s)); ) {
    for (let i = m.index; i < m.index + m[0].length; i++) mask[i] = true;
  }

  // (3) count `**` outside code regions; if odd, append a closing `**`
  let boldCount = 0;
  for (let i = 0; i < s.length - 1; i++) {
    if (s[i] === "*" && s[i + 1] === "*" && !mask[i]) {
      boldCount++;
      i++; // consume the second *
    }
  }
  if (boldCount % 2 === 1) s += "**";

  // (4) unpaired single backtick (excluding triples already accounted for)
  const noTriples = s.replace(/```/g, "");
  const backtickCount = (noTriples.match(/`/g) ?? []).length;
  if (backtickCount % 2 === 1) s += "`";

  return s;
}

export function renderMarkdown(src: string): string {
  if (!src) return "";
  const closed = closeStreamingMarkers(src);
  const raw = marked.parse(closed, { async: false }) as string;
  return DOMPurify.sanitize(raw, {
    ADD_ATTR: ["target", "rel"],
    FORBID_TAGS: ["style", "script", "iframe", "form", "input", "button"],
  });
}
