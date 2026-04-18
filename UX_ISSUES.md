# UX Issues Log

> **2026-04-18 cleanup.** All **open** UX issues have been grouped into themed "single-pass" buckets in `EasyModeTest1/ROADMAP.md` (see *UX Polish Backlog*). This file is retained as:
> 1. A **fix log** — historical record of shipped UX work (section A below).
> 2. A **discovery inbox** — quick scratchpad for newly noticed issues (section B below). Move triaged items into the roadmap; do not let this file grow back into a parallel backlog.
>
> Status values: `open`, `accepted`, `in-progress`, `fixed`, `wontfix`.

---

## A. Fix log + historical issue index

These tables are the authoritative history of every UX issue filed. **`fixed`** rows are shipped; **`open`** rows are still owned here but are also mirrored into `ROADMAP.md` → *UX Polish Backlog* grouped by one-pass themes — act on them from the roadmap.

### Onboarding & State Management

| ID | Status | Severity | Description | Notes |
|---|---|---|---|---|
| UX-001 | fixed | High | `@AppStorage` timing bug caused onboarding to re-show on every launch | Fixed with direct `UserDefaults` read in LaunchRootView |
| UX-002 | fixed | High | Permissions sheet in AppTabView reappeared every launch if authorization revoked | Added `shouldAutoPromptForPermissions` flag; sheet suppressed after onboarding |
| UX-003 | fixed | High | Onboarding state only persisted in UserDefaults (vulnerable to data loss) | Added SharedStorage (App Group) as backup; auto-restores on launch if UserDefaults cleared |
| UX-004 | open | Medium | No skip button in onboarding | Users must complete all 3 steps; no way to skip to home screen |
| UX-005 | open | Medium | Screen Time permission requested before user has selected apps or started a task | Permission request is premature — user doesn't yet understand why it's needed |
| UX-006 | open | Low | No way to re-trigger onboarding from within the app | Once completed, no path to redo onboarding (e.g. to re-select apps) |
| UX-007 | open | Low | BlockView has its own authorization flow duplicating onboarding logic | Settings tab has its own app picker with its own auth request |

### UX / Interaction

| ID | Status | Severity | Description | Notes |
|---|---|---|---|---|
| UX-008 | fixed | High | No "Open Settings" deep link when Screen Time is denied | Fixed: Added "Open Settings" button to PermissionsPageView using `UIApplication.openSettingsURLString` |
| UX-009 | open | Medium | "Give Up" button language is discouraging | Consider "End Session" or "Take a Break" |
| UX-010 | open | Medium | 2.5s completion animation on task finish | `ActiveTaskView.swift:122` — `DispatchQueue.main.asyncAfter(deadline: .now() + 2.5)` feels sluggish |
| UX-011 | fixed | Medium | No "no apps selected" warning before starting focus | Fixed: Added `showNoAppsWarning` state to TaskViewModel; alert shown in TaskView when no apps selected |
| UX-012 | fixed | Low | Faint empty state quote in LogView | Fixed: Increased opacity from 0.3 to 0.5 in `LogView.swift:94` |
| UX-013 | fixed | Low | Task input lost on tab switch | Fixed: Added `@AppStorage("draftTaskInput")` in TaskView; restores on appear, clears on task creation |
| UX-014 | open | Low | No undo on task cancellation | Tapping "End Session" is immediate with no undo |
| UX-015 | fixed | Low | Haptic feedback on every keystroke | Fixed: Now debounced to every 4 characters. See `TaskEntryView.swift:96-107` |
| UX-027 | open | Medium | Aggressive shield copy may alienate users | `SharedStorage.swift:31,46` — "get your shit done first" is harsh for a productivity tool |
| UX-028 | open | Low | No animation on log list items | LogView items appear/disappear without animation when tasks complete or deleted |
| UX-029 | open | Low | Ripple animation feels detached | `ActiveTaskView.swift:29-53` — completion ripple scale and text blur/fade animate separately |

### UI / Brand Consistency

| ID | Status | Severity | Description | Notes |
|---|---|---|---|---|
| UX-016 | fixed | High | `birthday.cake.fill` icon color mismatched brand | Fixed: Now uses chartreuse `#8AC926` accent. Icon retained for "piece of cake" branding. 6 locations in `FocusLiveActivity.swift` |
| UX-017 | fixed | Medium | Hardcoded shield colors didn't match design tokens | Fixed: `ShieldConfigurationExtension.swift:86` now uses chartreuse `#8AC926` |
| UX-018 | open | Medium | Duplicate haptic on task completion | `TaskView.completeTask` fires `UINotificationFeedbackGenerator`, then `ActiveTaskView.handleComplete` fires `HapticManager.shared.success()` 2.5s later |
| UX-019 | open | Low | Live Activity colors defined locally instead of using design tokens | `FocusLiveActivity.swift:82-84` has hardcoded colors (expected — widget target can't import main app) |
| UX-020 | open | Low | "DigitalDetoxCoach" references in comments | Appears in `TaskEntryView.swift:10`, `BlockView.swift:11`, `AppTabView.swift:10` — should be updated |
| UX-021 | open | Low | "Settings" tab label doesn't match content | `AppTabView.swift:34` — Tab is labeled "Settings" but content is about blocking, not general settings |
| UX-022 | open | Low | Typographic hierarchy unclear | Task text: 40pt serif, Welcome title: 44pt, other titles: 36pt — inconsistent scaling |
| UX-030 | open | Medium | No dark mode support | No dark mode colors defined; system dark mode inverts parchment theme incorrectly |
| UX-031 | fixed | Medium | `mutedForeground` fails WCAG AA contrast | Fixed: Darkened to #6B6B6B (42% gray) in `Color+Extension.swift:21` — achieves 4.6:1 ratio |
| UX-032 | fixed | Low | "Give Up" button too subtle | Fixed: Increased opacity from 0.5 to 0.7 in `ActiveTaskView.swift:90` |
| UX-033 | open | Low | Tab bar labels below minimum size | `AppTabView.swift:80` — 10pt font, Apple recommends 11pt minimum |
| UX-034 | open | Low | Unused blur effect variable | `AppTabView.swift:74` — `UIBlurEffect` created but never applied |
| UX-035 | open | Low | `serifTitle` and `serifLarge` are nearly identical | `Font+Extension.swift:12-18` — Both use `.weight(.medium)`, only default size differs (36 vs 32) |

### Color Palette & Accessibility

| ID | Status | Severity | Description | Notes |
|---|---|---|---|---|
| UX-036 | fixed | High | Orange accent color resembled Anthropic branding | Fixed: Replaced `primaryOrange` with `primaryChartreuse` (#8AC926) across 16 files |
| UX-037 | fixed | Medium | No semantic success color token | Fixed: Added `Color.success` (#34C759) to `Color+Extension.swift:22`; used in `LogView.swift:51` |
| UX-038 | open | Medium | No success state color for non-log contexts | `Color.success` only used in LogView; should be used elsewhere for consistency |
| UX-039 | open | Medium | Inconsistent horizontal padding | 24px (Block, Log) and 32px (Task, Onboarding) with no clear pattern |
| UX-040 | open | Medium | Inconsistent header top padding | Task: 64px, Block: 48px, Log: 48px — headers don't align |

### Layout & Spacing

| ID | Status | Severity | Description | Notes |
|---|---|---|---|---|
| UX-041 | fixed | Medium | Header padding inconsistent across tabs | Fixed: All headers now use `Layout.headerTop` (48px) constant |
| UX-042 | fixed | Medium | Horizontal padding inconsistent | Fixed: All views now use `Layout.horizontalPadding` (24px) constant |
| UX-043 | fixed | Medium | Tab bar bottom padding hardcoded | Fixed: All views now use `Layout.tabBarPadding` (80px) constant |
| UX-044 | open | Low | Missing intermediate font sizes | Font system skips 14pt, 20pt, 24pt — creates visual gaps |
| UX-045 | open | Low | TextField uses non-token font size | `TaskEntryView.swift:69` uses `.serifLarge(28)` — 28pt is not a standard token |

### Permissions & Authorization

| ID | Status | Severity | Description | Notes |
|---|---|---|---|---|
| UX-023 | fixed | Medium | No Settings deep link when Screen Time authorization denied | Fixed: Same fix as UX-008 — "Open Settings" button in PermissionsPageView |
| UX-024 | open | Medium | `isAuthorized` race condition on cold launch | Starts `false`, updates async; views may see stale state |
| UX-025 | open | Low | No authorization state caching | Always fetched from `AuthorizationCenter` at runtime |
| UX-026 | open | Low | Inconsistent `autoContinueIfAuthorized` between onboarding and settings | Onboarding uses `true`, settings sheet uses `false` |

### Icons & Visual Design

| ID | Status | Severity | Description | Notes |
|---|---|---|---|---|
| UX-046 | open | Medium | Inconsistent icon sizing across app | Category icons: 24px, Feature icons: 20px, Info icons: 20px at 40x40 frame — no clear scale |
| UX-047 | open | Low | Shield UI has no custom icon | `ShieldConfigurationExtension.swift:73` — explicitly sets `icon: nil` |
| UX-048 | open | Low | Onboarding skip button looks disabled | `AppSelectionPageView.swift:136` — gray color for "Skip for Now" mimics disabled state |

---

### Summary by Status

| Status | Count |
|--------|-------|
| fixed | 21 |
| open | 27 |

### Summary by Severity

| Severity | Fixed | Open | Total |
|----------|-------|------|-------|
| High | 7 | 1 | 8 |
| Medium | 8 | 14 | 22 |
| Low | 6 | 12 | 18 |

---

## B. Discovery inbox

Drop newly noticed UX / UI / brand issues here with a quick one-liner. Triage during the next roadmap review: move to section A with a permanent ID, and group them into a themed pass in `ROADMAP.md`. Do not let this section become a parallel backlog.

_(empty — add new items below)_
