---
description: 'Git branching, commit, and PR rules for this repository.'
applyTo: '**'
---

> **Index:** `.ai-instructions` is the index of all instruction files in this repository.

# Git Workflow

## Git Identity Check (MANDATORY before any commit)

Before making any git commit, verify the configured identity is correct and GPG signing is enabled:

```bash
CURRENT_EMAIL=$(git config user.email)
if [ "$CURRENT_EMAIL" = "andy@nanoclaw.ai" ] || [ -z "$CURRENT_EMAIL" ]; then
  echo "ERROR: Git is configured with the wrong identity ($CURRENT_EMAIL). Aborting."
  exit 1
fi
if [ "$(git config commit.gpgsign)" != "true" ]; then
  echo "ERROR: GPG signing is not enabled. Aborting."
  exit 1
fi
```

**If either check fails: stop all work immediately, do not commit, and report the misconfiguration.**

---

**Never commit directly to `main`.** All changes must be made on a feature branch.

Before starting any work:
1. Switch to `main`: `git checkout main`
2. Pull the latest: `git pull`
3. Create a feature branch: `git checkout -b <branch-name>`
4. Make all commits on that branch
5. Push the branch and open a PR — do not push to `main` directly

**If asked to fix or extend something already on an open branch, commit to that same branch and push to origin — do not create a new branch.**

## Commit Messages

- Follow the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) format.
- Keep commits small and focused, each with a descriptive message.
- **Never push empty commits** — always verify there are actual staged changes before committing; if nothing is staged, do not commit.
- **Run tests before every push** — confirm all tests pass before pushing any commit; fix failures before pushing, never push broken code.
- **Monitor CI after every push** — after pushing, check the PR's CI status; if any check fails, read the failure logs, fix the cause locally, re-run tests, and push again; report to the user if CI fails 3 times on the same PR without resolution.
- **One commit per review comment** — when addressing PR review comments, each individual comment must be resolved in its own separate commit; do not batch multiple review comments into one commit.
- Always include the Co-authored-by trailer:
  ```
  Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
  ```

## Issue Assignment

- Before picking up an issue, assign it to yourself: `gh issue edit <number> --add-assignee @me`
- Do not pick up issues already assigned to someone else.
- Do not work on issues labelled `on-hold`.

## Multi-Agent Implementation and Review Pattern

All implementation work uses a two-agent loop:

1. **Implementer agent** — reads all instruction files, implements the issue, commits (GPG signed), pushes, opens PR.
2. **Reviewer agent** — reads all instruction files, runs `git diff origin/main...HEAD`, checks every change against every rule, fixes violations, commits, pushes. Reports `clean` if no violations found.
3. **Repeat** the reviewer step until it reports `clean` (capped at 5 iterations).

## Pull Requests

- PRs must be reviewed by at least one other maintainer before merging.
- All changes must be tested and verified before merging.
- Always add yourself as assignee when creating or updating a PR: `gh pr edit <number> --add-assignee @me`
