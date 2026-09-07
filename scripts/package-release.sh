#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
TMP_DIR="$(mktemp -d)"
STAMP="$(date +%Y%m%d-%H%M%S)"
PACKAGE_NAME="ai-report-landing-${STAMP}.tar.gz"
PACKAGE_PATH="$DIST_DIR/$PACKAGE_NAME"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

INCLUDE_PATHS=(
  "index.html"
  "styles.css"
  "script.js"
  "analytics.config.js"
  "analytics.js"
  "404.html"
  "favicon.ico"
  "manifest.json"
  "sitemap.xml"
  "robots.txt"
  "pages/shared.css"
  "pages/docs.html"
  "pages/api.html"
  "pages/changelog.html"
  "pages/about.html"
  "pages/contact.html"
  "pages/privacy.html"
  "pages/terms.html"
  "Logos"
  "Assets"
)

mkdir -p "$DIST_DIR"

echo "Building release package from strict allowlist..."
pushd "$ROOT_DIR" >/dev/null
for rel_path in "${INCLUDE_PATHS[@]}"; do
  if [[ -e "$rel_path" ]]; then
    rsync -a --relative "$rel_path" "$TMP_DIR/"
  else
    echo "Warning: missing allowlisted path '$rel_path'"
  fi
done
popd >/dev/null

find "$TMP_DIR" -name '.DS_Store' -delete

if [[ -f "$ROOT_DIR/scripts/check-secrets.sh" ]]; then
  "$ROOT_DIR/scripts/check-secrets.sh"
fi

tar -czf "$PACKAGE_PATH" -C "$TMP_DIR" .

tar -tzf "$PACKAGE_PATH" > "$DIST_DIR/${PACKAGE_NAME%.tar.gz}.filelist.txt"

echo ""
echo "Release package created: $PACKAGE_PATH"
echo "Manifest created: $DIST_DIR/${PACKAGE_NAME%.tar.gz}.filelist.txt"
echo ""
echo "Package contents:"
cat "$DIST_DIR/${PACKAGE_NAME%.tar.gz}.filelist.txt"
