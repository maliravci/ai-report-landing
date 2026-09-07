#!/usr/bin/env bash
# deploy.sh — Production deploy script for ai-report-landing
# Usage: bash scripts/deploy.sh [--skip-package]
#   --skip-package  Use the latest existing dist package instead of rebuilding
# Requirements: SSH key at DEPLOY_KEY_PATH, scp, ssh, curl
set -euo pipefail

# ─── Configuration ──────────────────────────────────────────────────────────
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DEPLOY_KEY="${DEPLOY_KEY_PATH:-/Users/murat/Projects/ai-report-backend/oracle_cloud/keys/ssh-key-2026-03-05-2.key}"
DEPLOY_USER="ubuntu"
DEPLOY_HOST="130.61.145.56"
REMOTE_DIR="/var/www/landing"
DOMAIN="reportdrafter.com"
DIST_DIR="$ROOT_DIR/dist"

# ─── Helpers ─────────────────────────────────────────────────────────────────
log()  { echo "[deploy] $*"; }
fail() { echo "[deploy] ERROR: $*" >&2; exit 1; }

ssh_cmd() {
  ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new \
      -o ConnectTimeout=10 -i "$DEPLOY_KEY" \
      "${DEPLOY_USER}@${DEPLOY_HOST}" "$@"
}

# ─── Argument Parsing ─────────────────────────────────────────────────────────
SKIP_PACKAGE=false
for arg in "$@"; do
  [[ "$arg" == "--skip-package" ]] && SKIP_PACKAGE=true
done

# ─── Step 1: Preflight checks ─────────────────────────────────────────────────
log "Preflight checks..."
[[ -f "$DEPLOY_KEY" ]] || fail "SSH key not found: $DEPLOY_KEY"
chmod 600 "$DEPLOY_KEY"
ssh_cmd 'echo VM_OK' | grep -q VM_OK || fail "Cannot connect to VM"
log "VM reachable."

# ─── Step 2: Build release package ─────────────────────────────────────────────
if [[ "$SKIP_PACKAGE" == true ]]; then
  PACKAGE=$(ls -t "$DIST_DIR"/ai-report-landing-*.tar.gz 2>/dev/null | head -n 1)
  [[ -n "$PACKAGE" ]] || fail "No existing package found in dist/. Run without --skip-package."
  log "Reusing existing package: $(basename "$PACKAGE")"
else
  log "Building release package..."
  bash "$ROOT_DIR/scripts/package-release.sh"
  PACKAGE=$(ls -t "$DIST_DIR"/ai-report-landing-*.tar.gz | head -n 1)
  [[ -n "$PACKAGE" ]] || fail "Package build failed — no .tar.gz found in dist/"
  log "Package built: $(basename "$PACKAGE")"
fi

# ─── Step 3: Upload ──────────────────────────────────────────────────────────
log "Uploading $(basename "$PACKAGE") to VM..."
scp -o BatchMode=yes -o StrictHostKeyChecking=accept-new \
    -o ConnectTimeout=10 -i "$DEPLOY_KEY" \
    "$PACKAGE" "${DEPLOY_USER}@${DEPLOY_HOST}:/tmp/landing-release.tar.gz"
log "Upload complete."

# ─── Step 4: Deploy on VM ────────────────────────────────────────────────────
log "Deploying on VM..."
ssh_cmd bash <<'REMOTE'
set -euo pipefail
sudo mkdir -p /var/www/landing
sudo tar -xzf /tmp/landing-release.tar.gz -C /var/www/landing
sudo chown -R www-data:www-data /var/www/landing
sudo chmod -R 755 /var/www/landing
sudo nginx -t
sudo systemctl reload nginx
rm -f /tmp/landing-release.tar.gz
echo REMOTE_DEPLOY_OK
REMOTE
log "Deploy complete. Nginx reloaded."

# ─── Step 5: Smoke test ──────────────────────────────────────────────────────
log "Running smoke test on https://$DOMAIN ..."
sleep 3
TITLE=$(curl -sf --max-time 15 "https://$DOMAIN" | grep -o '<title>[^<]*</title>' || true)
if [[ -n "$TITLE" ]]; then
  log "Smoke test passed: $TITLE"
else
  fail "Smoke test failed — could not retrieve page title from https://$DOMAIN"
fi

# ─── Done ────────────────────────────────────────────────────────────────────
echo ""
echo "================================================"
echo "  DEPLOYMENT SUCCESSFUL"
echo "  Site: https://$DOMAIN"
echo "  Package: $(basename "$PACKAGE")"
echo "  $(date)"
echo "================================================"
