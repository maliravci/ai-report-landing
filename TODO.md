# ReportDrafter Landing — Items Awaiting Your Input

These items require assets, credentials, or decisions only you can provide.
Check them off or update details as you go.

---

## Production Launch Preparation (VM + Static Deploy)

- [x] **Strict release packaging script** — Added `scripts/package-release.sh` with allowlist-only deploy contents.
- [x] **Secret preflight script** — Added `scripts/check-secrets.sh` to block obvious leaked credentials.
- [x] **Deploy artifact folder policy** — Added `.gitignore` entry for `dist/` and sensitive extensions (`*.key`, `*.pem`, etc.).
- [ ] **Create final release archive** — Run `bash scripts/package-release.sh` right before server upload.
- [ ] **Verify release file manifest** — Confirm `dist/*.filelist.txt` has only runtime files.
- [ ] **Run full tests before upload** — `bash tests/run-tests.sh`.
- [ ] **Server hardening baseline** — SSH key-only auth, firewall ports restricted to `22/80/443`, auto-updates enabled.
- [ ] **TLS + proxy decision** — Confirm Cloudflare setup and SSL mode before go-live.

---

## Assets Needed

- [ ] **Product screenshots / demo video** — Hero section and How It Works visuals.
      Add files to a `media/` folder; once provided, will be embedded in the hero and step sections.

- [ ] **OG share image** — A 1200×630 social preview card image.
      Currently falling back to `Logos/logo_512x512.png`.
      Ideally branded card with tagline text for better social sharing.

## Services / Endpoints

- [ ] **Contact form endpoint** — Currently shows a client-side "Thank you" alert.
      Options: Formspree, Netlify Forms, Cloudflare Workers, or custom backend.
      Once provided, update `pages/contact.html` form `action` attribute and replace the temporary client-side success simulation.

## Social / Branding

- [ ] **Twitter/X handle** — Currently placeholder `@reportdrafter`.
      Update footer social links across all 8 HTML files once confirmed.

- [ ] **LinkedIn company page** — Currently placeholder `linkedin.com/company/reportdrafter`.
      Update once real page is created.

- [ ] **Twitter Card metadata** — `twitter:site` and `twitter:creator` handles.
      Will add to all pages once handles are confirmed.

## Content / Copy

- [ ] **Real testimonial quotes & names** — Current testimonials are realistic placeholders.
      Replace with actual customer feedback when available.

- [ ] **Company logo strip** — Trust strip currently text-only (industry names).
      Supply partner/client logos to upgrade to a visual logo carousel.

## Deployment

- [ ] **Custom domain DNS** — Confirm domain registrar and hosting (GitHub Pages, Netlify, Vercel, etc.)
      `sitemap.xml` and canonical URLs already reference `reportdrafter.com`.

- [x] **Google Analytics integration** — Consent-gated GA4 support is installed.
      Set `measurementId` in `analytics.config.js` with the production `G-XXXXXXXX` value before deployment.

- [x] **favicon.ico** — Added for legacy browser support.

---

_Last updated: 2026-02-28_
