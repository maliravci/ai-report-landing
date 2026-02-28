#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────
# check-js.sh — JavaScript quality checks
# ──────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
FAILS=0

pass() { printf "  \033[32mPASS\033[0m %s\n" "$1"; }
fail() { printf "  \033[31mFAIL\033[0m %s\n" "$1"; FAILS=$((FAILS + 1)); }
warn() { printf "  \033[33mWARN\033[0m %s\n" "$1"; }

js="$ROOT/script.js"

echo "=== JavaScript Quality Checks ==="

# ── 1. No var declarations ──
echo ""
echo "-- No var declarations --"
var_count=$(grep -cE '^\s*var\s' "$js" || true)
if [ "$var_count" -eq 0 ]; then
  pass "No 'var' declarations — uses const/let"
else
  fail "Found $var_count 'var' declarations (use const/let)"
  grep -n '^\s*var\s' "$js" | head -5
fi

# ── 2. DOMContentLoaded wrapper ──
echo ""
echo "-- DOMContentLoaded wrapper --"
if grep -qi 'DOMContentLoaded\|readystatechange' "$js"; then
  pass "Code wrapped in DOMContentLoaded"
elif grep -qE '^\(function\s*\(' "$js"; then
  pass "Code wrapped in IIFE (script loaded at end of body)"
else
  # Also check for deferred script or module pattern
  if grep -q 'defer\|type="module"' "$ROOT/index.html"; then
    pass "Script is deferred/module (no DOMContentLoaded needed)"
  else
    fail "Missing DOMContentLoaded or IIFE wrapper"
  fi
fi

# ── 3. DOM element guards ──
echo ""
echo "-- DOM element null guards --"
# Count getElementById calls and check for corresponding null guards
get_calls=$(grep -c 'getElementById\|querySelector' "$js" || true)
guards=$(grep -c 'if (' "$js" || true)
if [ "$guards" -gt 3 ]; then
  pass "Has $guards conditional guards for $get_calls DOM queries"
else
  warn "Only $guards guards for $get_calls DOM queries — verify null safety"
fi

# ── 4. No global variables ──
echo ""
echo "-- No global pollution --"
# Check if all code is inside DOMContentLoaded or IIFE
first_line=$(grep -n 'DOMContentLoaded\|function\|(function' "$js" | head -1 | cut -d: -f1)
if [ -n "$first_line" ] && [ "$first_line" -lt 10 ]; then
  pass "Code scoped early (line $first_line)"
else
  warn "Verify no accidental globals — first scope at line ${first_line:-unknown}"
fi

# ── 5. Passive event listeners ──
echo ""
echo "-- Passive event listeners --"
scroll_listeners=$(grep -c "addEventListener.*scroll\|addEventListener('scroll" "$js" || true)
passive_scroll=$(grep -c "scroll.*passive.*true\|passive.*true.*scroll" "$js" || true)
if [ "$scroll_listeners" -le "$passive_scroll" ] && [ "$scroll_listeners" -gt 0 ]; then
  pass "All $scroll_listeners scroll listener(s) are passive"
elif [ "$scroll_listeners" -eq 0 ]; then
  pass "No scroll listeners"
else
  # Check if non-passive ones are intentional (e.g., wheel with preventDefault)
  warn "$passive_scroll of $scroll_listeners scroll listeners marked passive"
fi

# ── 6. requestAnimationFrame for scroll ──
echo ""
echo "-- Scroll throttling --"
if grep -q 'requestAnimationFrame' "$js"; then
  pass "Uses requestAnimationFrame for scroll throttling"
else
  warn "Consider requestAnimationFrame for scroll handlers"
fi

# ── 7. No console.log left in ──
echo ""
echo "-- No debug logging --"
console_count=$(grep -cE 'console\.(log|debug|info)' "$js" || true)
if [ "$console_count" -eq 0 ]; then
  pass "No console.log/debug/info calls"
else
  fail "Found $console_count console log calls (remove for production)"
  grep -n 'console\.\(log\|debug\|info\)' "$js"
fi

# ── 8. No eval or innerHTML abuse ──
echo ""
echo "-- Security patterns --"
if grep -q 'eval(' "$js"; then
  fail "Found eval() — security risk"
else
  pass "No eval() usage"
fi
innerHTML_count=$(grep -c 'innerHTML' "$js" || true)
if [ "$innerHTML_count" -le 3 ]; then
  pass "innerHTML usage is minimal ($innerHTML_count)"
else
  warn "$innerHTML_count innerHTML usages — verify no user input is injected"
fi

# ── 9. File size ──
echo ""
echo "-- File size --"
size=$(wc -c < "$js" | tr -d ' ')
if [ "$size" -lt 50000 ]; then
  pass "script.js is ${size} bytes (lightweight)"
else
  warn "script.js is ${size} bytes — consider splitting"
fi

# ── 10. Strict mode or module ──
echo ""
echo "-- Strict mode --"
if grep -q "'use strict'\|\"use strict\"" "$js"; then
  pass "Uses strict mode"
else
  warn "Consider adding 'use strict' or using ES modules"
fi

echo ""
if [ $FAILS -eq 0 ]; then
  printf "\033[32m✓ All JavaScript checks passed\033[0m\n"
else
  printf "\033[31m✗ %d JavaScript check(s) failed\033[0m\n" "$FAILS"
fi
exit $FAILS
