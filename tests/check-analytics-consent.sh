#!/usr/bin/env bash
# Verify that the optional analytics tag is not loaded before consent is resolved.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ANALYTICS_FILE="$ROOT_DIR/analytics.js"

fail() {
  echo "FAIL  $*" >&2
  exit 1
}

[[ -f "$ANALYTICS_FILE" ]] || fail "analytics.js is missing"

if command -v node >/dev/null 2>&1; then
  node --check "$ANALYTICS_FILE" || fail "analytics.js has invalid syntax"
fi

grep -Fq "fetch(consentRegionEndpoint" "$ANALYTICS_FILE" \
  || fail "regional consent decision is missing"
grep -Fq "window['ga-disable-' + measurementId]" "$ANALYTICS_FILE" \
  || fail "analytics opt-out flag is missing"
grep -Fq "window.gtag = window.gtag ||" "$ANALYTICS_FILE" \
  || fail "analytics tag setup is missing"

# An invocation at the IIFE's base indentation would load the Google tag before
# the consent decision or a visitor action. Calls inside the approved branches
# are indented further.
if grep -Eq '^  loadAnalytics\(\);$' "$ANALYTICS_FILE"; then
  fail "analytics loads before consent is resolved"
fi

echo "PASS  Analytics is consent-gated and has an opt-out control"
