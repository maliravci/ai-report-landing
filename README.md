# Landing Page

Static marketing landing page for the AI Report Generator app.

## Tech Stack

- Plain HTML5 + CSS3 + vanilla JavaScript
- No build tools, no framework, no dependencies
- Google Fonts (Inter)

## Files

| File | Purpose |
|------|---------|
| `index.html` | Page structure — hero, features, how-it-works, confidence, platforms, CTA, footer |
| `styles.css` | All styling — responsive, animations, glassmorphism navbar |
| `script.js` | Navbar scroll effect, mobile menu, scroll-triggered fade-in animations |

## Running Locally

Open `index.html` directly in a browser, or use any static file server:

```bash
# From this directory
npx serve .
# or
python3 -m http.server 3001
```

## Sections

1. **Hero** — Headline, subtitle, CTA buttons, stats, mock report-result card
2. **Features** — 6 feature cards (AI extraction, confidence, editing, download, languages, dark mode)
3. **How It Works** — 4-step walkthrough with icons
4. **AI Confidence** — Confidence level breakdown + animated gauge
5. **Platforms** — Web, iOS, Android cards
6. **CTA** — Final call-to-action with gradient background
7. **Footer** — Brand, product/resource/company links

## Notes

This landing page is self-contained and has **no dependency** on the React Native app codebase. It can live in this repo for convenience or be moved to its own repository/deployment.
