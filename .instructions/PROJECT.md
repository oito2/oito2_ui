# Project Rules

Rules defined for this project. They take precedence over `AGENTS.md` and over the standards in `.instructions/` — use them to add a rule or to change a default. Perci creates this file once and never rewrites it.

<!-- One concise bullet per rule, under a heading for its topic. When a rule replaces a default, say which. -->

## Session Start

- Load the project memory with Sync82 (`load_project_context`, marker `.sync82.json`) before any task; update it at the end of the session.
- The repository syncs only with GitHub (no MEGAsync); git history is the source of truth for the code.

## Developer Notes

- Personal notes, plans, test procedures and build bundles live in `/srv/workspace/MyProjects/DevNotes/oito2_ui/` (outside the repository). This folder replaces the former `.dev/` directory; `.dev/` must not be recreated.
- Notes in that folder may be written in pt-BR (exception to the English-only documentation rule in `AGENTS.md`, which applies to files inside the repository).
- `.references/` (yaru.dart, Ark UI, flutter_packages clones), `.sync82.json` and the whole `.claude/` folder stay out of git (machine-specific).
- Commit flow: write the commit message to `/srv/workspace/MyProjects/DevNotes/oito2_ui/commit-msg.txt` and hand the user `git add -A; git commit -F <that file>; git push`.

## Standards

- The needs of oito2_ui override `.instructions/FLUTTER.md` (outdated for this project). Record every deviation in the Sync82 memory and update `FLUTTER.md` only at the end of the project (replaces the "mandatory standard" rule of `AGENTS.md` for that file).
- Already recorded deviations: theme presets live in `oito2_ui_themes`; permanent golden tests; Linux runner defaults to Skia; license holder "OITO2"; `flutter_lucide` instead of `lucide_icons_flutter`; `oito2_ui` instead of `shadcn_ui`; `material_ui` instead of `flutter/material`.

## Source Files

- Every hand-written `.dart` file, and every hand-maintained native runner file of `example/`, starts with the GPL-3.0 header "Copyright (C) 2026  OITO2" (two spaces, uppercase). Generated plugin registrants and `windows/runner/resource.h` are excluded.
- Dart doc comments are prose with `[param]` references, "Returns ..." and "Throws an [X] when ..."; no `@param` tags.
- Every clickable control shows the click (hand) cursor on all platforms: `WidgetStateMouseCursor.clickable` on InkWells and buttons, `MouseRegion(cursor: SystemMouseCursors.click)` on GestureDetector-based taps.

## Testing & Verification

- Every observable fix gets a regression test proven to fail against the previous code: extract HEAD with `git archive HEAD | tar -x` into the scratchpad (never `git stash`).
- Run package tests per package, never from the workspace root (the `ink_sparkle.frag` asset fails there).
- Run the full checks before reporting: `dart format`, `dart analyze`, per-package tests, `dart run tool/generate_docs.dart --check`, and the web build with `tool/check_web_build.dart` when the showcase changes.
- After any lib doc comment or CHANGELOG change, regenerate the showcase docs with `dart run tool/generate_docs.dart`.
- Goldens use the tolerant comparator from `oito2_ui_test_utils`; avoid indeterminate spinners and `DateTime.now()` in goldens.
- Local web checks: copy `example/build/web` to the scratchpad, serve with `python3 -m http.server`, stop it by its listening PID (`ss -ltnp`); never `pkill -f`.

## Agent Conduct

- Never automate clicks or input on the user's real desktop; manual desktop checks are the user's.
- Never read or commit secrets.
- When a session permission rule denies a command (e.g. `tar`), hand the user the command instead of working around it.
- Genuine choices go through the selectable-question tool with a **[RECOMENDADO]** option.
- Git commit trailer: `Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>` (or the current model's name).
