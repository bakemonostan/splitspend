# SplitSpend — Design System (MVP handoff)

**Purpose:** Single source for **Figma Variants**, **Stitch**, or any AI/design tool generating UI for the SplitSpend PRD.  
**Companion doc:** `PRD.md`  

---

## 1. Brand & tone

| Attribute | Direction |
|-----------|-----------|
| **Name** | SplitSpend |
| **Personality** | Clear, trustworthy, low-friction—**finance without anxiety** |
| **Voice** | Short labels, plain language; errors are helpful, not blaming |
| **Density** | Comfortable mobile spacing; avoid cramming tables on small screens |

---

## 2. Design principles

1. **One primary action per screen** (e.g. “Add expense” on group detail).
2. **Progressive disclosure** — receipt and note optional behind clear affordances.
3. **Trust cues** — subtle lock/privacy for auth; no dark patterns.
4. **Accessibility first** — touch targets ≥ 44pt, readable contrast, support dynamic type where possible.

---

## 3. Color tokens (semantic)

Map these to **Figma variables** / **Stitch tokens**. Use **semantic** names so light/dark can swap later.

| Token | Usage | Light (suggested hex) | Dark (suggested hex) |
|-------|--------|------------------------|----------------------|
| `color.surface` | App background | `#F8F9FB` | `#121418` |
| `color.surface-elevated` | Cards, sheets | `#FFFFFF` | `#1C2128` |
| `color.primary` | Primary buttons, links | `#0F766E` | `#2DD4BF` |
| `color.primary-on` | Text on primary | `#FFFFFF` | `#042F2E` |
| `color.text-primary` | Body | `#0F172A` | `#E6EDF3` |
| `color.text-secondary` | Captions, meta | `#64748B` | `#8B9CB3` |
| `color.border` | Dividers, inputs | `#E2E8F0` | `#30363D` |
| `color.danger` | Delete, critical errors | `#DC2626` | `#F87171` |
| `color.success` | Confirmations | `#16A34A` | `#4ADE80` |
| `color.warning` | Non-blocking issues | `#D97706` | `#FBBF24` |

**Scrim / overlay:** `rgba(15, 23, 42, 0.45)` over content behind modals.

---

## 4. Typography

| Style | Role | Weight | Size (sp) | Line height |
|-------|------|--------|-----------|-------------|
| `display` | Rare hero | 700 | 28–32 | 1.2 |
| `title` | Screen titles | 600 | 20–22 | 1.25 |
| `headline` | Section headers | 600 | 17–18 | 1.3 |
| `body` | Primary copy | 400 | 15–16 | 1.45 |
| `body-strong` | Emphasis | 600 | 15–16 | 1.45 |
| `caption` | Meta, timestamps | 400 | 12–13 | 1.35 |
| `label` | Inputs, chips | 500 | 13–14 | 1.2 |

**Font family:** Use platform default (SF Pro / Roboto) for MVP; optional brand font later.

---

## 5. Spacing & layout

| Token | Value (pt) | Use |
|-------|--------------|-----|
| `space.xs` | 4 | Tight stacks |
| `space.sm` | 8 | Icon gaps |
| `space.md` | 16 | Screen padding, card padding |
| `space.lg` | 24 | Section separation |
| `space.xl` | 32 | Empty states |

- **Screen horizontal padding:** `space.md` (16).
- **List row min height:** 56–64 pt (touch + two-line text).
- **Bottom safe area:** reserve for FAB or primary CTA bar.

---

## 6. Radius, stroke, elevation

| Token | Value |
|-------|--------|
| `radius.sm` | 8 |
| `radius.md` | 12 |
| `radius.lg` | 16 (bottom sheets, large cards) |
| `radius.full` | 999 (pills, avatars) |
| `stroke.input` | 1 px `color.border` |
| `elevation.card` | 0–1 dp shadow or 1 px border only (avoid heavy shadows on MVP) |

---

## 7. Iconography

- **Style:** Outlined / rounded (Material Symbols **Outlined** or SF Symbols equivalent).
- **Key icons:** `groups`, `add`, `receipt_long`, `camera`, `image`, `lock`, `logout`, `chevron_right`, `close`, `check`, `error_outline`.

---

## 8. Components (build as Figma Variants)

Use **variant properties** like: `state` = default | pressed | disabled | loading | error; `theme` = light | dark.

| Component | Variants / notes |
|-----------|------------------|
| **AppBar** | With back, title, optional action (profile) |
| **PrimaryButton** | Full-width on mobile forms |
| **SecondaryButton** | Outlined or text |
| **TextField** | With label, error text, optional prefix (currency) |
| **ListTile** | Expense row: title = note or category, subtitle = date + payer |
| **Avatar** | Initials fallback |
| **Chip** | Category, currency badge |
| **FAB** | Add expense (optional if using bottom bar) |
| **BottomSheet** | Join group, filters (stretch) |
| **EmptyState** | Illustration placeholder + title + CTA |
| **Snackbar** | Success / error |
| **Skeleton** | List rows while loading |
| **ReceiptThumb** | 4:3 or square, radius `radius.sm` |

---

## 9. Patterns

### 9.1 Expense list row
- **Leading:** category icon or receipt thumb placeholder  
- **Title:** short description or category  
- **Subtitle:** relative date · **amount** right-aligned (tabular nums)  
- **Trailing:** chevron if detail exists  

### 9.2 Money display
- Currency symbol + amount with **thousands separators**; 2 decimal places; use locale-aware formatting in implementation.

### 9.3 Auth screens
- Logo/wordmark top; form centered; **legal** one-liner footer (stretch).

### 9.4 destructive actions
- Delete expense: confirm **dialog** or bottom sheet; red **danger** button.

---

## 10. Motion

- **Duration:** 200–280 ms for sheets and page transitions.
- **Curve:** Standard ease-in-out; avoid bouncy physics on finance flows.
- **Realtime update:** subtle list insert (fade/slide) when new expense arrives.

---

## 11. Accessibility

- Minimum **contrast** WCAG AA for text on surfaces.
- **Focus order** logical on forms (for web / keyboard if ever ported).
- **Semantics:** screens titled; buttons with verbs (“Add expense”, not “OK”).

---

## 12. Stitch / AI prompt snippet (copy-paste)

Use with `PRD.md` attached:

> Design a **mobile iOS/Android** app called **SplitSpend** for **group expense tracking**. Style: **clean fintech**, semantic colors from DESIGN_SYSTEM.md, **16pt** screen padding, **rounded 12–16** cards, **teal primary** `#0F766E`. Screens: auth (sign in/up), **groups list** with empty state, **create group**, **join group** sheet, **group feed** with expense rows (amount right-aligned, date subtitle), **add expense** form with amount, currency, category chips, optional receipt. Include **loading skeletons** and **error snackbar**. Dark mode optional second theme using token table.

---

## 13. File delivery checklist

- [ ] All screens in §8 of PRD as frames  
- [ ] Components in §8 as variant sets  
- [ ] Color & type styles as **variables** / styles  
- [ ] Light + dark (optional)  
- [ ] Export **PNG** or **Figma link** for Stitch  
