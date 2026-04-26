---
description: 'Rules for writing and modifying GitHub Actions workflow files.'
applyTo: '**'
---

[Back to Local Instructions Index](index.md)

# GitHub Actions Workflow Guidelines

## Linting Requirements

**Every GitHub Actions workflow file must pass all of the following super-linter checks before committing:**

- `GITHUB_ACTIONS` — actionlint validates workflow syntax and expression correctness
- `YAML` — yamllint validates YAML formatting
- `BASH` / `shellcheck` — any `run:` blocks containing shell scripts must pass shellcheck

Run the super-linter locally or ensure CI passes before marking a PR ready.

## Shell Scripts in `run:` Blocks

- Multi-line shell scripts embedded in `run:` steps are linted by shellcheck as part of the `GITHUB_ACTIONS` super-linter check.
- Avoid multiple individual `>> file` redirects — group them into a single `{ } >> file` block (fixes SC2129).
- Avoid piping commands through `tail`, `grep`, or other filters that swallow exit codes — this masks failures (use `set -o pipefail` or restructure to avoid pipes on install commands).

## GitHub Models API

- Use `https://models.inference.ai.azure.com/chat/completions` as the endpoint.
- Model names do **not** include the provider prefix — use `gpt-4o` or `gpt-4o-mini`, not `openai/gpt-4o`.
