---
name: summarize-text
description: Summarize a block of text or a document into concise, structured bullet points. Use when the user asks to summarize, condense, TL;DR, or extract key points from text, an article, notes, or a transcript.
license: MIT
metadata:
  author: nakai
  version: "0.1.0"
---

# Summarize Text

Produce a concise, faithful summary of the provided text.

## Instructions

1. Read the full text the user provided (pasted content, an uploaded file, or a referenced document).
2. Identify the main thesis and the supporting points that matter.
3. Output in this structure:
   - **One-line TL;DR** — a single sentence capturing the core message.
   - **Key points** — 3–7 bullets, each a complete, standalone statement.
   - **Action items / open questions** — only if the source contains them; omit the section otherwise.
4. Preserve the source's meaning. Do not add facts, opinions, or interpretation that is not in the text.
5. Match the length to the input: short input → short summary. Never pad.

## Constraints

- Keep bullets tight; no filler like "The text discusses...".
- If the text is ambiguous or empty, say so instead of guessing.
- Keep the summary substantially shorter than the source.

<!--
This is an EXAMPLE skill that ships with the scaffold. It uses only portable
Markdown instructions, so it behaves identically in Claude Code, the Claude
desktop app, and the Claude web app. Replace or delete it once you add your own.
-->
