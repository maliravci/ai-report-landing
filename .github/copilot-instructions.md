# Copilot Instructions — AI Report Landing Page

Apply these instructions for all edits in this repository.

## 1) Project Purpose
This repository contains a **standalone marketing landing page** for the AI Report Generator product.

The page explains:
- what the app does,
- how the workflow works,
- why confidence scoring matters,
- and how users can get started.

This is **not** the React Native app codebase. Keep it independent and deployment-ready as a static site.

## 2) Product Summary (for copy/context)
AI Report Generator helps users:
1. Upload report templates + source documents,
2. Extract field values with AI,
3. Review confidence scores,
4. Edit/re-extract fields when needed,
5. Regenerate and download final reports.

Primary value proposition: **faster document/report completion with transparent AI confidence + human control**.

## 3) Repository Scope
Current stack is intentionally minimal:
- `index.html` — markup and content
- `styles.css` — all visual styling
- `script.js` — lightweight interactive behavior

Do not introduce build tools/frameworks (React, Vue, Tailwind, bundlers) unless explicitly requested.

## 4) UX Priorities
When generating or editing code:
- Keep a modern, premium visual style.
- Prioritize clarity and readability over flashy effects.
- Ensure mobile-first responsiveness.
- Keep CTA visibility strong in hero and bottom sections.
- Preserve fast load and smooth scrolling.

## 5) Coding Rules
- Keep HTML semantic (`header`, `nav`, `main`, `section`, `footer`).
- Keep CSS tokenized via `:root` variables for colors, spacing, radii, shadows.
- Keep JavaScript dependency-free and defensive.
- Avoid inline JS/CSS in HTML unless explicitly needed.
- Keep files organized and avoid dead code.

## 6) Content & Messaging Rules
- Use concise, benefit-focused copy.
- Keep claims realistic and non-deceptive.
- Prefer product-accurate wording (AI extraction + confidence + human review).
- Avoid backend/internal implementation details unless needed for trust section.

## 7) Accessibility Baseline
Always preserve/improve:
- keyboard navigability,
- visible focus styles,
- color contrast,
- aria labels for interactive controls,
- descriptive link/button text.

## 8) Performance Baseline
- Keep JS small and non-blocking.
- Minimize layout thrash in animations.
- Avoid large image/video payloads unless requested.
- Prefer CSS animations/transitions over heavy JS animation loops.

## 9) Change Discipline
- Make focused, minimal diffs.
- Do not rewrite the entire page when only a section change is requested.
- Preserve existing section IDs/anchors unless asked to change them.
- If changing structure, keep links and navigation in sync.

## 10) Definition of Done
Before finishing any coding task, confirm:
- layout works on mobile/tablet/desktop,
- navigation anchors still work,
- no console errors from `script.js`,
- design remains consistent across sections.

Refer to detailed standards in:
- `.github/instructions/landing-standards.instructions.md`
