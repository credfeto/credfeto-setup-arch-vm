---
description: 'Rules for pull request descriptions — template usage and automated description generation.'
applyTo: '**'
---

> **Index:** `.ai-instructions` is the index of all instruction files in this repository.

# Pull Request Template

**Every PR opened by an automated workflow must use `.github/PULL_REQUEST_TEMPLATE.md`** as its body structure, with the Description section filled in by Copilot.

## How to apply the template

Use the shared composite action after creating a PR:

```yaml
- name: "Apply PR template and generate description"
  uses: ./.github/actions/apply-pr-template
  with:
    pull_number: ${{ steps.create-pr.outputs.pr_number }}
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

The action (`.github/actions/apply-pr-template`) handles everything:
- Reads the template from `.github/PULL_REQUEST_TEMPLATE.md` via the GitHub API
- Applies it to the PR body if not already present
- Calls GitHub Models (Copilot) to generate a concise description and fills in the `# Description` section
- Is idempotent — safe to call multiple times

## Requirements for the calling job

The job that calls this action must have these permissions:

```yaml
permissions:
  pull-requests: write
  contents: read
  models: read
```

## Rules

- Never hardcode a PR body in `gh pr create --body` or `github.rest.pulls.create` — use the action instead.
- The action must be called only after the PR has been created (it needs a PR number).
- The repo must be checked out before calling the action (it is a local composite action at `./.github/actions/apply-pr-template`).
