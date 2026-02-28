# Testing Scripts

Automated tests for the ReportDrafter landing page. All scripts run from the project root.

## Quick Start

```bash
bash tests/run-tests.sh
```

## Individual Tests

| Script | What it checks |
|--------|---------------|
| `validate-html.sh` | HTML structure: doctype, lang, meta tags, semantic landmarks, heading hierarchy, duplicate IDs, alt attributes, JSON-LD validity |
| `check-links.sh` | Internal links, anchor targets, navigation consistency, broken file references |
| `check-accessibility.sh` | ARIA attributes, focus styles, color contrast tokens, keyboard navigation, form labels, touch targets |
| `check-css.sh` | CSS variables usage, unused tokens, responsive breakpoints, `!important` usage, vendor prefix needs |
| `check-js.sh` | JavaScript quality: no `var`, DOM guards, no global pollution, event listener patterns |

## Requirements

- Bash 4+ (macOS default zsh also works)
- Standard Unix tools: `grep`, `sed`, `awk`, `find`
- No external dependencies required

## Exit Codes

- `0` — all checks passed
- `1` — one or more checks failed (details printed to stdout)

## Adding Tests

Each script follows the same pattern:
1. Define check functions that print `PASS` or `FAIL` messages
2. Increment a failure counter on `FAIL`
3. Exit with the failure count

To add a new test file, create it in `tests/` and add it to `run-tests.sh`.
