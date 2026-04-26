---
description: 'Git branching, commit, and PR rules for this repository.'
applyTo: '**'
---

[Back to Local Instructions Index](index.md)

# Git Workflow

> The global [git.instructions.md](../global/git.instructions.md) and [task-workflow.instructions.md](../global/task-workflow.instructions.md) cover identity checks, branching strategy, Conventional Commits format, issue/PR assignment, and the multi-agent pattern. The rules below are additional rules specific to this repository.

## Commit Messages

- **Never push empty commits** — always verify there are actual staged changes before committing; if nothing is staged, do not commit.
- **Never squash commits** — do not squash, fixup, or otherwise rewrite history; the full commit history must be preserved so the complete journey is visible.
- **Delete branches when closing PRs** — when closing (abandoning) a PR, always delete the associated remote branch immediately after: `gh pr close <number> && git push origin --delete <branch>`
- **Monitor CI after every push** — after pushing, check the PR's CI status; if any check fails, read the failure logs, fix the cause locally, re-run tests, and push again; report to the user if CI fails 3 times on the same PR without resolution.
- **One commit per review comment** — when addressing PR review comments, each individual comment must be resolved in its own separate commit; do not batch multiple review comments into one commit.
- Always include the Co-authored-by trailer:
  ```
  Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
  ```

## Issue Assignment

- Do not work on issues labelled `on-hold`.

## Pull Requests

- PRs must be reviewed by at least one other maintainer before merging.
- All changes must be tested and verified before merging.

