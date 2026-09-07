#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

if ! command -v grep >/dev/null 2>&1; then
  echo "grep is required"
  exit 1
fi

PATTERN='(-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----|AKIA[0-9A-Z]{16}|ASIA[0-9A-Z]{16}|AIza[0-9A-Za-z_\-]{35}|xox[baprs]-[0-9A-Za-z-]{10,}|ghp_[0-9A-Za-z]{36}|github_pat_[0-9A-Za-z_]{20,}|sk-[A-Za-z0-9]{20,}|connection_string|client_secret|access_key|secret_key|private_key\s*=|password\s*=)'

EXCLUDES=(
  --exclude-dir=.git
  --exclude-dir=.github
  --exclude-dir=dist
  --exclude-dir=scripts
  --exclude-dir=tests
  --exclude=README.md
  --exclude=TODO.md
  --exclude=DEPLOYMENT.md
  --exclude='*.pub'
  --exclude='*.md'
)

echo "Running secret preflight scan..."
set +e
SCAN_OUTPUT=$(grep -RInE "$PATTERN" "$ROOT_DIR" "${EXCLUDES[@]}")
SCAN_EXIT=$?
set -e

if [[ $SCAN_EXIT -eq 0 && -n "$SCAN_OUTPUT" ]]; then
  echo ""
  echo "Potential secrets detected. Review before deployment:"
  echo "$SCAN_OUTPUT"
  exit 1
fi

echo "No obvious secrets detected in deploy scope."
