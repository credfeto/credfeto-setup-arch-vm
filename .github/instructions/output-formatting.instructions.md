---
description: 'Output formatting rules for the install script — coloured indicators for applied, skipped, and failed steps.'
applyTo: '**'
---

> **Index:** `.ai-instructions` is the index of all instruction files in this repository.

# Output Formatting

The `install` script uses three helper functions for all status output. Plain `echo` must not be used for status messages.

## Indicators

| Function | Symbol | Colour | When to use |
|---|---|---|---|
| `ok "message"` | ✓ | Green | A setting was successfully applied or written |
| `skip "message"` | ● | Yellow | A setting was already correct — no change needed |
| `die "message"` | ✗ | Red | A fatal error occurred — prints to stderr and exits |

## Implementation

These functions are defined at the top of the `install` script:

```sh
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
RESET='\033[0m'

ok()   { printf "${GREEN}✓${RESET} %s\n" "$*"; }
skip() { printf "${YELLOW}●${RESET} %s\n" "$*"; }
die()  { printf "${RED}✗${RESET} %s\n" "$*" >&2; exit 1; }
```

## Rules

- Every action that applies a change must call `ok` on success.
- Every action that finds the configuration already correct must call `skip`.
- Every unrecoverable error must call `die` (never use plain `echo` for errors).
- Section header lines (`echo "Configuring X..."`) are acceptable as progress indicators before a long operation.
