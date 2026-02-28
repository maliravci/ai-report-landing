#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────
# run-tests.sh — Run all test suites
# ──────────────────────────────────────────────────────────
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TOTAL_FAILS=0
SUITES_RUN=0
SUITES_FAILED=0

run_suite() {
  local script="$1"
  local name
  name=$(basename "$script" .sh)
  
  echo ""
  echo "╔══════════════════════════════════════════════════════════╗"
  printf "║  %-54s  ║\n" "$name"
  echo "╚══════════════════════════════════════════════════════════╝"
  echo ""
  
  SUITES_RUN=$((SUITES_RUN + 1))
  
  if bash "$script"; then
    : # passed
  else
    local fails=$?
    TOTAL_FAILS=$((TOTAL_FAILS + fails))
    SUITES_FAILED=$((SUITES_FAILED + 1))
  fi
}

echo "╔══════════════════════════════════════════════════════════╗"
echo "║         ReportDrafter Landing Page — Test Suite         ║"
echo "╚══════════════════════════════════════════════════════════╝"

run_suite "$SCRIPT_DIR/validate-html.sh"
run_suite "$SCRIPT_DIR/check-links.sh"
run_suite "$SCRIPT_DIR/check-accessibility.sh"
run_suite "$SCRIPT_DIR/check-css.sh"
run_suite "$SCRIPT_DIR/check-js.sh"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ $TOTAL_FAILS -eq 0 ]; then
  printf "\033[32m✓ All %d test suites passed\033[0m\n" "$SUITES_RUN"
else
  printf "\033[31m✗ %d of %d suites had failures (%d total failures)\033[0m\n" \
    "$SUITES_FAILED" "$SUITES_RUN" "$TOTAL_FAILS"
fi

echo ""
exit $TOTAL_FAILS
