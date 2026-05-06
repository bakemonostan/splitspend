# SplitSpend — Product Requirements Document (MVP)

**Version:** 1.0  
**Stack:** Flutter (client) · Supabase (Auth, Postgres, RLS, Storage, Realtime)  
**Audience:** Design (Figma / Stitch / Variant), engineering, interview walkthrough  

---

## 1. Product summary

**SplitSpend** is a mobile-first app for **small groups** (housemates, trips, teams) to **log shared expenses**, attach **receipt photos**, and see a **live-updating feed** per group. Access is gated by **accounts** and **group membership** (Row Level Security on the backend).

**North star (MVP):** A user can create a group, share an invite code, add expenses with optional receipts, and see updates in near real time—without seeing other groups’ data.

---

## 2. Goals & non-goals

### Goals
- Demonstrate **production-shaped** features: auth, scoped data, file upload, realtime, clear IA.
- Ship an **MVP** that is demoable end-to-end in **&lt; 10 minutes** (happy path).
- Keep **visual and UX** consistent via a single **design system** (see `DESIGN_SYSTEM.md`).

### Non-goals (MVP)
- Bank linking, automatic currency conversion, tax rules, reimbursements automation.
- Full “who owes whom” settlement math (optional **stretch**: simple totals per category or per person).
- Web admin portal, email invites, push notifications (can be stretch).
- Offline-first / conflict resolution (show graceful errors; online-first).

---

## 3. Target users

| Persona | Need |
|--------|------|
| **Organizer** | Creates group, shares code, reviews expenses |
| **Member** | Joins with code, adds expenses and receipts |
| **Solo tester** | Same person uses two accounts/devices to validate RLS |

---

## 4. Core user flows

1. **Onboarding / Auth** — Sign up, sign in, sign out; session persists across restarts.
2. **Groups hub** — List groups the user belongs to; empty state when none.
3. **Create group** — Name + generated **invite code** (unique); user becomes **owner**.
4. **Join group** — Enter invite code; user becomes **member** (RPC `join_group`).
5. **Group detail** — Tabs or sections: **Feed** (expenses), **Add expense** (primary CTA).
6. **Add / edit expense** — Amount, currency, category, date, note, optional **receipt** (camera/gallery).
7. **Live feed** — New expenses appear without full app restart (Realtime subscription).
8. **Receipts** — Stored in private bucket; path tied to `group_id` / expense.

---

## 5. Functional requirements

### 5.1 Authentication
- Email + password and/or magic link (match Supabase project settings).
- Password reset entry point if using password auth.
- Clear error states: invalid credentials, network offline.

### 5.2 Groups
- **Create:** `name` + server-unique `invite_code` (client generates + retries on conflict).
- **List:** Only groups where the user is in `group_members`.
- **Join:** Single field for code; success navigates to group detail; invalid code shows inline error.

### 5.3 Expenses
- **Fields:** amount (≥ 0), currency (default USD), category (preset list + “Other”), **spent_at** date/time, optional note.
- **List:** Chronological (newest first), pull-to-refresh, skeleton on first load.
- **Edit / delete:** Only by **creator** (matches current RLS); show affordance only for own rows.
- **Receipt:** Optional image; show thumbnail in list when present; full-screen viewer on tap.

### 5.4 Realtime
- Subscribe to **inserts** on `expenses` for the **current group**; debounce UI updates if needed.

### 5.5 Profile
- Display name (and optional avatar URL later); edit display name on a simple profile screen or sheet.

---

## 6. Acceptance criteria (MVP)

- [ ] Two test users cannot read each other’s groups or expenses (RLS).
- [ ] Creating a group creates **one** owner row and appears in hub.
- [ ] Join with wrong code fails with clear message; correct code adds member and shows group.
- [ ] Adding an expense updates list for **both** members within seconds (Realtime).
- [ ] Receipt upload completes and thumbnail/path is visible after refresh if needed.
- [ ] Sign out clears session; sign in again restores access.

---

## 7. Data model (reference)

High-level only—source of truth is Supabase migrations.

- `profiles` — 1:1 with `auth.users`
- `groups` — `invite_code`, `created_by`
- `group_members` — `role`: owner | member
- `expenses` — `group_id`, `created_by`, `amount`, `currency`, `category`, `note`, `spent_at`, `receipt_storage_path`

---

## 8. Screen inventory (for design)

Use this checklist with **Variant / Stitch** prompts.

| # | Screen / surface |
|---|-------------------|
| S1 | Splash / loading (session restore) |
| S2 | Sign in |
| S3 | Sign up |
| S4 | Groups hub (empty + populated) |
| S5 | Create group |
| S6 | Join group (modal or full screen) |
| S7 | Group detail — expense feed |
| S8 | Add expense (form + receipt picker) |
| S9 | Expense detail (optional) |
| S10 | Profile / settings |
| S11 | Error / offline banner |
| S12 | Success toasts / snackbars |

---

## 9. Stretch (post-MVP)

- Summary card: **total this month**, breakdown by category.
- “Balances” stub: simple owed text per member (no payments).
- Push notifications for new expenses (FCM + Edge Function).

---

## 10. Open questions

- **Auth method:** Password only vs magic link (affects UI copy).
- **Currency:** Single default vs per-expense (MVP: per-expense is fine).
- **Categories:** Fixed list in app vs DB seed (MVP: fixed list in app).

---

## 11. Document pairing

- **Design tokens & components:** `DESIGN_SYSTEM.md`  
- **Engineering:** Supabase project `splitspend-mvp`, Flutter app (repo TBD).
