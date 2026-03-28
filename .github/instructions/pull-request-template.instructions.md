---
description: 'Rules for pull request descriptions — template usage and automated description generation.'
applyTo: '**'
---

> **Index:** `.ai-instructions` is the index of all instruction files in this repository.

# Pull Request Template

**Every PR opened by an automated workflow must use `.github/PULL_REQUEST_TEMPLATE.md`** as its body structure, with the Description section filled in by Copilot.

## How to generate the description

Before creating a PR, call the shared `generate-pr-description` composite action with the
base and head SHAs. It diffs the two commits via the GitHub API and uses GitHub Copilot
(GitHub Models) to write a concise description:

```yaml
- name: "Generate PR description"
  id: describe
  uses: ./.github/actions/generate-pr-description
  with:
    base_sha: ${{ steps.push.outputs.base_sha }}
    head_sha: ${{ steps.push.outputs.head_sha }}
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

## How to compose the PR body

Read the template, fill the `# Description` section with the generated text, and pass the
complete body to `gh pr create --body`:

```sh
BODY=$(python3 - << 'PYEOF'
import os, re
template = open('.github/PULL_REQUEST_TEMPLATE.md').read().rstrip()
desc = os.environ.get('DESCRIPTION', '').strip()
marker = '<!-- description-auto-generated-by-copilot -->'
maintained = '<!-- maintained-by-copilot -->'
if desc:
    body = re.sub(
        r'(^#{1,3}\s+Description\s*\n)([\s\S]*?)(?=\n#{1,3}\s|$)',
        lambda m: f"{m.group(1)}{desc}\n\n{marker}\n\n",
        template, flags=re.MULTILINE)
else:
    body = template
print(body + f'\n\n{maintained}')
PYEOF
)
gh pr create --base main --head "${BRANCH}" --title "..." --body "${BODY}"
```

## Requirements for the calling job

```yaml
permissions:
  pull-requests: write
  contents: read
  models: read
```

## Rules

- Never hardcode a static PR body — always compose from the template with a generated description.
- Generate the description **before** creating the PR so the body is complete at creation time.
- The repo must be checked out before calling the action (local composite action at `./.github/actions/generate-pr-description`).
- For `maintain-pr-description.yml`: call the action then update the PR body inline using the `description` output.
