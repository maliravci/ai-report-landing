#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────
# check-links.sh — Internal link & anchor validation
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

echo "=== Link Checks ==="

# ── 1. Internal anchor targets (hash links within same page) ──
echo ""
echo "-- Anchor targets (index.html) --"
idx="$ROOT/index.html"
anchors=$(grep -oE 'href="#[^"]*"' "$idx" | sed 's/href="#//;s/"//' | sort -u)
for anchor in $anchors; do
  if [ -z "$anchor" ]; then continue; fi
  if grep -q "id=\"$anchor\"" "$idx"; then
    pass "#$anchor target exists"
  else
    fail "#$anchor target NOT FOUND in index.html"
  fi
done

# ── 2. Internal file references ──
echo ""
echo "-- Internal file references --"
while IFS= read -r f; do
  rel="${f#"$ROOT"/}"
  # Extract href values that point to local files (not http, mailto, tel, #, javascript)
  hrefs=$(grep -oE 'href="[^"]*"' "$f" | sed 's/href="//;s/"//' | \
    grep -v '^http' | grep -v '^mailto:' | grep -v '^tel:' | \
    grep -v '^#' | grep -v '^javascript:' | grep -v '^data:' || true)
  
  dir=$(dirname "$f")
  for href in $hrefs; do
    # Strip query string and hash
    clean=$(echo "$href" | sed 's/[?#].*//')
    if [ -z "$clean" ]; then continue; fi
    target="$dir/$clean"
    if [ -f "$target" ] || [ -d "$target" ]; then
      pass "$rel → $href exists"
    else
      # Try from root
      target="$ROOT/$clean"
      if [ -f "$target" ] || [ -d "$target" ]; then
        pass "$rel → $href exists (from root)"
      else
        fail "$rel → $href NOT FOUND"
      fi
    fi
  done
done < <(html_files)

# ── 3. CSS file references ──
echo ""
echo "-- CSS file references --"
while IFS= read -r f; do
  rel="${f#"$ROOT"/}"
  css_refs=$(grep -oE 'href="[^"]*\.css"' "$f" | sed 's/href="//;s/"//' | \
    grep -v '^http' || true)
  dir=$(dirname "$f")
  for css in $css_refs; do
    target="$dir/$css"
    if [ -f "$target" ]; then
      pass "$rel → $css loads"
    else
      target="$ROOT/$css"
      if [ -f "$target" ]; then
        pass "$rel → $css loads (from root)"
      else
        fail "$rel → $css NOT FOUND"
      fi
    fi
  done
done < <(html_files)

# ── 4. Navigation consistency — all nav links present ──
echo ""
echo "-- Nav link consistency (index.html) --"
expected_nav_anchors="features how-it-works pricing faq"
for anchor in $expected_nav_anchors; do
  if grep -q "href=\"#$anchor\"" "$idx"; then
    pass "Nav has #$anchor"
  else
    fail "Nav missing #$anchor"
  fi
done

# ── 5. Subpage back-to-home links ──
echo ""
echo "-- Subpage links back to home --"
for f in "$ROOT"/pages/*.html; do
  rel="${f#"$ROOT"/}"
  if grep -qE 'href="\.\./index\.html|href="/"' "$f"; then
    pass "$rel links back to home"
  else
    # Check for relative link to parent
    if grep -q 'href="../"' "$f"; then
      pass "$rel links back to home"
    else
      fail "$rel has no link back to home page"
    fi
  fi
done

# ── 6. Sitemap references ──
echo ""
echo "-- Sitemap entries --"
sitemap="$ROOT/sitemap.xml"
if [ -f "$sitemap" ]; then
  pass "sitemap.xml exists"
  loc_count=$(grep -c '<loc>' "$sitemap" || true)
  if [ "$loc_count" -gt 0 ]; then
    pass "sitemap.xml has $loc_count URLs"
  else
    fail "sitemap.xml has no <loc> entries"
  fi
else
  fail "sitemap.xml not found"
fi

# ── 7. Robots.txt ──
echo ""
echo "-- robots.txt --"
robots="$ROOT/robots.txt"
if [ -f "$robots" ]; then
  pass "robots.txt exists"
  if grep -q 'Sitemap:' "$robots"; then
    pass "robots.txt references sitemap"
  else
    fail "robots.txt missing Sitemap directive"
  fi
else
  fail "robots.txt not found"
fi

echo ""
if [ $FAILS -eq 0 ]; then
  printf "\033[32m✓ All link checks passed\033[0m\n"
else
  printf "\033[31m✗ %d link check(s) failed\033[0m\n" "$FAILS"
fi
exit $FAILS
