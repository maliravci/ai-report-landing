# Deployment Guide

How to deploy the ReportDrafter landing page as a static site.

---

## Production Files (DEPLOY THESE)

These files are required for the site to function:

```
index.html              ← Main landing page
styles.css              ← Styling for index.html
script.js               ← Interactive behavior
404.html                ← Custom error page
favicon.ico             ← Browser tab icon
manifest.json           ← PWA manifest
sitemap.xml             ← Search engine sitemap
robots.txt              ← Crawler directives

pages/
  shared.css            ← Shared subpage styles
  docs.html             ← Documentation
  api.html              ← API reference
  changelog.html        ← Product changelog
  about.html            ← About / team
  contact.html          ← Contact form
  privacy.html          ← Privacy policy
  terms.html            ← Terms of service

Logos/                  ← All logo files (SVG + PNG)
Assets/                 ← Image assets (team photos, icons)
```

## Development-Only Files (DO NOT DEPLOY)

These files are for development, documentation, and testing — exclude them from production:

```
README.md               ← Project documentation
DEPLOYMENT.md           ← This file
TODO.md                 ← Task tracking
.git/                   ← Git history
.github/                ← Copilot instructions, coding standards
tests/                  ← Automated test scripts
```

---

## Deployment Methods

### GitHub Pages

1. Go to **Settings → Pages** in your GitHub repo
2. Set source to **Deploy from a branch** → `master` / `main` (root `/`)
3. Site will be live at `https://<username>.github.io/<repo>/`

To exclude dev files, add a `.nojekyll` file and use the default GitHub Pages behavior (it serves everything). Dev files like `README.md` and `.github/` won't appear in navigation since nothing links to them.

### Netlify

1. Connect your GitHub repo at [app.netlify.com](https://app.netlify.com)
2. Build settings:
   - **Build command:** (leave empty — no build step)
   - **Publish directory:** `.`
3. Site deploys automatically on push

### Vercel

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel --prod
```

Or connect your repo at [vercel.com/new](https://vercel.com/new). No build configuration needed.

### Cloudflare Pages

1. Connect repo at [dash.cloudflare.com](https://dash.cloudflare.com) → Pages
2. Build settings:
   - **Build command:** (leave empty)
   - **Build output directory:** `.`

### Manual / Any Static Host

Copy only the production files listed above to your server's web root:

```bash
# Example: rsync to a server (excluding dev files)
rsync -av --exclude='.git' \
          --exclude='.github' \
          --exclude='tests' \
          --exclude='README.md' \
          --exclude='DEPLOYMENT.md' \
          --exclude='TODO.md' \
          ./ user@server:/var/www/reportdrafter/
```

Or use the deploy script below.

---

## Deploy Script

A helper script to copy only production files to a target directory:

```bash
#!/usr/bin/env bash
# deploy.sh — Copy production files to a target directory
set -euo pipefail

TARGET="${1:?Usage: ./deploy.sh <target-directory>}"

mkdir -p "$TARGET"

# Files to exclude from deployment
EXCLUDES=(
  '.git'
  '.github'
  'tests'
  'README.md'
  'DEPLOYMENT.md'
  'TODO.md'
  '.gitignore'
  '*.py'
  'deploy.sh'
)

EXCLUDE_ARGS=()
for e in "${EXCLUDES[@]}"; do
  EXCLUDE_ARGS+=(--exclude="$e")
done

rsync -av "${EXCLUDE_ARGS[@]}" ./ "$TARGET/"

echo ""
echo "✓ Deployed to $TARGET"
echo "  $(find "$TARGET" -type f | wc -l | tr -d ' ') files"
```

---

## Pre-Deployment Checklist

Run before every deployment:

- [ ] `bash tests/run-tests.sh` — all tests pass
- [ ] Open `index.html` locally — no console errors
- [ ] Check mobile layout (375px) — no overflow or overlap
- [ ] Verify all nav links work — Features, How It Works, Pricing, FAQ
- [ ] Check subpage links — Docs, API, Changelog, About, Contact
- [ ] Confirm CTA buttons link to `https://app.reportdrafter.com/signup`
- [ ] Verify `sitemap.xml` URLs match your production domain
- [ ] Verify `robots.txt` Sitemap URL matches your production domain

## Post-Deployment Verification

After deploying:

- [ ] Visit the live URL — page loads without errors
- [ ] Test mobile menu toggle
- [ ] Verify smooth scroll to sections
- [ ] Check 404 page by visiting a non-existent URL
- [ ] Run [PageSpeed Insights](https://pagespeed.web.dev/) — target 90+ on all metrics
- [ ] Validate structured data at [Rich Results Test](https://search.google.com/test/rich-results)

---

## Custom Domain Setup

If using a custom domain (e.g., `reportdrafter.com`):

1. Update `sitemap.xml` — replace base URLs with your domain
2. Update `robots.txt` — update the Sitemap directive URL
3. Update `manifest.json` — update `start_url` if needed
4. Update OG meta tags in `index.html` — set `og:url` to your domain
5. Configure DNS per your hosting provider's instructions

## File Size Budget

| Category | Target | Current |
|----------|--------|---------|
| Total HTML | < 200 KB | ~100 KB |
| styles.css | < 50 KB | ~38 KB |
| script.js | < 15 KB | ~9 KB |
| Total site (excl. images) | < 300 KB | ~160 KB |

The site has no build step, no bundling, and no external JS dependencies — keeping it fast by default.
