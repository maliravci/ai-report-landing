#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────
# check-css.sh — CSS quality & standards checks
# ──────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
FAILS=0

pass() { printf "  \033[32mPASS\033[0m %s\n" "$1"; }
fail() { printf "  \033[31mFAIL\033[0m %s\n" "$1"; FAILS=$((FAILS + 1)); }
warn() { printf "  \033[33mWARN\033[0m %s\n" "$1"; }

css="$ROOT/styles.css"
shared="$ROOT/pages/shared.css"

echo "=== CSS Quality Checks ==="

# ── 1. CSS custom properties (design tokens) ──
echo ""
echo "-- Design tokens --"
required_tokens="primary primary-dark accent max-width nav-height"
for token in $required_tokens; do
  if grep -q -- "--${token}:" "$css"; then
    val=$(grep -oE -- "--${token}:\s*[^;]+" "$css" | head -1)
    pass "$val"
  else
    fail "Missing design token: --$token"
  fi
done

# ── 2. Hardcoded colors (should use variables) ──
echo ""
echo "-- Hardcoded color check --"
# Count hex colors outside :root
outside_root=$(awk '/:root/,/^}/' "$css" | wc -l)
total_hex=$(grep -cE '#[0-9a-fA-F]{3,8}' "$css" || true)
root_hex=$(awk '/:root/,/^}/' "$css" | grep -cE '#[0-9a-fA-F]{3,8}' || true)
non_root_hex=$((total_hex - root_hex))
if [ "$non_root_hex" -lt 20 ]; then
  pass "Only $non_root_hex hex colors outside :root (token usage is good)"
else
  warn "$non_root_hex hex colors outside :root — consider using CSS variables"
fi

# ── 3. !important usage ──
echo ""
echo "-- !important usage --"
important_count=$(grep -c '!important' "$css" || true)
if [ "$important_count" -eq 0 ]; then
  pass "No !important in styles.css"
elif [ "$important_count" -le 3 ]; then
  warn "$important_count !important declarations (acceptable)"
else
  fail "$important_count !important declarations (reduce if possible)"
fi

# ── 4. Responsive breakpoints ──
echo ""
echo "-- Responsive breakpoints --"
breakpoints=$(grep -oE '@media[^{]+' "$css" | sort -u)
bp_count=$(echo "$breakpoints" | grep -c 'max-width\|min-width' || true)
if [ "$bp_count" -ge 2 ]; then
  pass "$bp_count responsive breakpoints defined"
  echo "$breakpoints" | head -5 | while IFS= read -r bp; do
    printf "       %s\n" "$bp"
  done
else
  fail "Insufficient responsive breakpoints (found $bp_count)"
fi

# ── 5. Key widths covered ──
echo ""
echo "-- Required widths --"
for width in '768' '480'; do
  if grep -q "$width" "$css"; then
    pass "Breakpoint at ${width}px exists"
  else
    warn "No breakpoint at ${width}px"
  fi
done

# ── 6. No inline styles in HTML ──
echo ""
echo "-- Inline styles in HTML --"
while IFS= read -r f; do
  rel="${f#"$ROOT"/}"
  inline=$(grep -cn 'style="' "$f" || true)
  if [ "$inline" -eq 0 ]; then
    pass "$rel has no inline styles"
  else
    fail "$rel has $inline inline style(s)"
  fi
done < <(find "$ROOT" -name '*.html' -not -path '*/.git/*' -not -path '*/node_modules/*' | sort)

# ── 7. CSS file size check ──
echo ""
echo "-- File size --"
for f in "$css" "$shared"; do
  if [ -f "$f" ]; then
    rel="${f#"$ROOT"/}"
    size=$(wc -c < "$f" | tr -d ' ')
    if [ "$size" -lt 100000 ]; then
      pass "$rel is ${size} bytes (lightweight)"
    else
      warn "$rel is ${size} bytes — consider splitting"
    fi
  fi
done

# ── 8. Consistent box-sizing ──
echo ""
echo "-- Box sizing --"
if grep -q 'box-sizing' "$css"; then
  pass "box-sizing rule present"
else
  warn "Consider adding box-sizing: border-box reset"
fi

echo ""
if [ $FAILS -eq 0 ]; then
  printf "\033[32m✓ All CSS checks passed\033[0m\n"
else
  printf "\033[31m✗ %d CSS check(s) failed\033[0m\n" "$FAILS"
fi
exit $FAILS
