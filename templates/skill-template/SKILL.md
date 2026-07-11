---
name: skill-template
description: REPLACE THIS. Describe what the skill does AND when to use it, with keywords the model would match on. Max 1024 chars. Example — "Generate a conventional-commit message from staged changes. Use when the user asks for a commit message or to commit."
# --- Optional fields below. Delete any you do not use. ---
# license: MIT
# metadata:
#   author: nakai
#   version: "0.1.0"
# --- Claude Code-only extensions (ignored by the Claude apps; safe to keep) ---
# disable-model-invocation: true   # only the user can trigger it via /name (good for side-effecting actions)
# user-invocable: false            # only Claude can trigger it (good for background knowledge)
# allowed-tools: Read Grep         # pre-approved tools while active
# argument-hint: "[file] [format]"
---

# Skill Title

State the task or knowledge here. Keep the body under ~500 lines; move long
reference material into `references/` and load it on demand.

## Instructions

1. First step.
2. Second step.
3. ...

## Notes

- `name:` MUST equal this folder's name (Agent Skills requirement): lowercase
  letters, numbers, and hyphens only; no leading/trailing or consecutive hyphens.
- Put the most important use-case keywords first in `description:` — the listing
  is truncated at ~1024 chars.

<!--
Optional supporting files (all loaded only when referenced):
  scripts/     executable helpers (Bash/Python/JS) — reference with a relative path
  references/  detailed docs the model reads on demand
  assets/      templates, images, data files
Reference them from this file, e.g. "See [reference](references/REFERENCE.md)".

Portability note: dynamic context (!`cmd`), context: fork, and allowed-tools are
Claude Code features. They are ignored when the skill is uploaded to the Claude
apps, so a skill that relies on them will not behave the same there.
-->
