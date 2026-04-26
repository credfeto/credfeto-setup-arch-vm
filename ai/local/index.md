<!-- Globally Maintained -->
# Local instructions

This is an index of local instructions that apply to just this project. 
- Ensure consistency across this file with respect to the global instructions.
- This file should be considered an index of local instructions.
- Each file other than this one should be named in the format `<category>.instructions.md` Where `<category>` is the category of the file and all related rules should be listed there.
- `<category>.instructions.md` files should be placed in this directory.
- `<category>.instructions.md` files should maintain a backlink to this file.
- If this is the git@github.com:credfeto/cs-template.git repository, this folder should not have any other instructions than this file.
- This file should not be modified in git@github.com:credfeto/cs-template.git, but can be modified in forks and other repositories as needed.
- The rules above this point in the file should be considered global rules.

## Instruction Files
<!-- Locally Maintained -->
| File | Description |
|------|-------------|
| [arch-linux.instructions.md](arch-linux.instructions.md) | Arch Linux administration, pacman workflows, rolling-release best practices, kernel and systemd specifics |
| [git-workflow.instructions.md](git-workflow.instructions.md) | Repo-specific commit rules: no empty commits, no squash, delete branches on PR close, CI monitoring, co-authored-by trailer |
| [install-script.instructions.md](install-script.instructions.md) | Idempotency, hardening scope, live-and-persistent change pattern, POSIX sh style, shellcheck/checkbashisms |
| [docker-compatibility.instructions.md](docker-compatibility.instructions.md) | Settings that must never break Docker or container networking |
| [output-formatting.instructions.md](output-formatting.instructions.md) | ok / skip / die helper functions and coloured indicators for the install script |
| [changelog.instructions.md](changelog.instructions.md) | Repo-specific changelog rules: install-script audience, when to add/skip entries, valid types including Deployment Changes |
| [github-actions.instructions.md](github-actions.instructions.md) | Super-linter checks required, shell script pitfalls (SC2129, pipefail), GitHub Models API endpoint |
| [pull-request-template.instructions.md](pull-request-template.instructions.md) | PR body structure, auto-generated description via composite action, maintain-pr-description workflow rules |
| [testing.instructions.md](testing.instructions.md) | Test VM at arch-vm-test.lan (user: test, sudo), when and how to validate Ansible role and install script changes |
