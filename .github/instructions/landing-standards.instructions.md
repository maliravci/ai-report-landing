# Landing Standards (Detailed)

Use this file as implementation guidance for all landing-page changes.

## A) Architecture & Responsibilities

### File responsibilities
- `index.html`: semantic structure, content hierarchy, SEO meta tags.
- `styles.css`: design tokens, layout, responsive behavior, animation styles.
- `script.js`: small progressive enhancement only (menu, scroll effects, reveal animations).

### Keep the page static-first
- Must remain fully usable if JavaScript is disabled (except non-critical polish).
- Avoid coupling markup to fragile JS selectors; prefer stable IDs/classes.

## B) HTML Standards

- Use semantic landmarks:
  - `header` for hero,
  - `nav` for primary navigation,
  - `main` wrapping content sections,
  - `footer` for final links/legal.
- Maintain heading order (`h1` once, then logical `h2`/`h3`).
- Ensure all interactive controls are native elements (`button`, `a`) not clickable `div`s.
- Keep anchor IDs stable for nav links.
- Add/keep meta tags:
  - `title`, `description`, viewport.

## C) CSS Standards

- Reuse CSS variables from `:root`; do not hardcode repeated values.
- Preserve visual consistency:
  - spacing rhythm,
  - border radii,
  - shadows,
  - color system.
- Prefer class-based styling; avoid element-overrides that can cause regressions.
- Keep responsive breakpoints consistent with current structure.
- Avoid overly complex selectors and `!important` unless absolutely required.

### Responsive behavior
Verify at least these widths:
- 375px (mobile)
- 768px (tablet)
- 1024px (small desktop)
- 1440px (large desktop)

## D) JavaScript Standards

- Keep script dependency-free and short.
- Use `const`/`let`; no global variable pollution.
- Guard for missing DOM elements before attaching listeners.
- Keep interactions unobtrusive:
  - mobile menu toggle,
  - navbar scroll state,
  - reveal-on-scroll animations.
- Avoid introducing business logic into the landing page script.

## E) Accessibility & Usability

- Keep sufficient color contrast for text and controls.
- Ensure visible focus state on links/buttons.
- Include `aria-label` for icon-only buttons.
- Ensure touch targets are practical on mobile.
- Keep copy scannable: short paragraphs, meaningful headings.

## F) SEO & Marketing Content

- Keep above-the-fold messaging clear:
  - what product does,
  - who it helps,
  - what action to take.
- Keep CTA labels action-oriented and specific.
- Avoid vague jargon; prefer direct language.

## G) Quality Checklist for Any PR/Change

1. No broken section anchors.
2. No visual overlap at mobile widths.
3. No console errors.
4. No invalid or duplicate IDs.
5. Performance remains lightweight (no unnecessary libraries).
6. Messaging stays aligned with app capabilities.

## H) Non-Goals (unless requested)

Do **not** add by default:
- analytics SDKs,
- cookie banners,
- CMS integration,
- backend forms,
- framework migration,
- complex animation libraries.

## I) If user asks for new sections/components

- Follow existing visual language.
- Keep section IDs and nav links synchronized.
- Add only requested scope; avoid feature creep.
- Preserve page performance and readability.
