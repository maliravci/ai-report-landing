#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────
# check-accessibility.sh — Accessibility baseline checks
# ──────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
FAILS=0

pass() { printf "  \033[32mPASS\033[0m %s\n" "$1"; }
fail() { printf "  \033[31mFAIL\033[0m %s\n" "$1"; FAILS=$((FAILS + 1)); }
warn() { printf "  \033[33mWARN\033[0m %s\n" "$1"; }

html_files() {
  find "$ROOT" -name '*.html' -not -path '*/.git/*' -not -path '*/node_modules/*' | sort
}

idx="$ROOT/index.html"
css="$ROOT/styles.css"

echo "=== Accessibility Checks ==="

# ── 1. Skip-to-content link ──
echo ""
echo "-- Skip link --"
if grep -q 'skip' "$idx" && grep -q 'main-content\|#main' "$idx"; then
  pass "Skip-to-content link present"
else
  fail "Missing skip-to-content link"
fi

# ── 2. ARIA labels on icon-only buttons ──
echo ""
echo "-- ARIA labels on buttons --"
while IFS= read -r f; do
  rel="${f#"$ROOT"/}"
  # Find buttons without text content or aria-label
  buttons_no_aria=$(grep -n '<button' "$f" | grep -v 'aria-label' | grep -v 'aria-labelledby' || true)
  # This is a heuristic — buttons with text content are fine without aria-label
  if [ -z "$buttons_no_aria" ]; then
    pass "$rel — all buttons have aria-label or text"
  else
    # Check if they have text content (not just icons)
    while IFS= read -r line; do
      linenum=$(echo "$line" | cut -d: -f1)
      # If button has SVG or no visible text, it needs aria-label
      if echo "$line" | grep -qE '<svg|class=".*icon' && ! echo "$line" | grep -q 'aria-label'; then
        fail "$rel:$linenum — icon button without aria-label"
      fi
    done <<< "$buttons_no_aria"
  fi
done < <(html_files)

# ── 3. Focus styles in CSS ──
echo ""
echo "-- Focus styles --"
if grep -q ':focus' "$css"; then
  pass "styles.css has :focus rules"
else
  fail "styles.css missing :focus rules"
fi
if grep -q 'focus-visible' "$css"; then
  pass "styles.css uses :focus-visible"
else
  warn "styles.css could use :focus-visible for keyboard-only focus"
fi

# ── 4. Color contrast tokens ──
echo ""
echo "-- Color contrast (design tokens) --"
# Check that text colors aren't too light on white background
if grep -q '\-\-text:' "$css"; then
  text_color=$(grep -oE '\-\-text:\s*#[0-9a-fA-F]+' "$css" | head -1 | grep -oE '#[0-9a-fA-F]+')
  if [ -n "$text_color" ]; then
    pass "Text color token defined: $text_color"
  fi
fi
# Verify primary colors exist
for token in 'primary' 'primary-dark' 'accent'; do
  if grep -q -- "--${token}:" "$css"; then
    pass "Color token --$token defined"
  else
    fail "Color token --$token missing"
  fi
done

# ── 5. Form labels ──
echo ""
echo "-- Form labels --"
while IFS= read -r f; do
  rel="${f#"$ROOT"/}"
  inputs=$(grep -c '<input\|<textarea\|<select' "$f" 2>/dev/null || true)
  if [ "$inputs" -gt 0 ]; then
    labels=$(grep -c '<label\|aria-label\|aria-labelledby' "$f" 2>/dev/null || true)
    if [ "$labels" -ge "$inputs" ]; then
      pass "$rel — $inputs form fields, $labels labels/aria"
    else
      fail "$rel — $inputs form fields but only $labels labels"
    fi
  fi
done < <(html_files)

# ── 6. aria-expanded on toggle controls ──
echo ""
echo "-- aria-expanded on toggles --"
if grep -q 'aria-expanded' "$idx"; then
  pass "index.html has aria-expanded attributes"
  # Check FAQ buttons
  faq_buttons=$(grep -c 'aria-expanded' "$idx" || true)
  pass "Found $faq_buttons aria-expanded attributes"
else
  fail "index.html missing aria-expanded on toggle controls"
fi

# ── 7. Decorative images/SVGs hidden ──
echo ""
echo "-- Decorative content aria-hidden --"
# Check for aria-hidden on decorative SVGs
decorative_hidden=$(grep -c 'aria-hidden="true"' "$idx" || true)
if [ "$decorative_hidden" -gt 0 ]; then
  pass "index.html has $decorative_hidden aria-hidden elements"
else
  fail "index.html should have aria-hidden on decorative elements"
fi

# ── 8. Touch target sizes ──
echo ""
echo "-- Touch target sizes (CSS check) --"
# Check that buttons/links have adequate sizing
if grep -qE 'min-height:\s*(4[0-9]|[5-9][0-9]|[0-9]{3,})px' "$css" || \
   grep -qE 'padding:\s*(1[0-9]|[2-9][0-9])px' "$css"; then
  pass "CSS has adequate touch target sizing"
else
  warn "Verify touch targets are at least 44x44px on mobile"
fi

# ── 9. Role attributes on dynamic content ──
echo ""
echo "-- ARIA roles --"
for role in 'role="img"' 'role="listitem"\|role="list"'; do
  count=$(grep -c "$role" "$idx" 2>/dev/null || true)
  if [ "$count" -gt 0 ]; then
    pass "index.html uses $role ($count instances)"
  fi
done

# ── 10. tabindex usage ──
echo ""
echo "-- tabindex on sections --"
tabindex_count=$(grep -c 'tabindex="-1"' "$idx" || true)
if [ "$tabindex_count" -gt 0 ]; then
  pass "index.html has $tabindex_count sections with tabindex=\"-1\""
else
  warn "Consider tabindex=\"-1\" on scroll-target sections"
fi

# ── 11. sr-only utility class ──
echo ""
echo "-- Screen reader utility class --"
if grep -q '\.sr-only' "$css"; then
  pass "styles.css has .sr-only utility"
else
  fail "styles.css missing .sr-only utility class"
fi

echo ""
if [ $FAILS -eq 0 ]; then
  printf "\033[32m✓ All accessibility checks passed\033[0m\n"
else
  printf "\033[31m✗ %d accessibility check(s) failed\033[0m\n" "$FAILS"
fi
exit $FAILS
