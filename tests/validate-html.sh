#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────
# validate-html.sh — HTML structure & SEO checks
# ──────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
FAILS=0

pass() { printf "  \033[32mPASS\033[0m %s\n" "$1"; }
fail() { printf "  \033[31mFAIL\033[0m %s\n" "$1"; FAILS=$((FAILS + 1)); }

html_files() {
  find "$ROOT" -name '*.html' -not -path '*/.git/*' -not -path '*/node_modules/*' | sort
}

echo "=== HTML Validation ==="

# ── 1. DOCTYPE ──
echo ""
echo "-- Doctype --"
while IFS= read -r f; do
  rel="${f#"$ROOT"/}"
  if head -5 "$f" | grep -qi '<!doctype html>'; then
    pass "$rel has DOCTYPE"
  else
    fail "$rel missing DOCTYPE"
  fi
done < <(html_files)

# ── 2. Lang attribute ──
echo ""
echo "-- Lang attribute --"
while IFS= read -r f; do
  rel="${f#"$ROOT"/}"
  if grep -q '<html[^>]*lang=' "$f"; then
    pass "$rel has lang attribute"
  else
    fail "$rel missing lang attribute on <html>"
  fi
done < <(html_files)

# ── 3. Required meta tags ──
echo ""
echo "-- Required meta tags --"
while IFS= read -r f; do
  rel="${f#"$ROOT"/}"
  for tag in 'charset' 'viewport' 'description'; do
    if grep -qi "meta[^>]*${tag}" "$f"; then
      pass "$rel has meta $tag"
    else
      fail "$rel missing meta $tag"
    fi
  done
done < <(html_files)

# ── 4. Title tag ──
echo ""
echo "-- Title tag --"
while IFS= read -r f; do
  rel="${f#"$ROOT"/}"
  if grep -q '<title>' "$f"; then
    pass "$rel has <title>"
  else
    fail "$rel missing <title>"
  fi
done < <(html_files)

# ── 5. Semantic landmarks ──
echo ""
echo "-- Semantic landmarks (index.html) --"
idx="$ROOT/index.html"
for landmark in '<header' '<nav' '<main' '<footer'; do
  if grep -q "$landmark" "$idx"; then
    pass "index.html has $landmark"
  else
    fail "index.html missing $landmark"
  fi
done

# ── 6. Single h1 per page ──
echo ""
echo "-- Single <h1> per page --"
while IFS= read -r f; do
  rel="${f#"$ROOT"/}"
  h1_count=$(grep -c '<h1' "$f" || true)
  if [ "$h1_count" -eq 1 ]; then
    pass "$rel has exactly 1 <h1>"
  elif [ "$h1_count" -eq 0 ]; then
    fail "$rel has no <h1>"
  else
    fail "$rel has $h1_count <h1> tags (should be 1)"
  fi
done < <(html_files)

# ── 7. Duplicate IDs ──
echo ""
echo "-- Duplicate IDs --"
while IFS= read -r f; do
  rel="${f#"$ROOT"/}"
  dupes=$(grep -oE 'id="[^"]*"' "$f" | sort | uniq -d || true)
  if [ -z "$dupes" ]; then
    pass "$rel has no duplicate IDs"
  else
    fail "$rel has duplicate IDs: $dupes"
  fi
done < <(html_files)

# ── 8. Images have alt attributes ──
echo ""
echo "-- Image alt attributes --"
while IFS= read -r f; do
  rel="${f#"$ROOT"/}"
  # Find <img without alt=
  missing=$(grep -n '<img ' "$f" | grep -v 'alt=' || true)
  if [ -z "$missing" ]; then
    pass "$rel — all <img> have alt"
  else
    fail "$rel — <img> missing alt: $(echo "$missing" | head -3)"
  fi
done < <(html_files)

# ── 9. JSON-LD validity (basic) ──
echo ""
echo "-- JSON-LD structured data --"
if grep -q 'application/ld+json' "$idx"; then
  pass "index.html has JSON-LD"
  # Check it's parseable (if python3 available)
  if command -v python3 &>/dev/null; then
    json_blocks=$(python3 -c "
import re, json, sys
with open('$idx') as f:
    html = f.read()
blocks = re.findall(r'<script[^>]*application/ld\+json[^>]*>(.*?)</script>', html, re.DOTALL)
errors = 0
for i, b in enumerate(blocks):
    try:
        json.loads(b)
    except json.JSONDecodeError as e:
        print(f'Block {i+1}: {e}')
        errors += 1
sys.exit(errors)
" 2>&1) && pass "JSON-LD is valid JSON" || fail "JSON-LD parse error: $json_blocks"
  fi
else
  fail "index.html missing JSON-LD structured data"
fi

# ── 10. Open Graph tags ──
echo ""
echo "-- Open Graph meta tags --"
for prop in 'og:title' 'og:description' 'og:type' 'og:url'; do
  if grep -q "property=\"$prop\"" "$idx"; then
    pass "index.html has $prop"
  else
    fail "index.html missing $prop"
  fi
done

echo ""
if [ $FAILS -eq 0 ]; then
  printf "\033[32m✓ All HTML checks passed\033[0m\n"
else
  printf "\033[31m✗ %d HTML check(s) failed\033[0m\n" "$FAILS"
fi
exit $FAILS
