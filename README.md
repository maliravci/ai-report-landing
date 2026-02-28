# ReportDrafter — Landing Page

Static marketing landing page for **ReportDrafter**, the AI-powered report generator.

## Tech Stack

- Plain HTML5 + CSS3 + vanilla JavaScript
- No build tools, no framework, no dependencies
- Google Fonts (Inter 400–800)
- CSS custom properties for design tokens (`:root` variables)

## Project Structure

### Core Pages

| File | Purpose |
|------|---------|
| `index.html` | Main landing page — hero, features, how-it-works, confidence, trust strip, testimonials, pricing, FAQ, CTA, footer |
| `styles.css` | All styling for `index.html` — responsive layout, animations, glassmorphism navbar, design tokens |
| `script.js` | Navbar scroll effect, mobile menu, scroll-triggered animations, FAQ accordion, back-to-top, floating CTA, active nav tracking, contact form validation |

### Subpages (`pages/`)

| File | Purpose |
|------|---------|
| `pages/shared.css` | Shared styles for all subpages |
| `pages/docs.html` | Documentation — getting started, templates, confidence scores |
| `pages/api.html` | API reference — endpoints, rate limits, error codes |
| `pages/changelog.html` | Product changelog with versioned entries |
| `pages/about.html` | Team bios and company information |
| `pages/contact.html` | Contact form |
| `pages/privacy.html` | Privacy policy |
| `pages/terms.html` | Terms of service |

### Other Files

| File | Purpose |
|------|---------|
| `404.html` | Custom 404 error page |
| `favicon.ico` | Browser tab icon |
| `manifest.json` | PWA web app manifest |
| `sitemap.xml` | Search engine sitemap |
| `robots.txt` | Crawler directives |
| `Logos/` | Brand logo files (SVG, PNG) |
| `Assets/` | Image assets (team photos, icons) |

### Development Files (not deployed)

| File | Purpose |
|------|---------|
| `README.md` | This file — project documentation |
| `TODO.md` | Task tracking |
| `.github/` | Copilot instructions, coding standards |
| `tests/` | Automated testing scripts |
| `DEPLOYMENT.md` | Deployment guide |

## Sections (index.html)

1. **Hero** — Headline, subtitle, CTA buttons, animated stats, mock report card
2. **Trust Strip** — Industry badges (Finance, Healthcare, Legal, etc.)
3. **Features** — 6 feature cards (AI extraction, confidence scoring, inline editing, export, multilingual, transparent review trail)
4. **How It Works** — 4-step visual walkthrough
5. **AI Confidence** — Confidence level breakdown + animated gauge
6. **Platforms** — Web, iOS, Android cards
7. **Testimonials** — 3 customer testimonials with star ratings
8. **Pricing** — Starter / Professional / Enterprise tiers
9. **FAQ** — 8 collapsible questions with JSON-LD structured data
10. **CTA** — Final call-to-action with gradient background
11. **Footer** — 4-column layout: brand, product, resources, get started

## Running Locally

Open `index.html` directly in a browser, or use any static file server:

```bash
npx serve .
# or
python3 -m http.server 3001
```

## Testing

Run the test suite from the project root:

```bash
# All tests
bash tests/run-tests.sh

# Individual checks
bash tests/validate-html.sh
bash tests/check-links.sh
bash tests/check-accessibility.sh
```

See `tests/README.md` for details.

## Deployment

See [DEPLOYMENT.md](DEPLOYMENT.md) for the full deployment guide, including which files to include/exclude.

## Notes

This landing page is self-contained and has **no dependency** on the React Native app codebase. It is designed to be deployed as a static site on any hosting platform (GitHub Pages, Netlify, Vercel, Cloudflare Pages, etc.).
