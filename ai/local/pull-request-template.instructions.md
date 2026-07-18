---
description: 'Rules for pull request descriptions — template usage and description writing.'
applyTo: '**'
---

# Pull Request Template

[Back to Local Instructions Index](index.md)

**Every PR must use `.github/PULL_REQUEST_TEMPLATE.md`** as its body structure.

## Current state: no automated description generation

There is no live automation that generates or maintains PR descriptions in this repo.
`.github/workflows/maintain-pr-description.yml` was deleted from `main` on 2026-06-17
(commit `bead402`, "Removed: Obsolete workflow") and nothing currently calls it. The
`generate-pr-description` composite action (`.github/actions/generate-pr-description/`)
still exists in the repo but is orphaned — no workflow references it, so it never runs.

Do not assume a `<!-- maintained-by-copilot -->` marker in a PR body means anything is
actively managing it — nothing is. Do not add that marker, or the
`<!-- description-auto-generated-by-copilot -->` marker, to a body you write by hand;
they would falsely imply automated maintenance that doesn't exist.

## How to compose the PR body

Read `.github/PULL_REQUEST_TEMPLATE.md` and fill in every section yourself:

- `# Description`: hand-write a concise summary of what changed and why, from the diff
  and commit messages.
- `# How Has This Been Tested`: describe what was actually done (or explicitly note it
  wasn't, e.g. a test VM being unavailable) — never tick a box that doesn't reflect reality.
- `# Types of changes`, `## Deployment Configuration Changes`, `# Checklist`: fill in
  based on the actual change.

The body must always conform to the template's structure — never a freeform body, and
never omit a section defined in the template.

## If the automation is ever restored

If `maintain-pr-description.yml` (or an equivalent) is reintroduced, update this file to
describe its actual logic — the workflow, not this file, is the source of truth for how
descriptions get generated/maintained. Until then, this file describes the manual process
above.
