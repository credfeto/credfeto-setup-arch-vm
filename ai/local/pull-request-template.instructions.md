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

## Creating a PR

When explicitly creating a pull request (e.g. via `gh pr create`), the body **must**:

- Be built from `PULL_REQUEST_TEMPLATE.md` as its base structure — never supply a freeform body.
- Include all sections defined in the template (`# Description`, `# How Has This Been Tested`,
  `# Types of changes`, `## Deployment Configuration Changes`, `# Checklist`).
- Have the `# Description` section filled with a generated description (via the composite action)
  and the `<!-- description-auto-generated-by-copilot -->` marker.
- End with the `<!-- maintained-by-copilot -->` marker so subsequent workflow runs can manage it.

## Updating an Existing PR Description

When updating a PR body (not creating it for the first time), apply the same logic used by
`.github/workflows/maintain-pr-description.yml`.

> **Important:** If the logic in `maintain-pr-description.yml` is ever changed, this instruction
> file **must** be updated to reflect that new logic. These rules are derived from and must stay
> in sync with that workflow — the workflow is the authoritative source of truth for update
> behaviour.

1. **Only manage bodies that contain `<!-- maintained-by-copilot -->`.**  
   If the marker is absent, do not touch the PR body.

2. **Apply the template when the body is empty or still the bare template.**  
   Compare the current body (after stripping both markers) against the content of
   `PULL_REQUEST_TEMPLATE.md`. If they match, or the body is blank, reset to:
   ```
   <template content>

   <!-- maintained-by-copilot -->
   ```

3. **Never replace a manually-written description.**  
   If the `# Description` section has real content and the
   `<!-- description-auto-generated-by-copilot -->` marker is absent, leave the section
   unchanged.

4. **The updated body must always conform to `PULL_REQUEST_TEMPLATE.md`.**  
   Never write a PR body whose structure does not match the template — all sections
   (`# Description`, `# How Has This Been Tested`, `# Types of changes`,
   `## Deployment Configuration Changes`, `# Checklist`) must be present.

5. **Re-generate the description via the composite action, do not hand-write it.**  
   Call `./.github/actions/generate-pr-description` with the PR's `base_sha` and
   `head_sha`, then insert the output into the `# Description` section followed by
   `<!-- description-auto-generated-by-copilot -->`.

## Rules

- Never hardcode a static PR body — always compose from the template with a generated description.
- Generate the description **before** creating the PR so the body is complete at creation time.
- The repo must be checked out before calling the action (local composite action at `./.github/actions/generate-pr-description`).
- For `maintain-pr-description.yml`: call the action then update the PR body inline using the `description` output.
- When updating a PR description, never produce a body that omits or restructures the sections defined in `PULL_REQUEST_TEMPLATE.md`.
