# Product Roadmap: Easy Mode

> **Source of truth** for outstanding work. Historical spec / PRD / early requirements live in `docs/archive/`.
> Last validated against source: **2026-04-18**.

## Product brief (condensed)

- **Problem** — phones interrupt deep work; task apps overwhelm; focus apps do not push a single next action.
- **Solution** — a minimalist iOS app where the user types **one** thing they want to accomplish, hits go, gets distractions shielded, and gets a satisfying completion moment. A log keeps score.
- **Design language** — retro-future, minimal-but-bold, light parchment + strong lines, chartreuse accent, serif display type. (See live code and `UX_ISSUES.md` archive at bottom for specifics.)

---

## Code Review Findings (2026-03-25, re-validated 2026-04-18)

### High Priority

1. **`Item` model naming** — Still `final class Item` at `EasyModeTest1/Models/Item.swift:13`. Represents a task with `taskText`, `timestamp`, `isInProgress`, `isCompleted`, `isCancelled`, `completedAt`, `cancelledAt`. Rename to `FocusTask` (or similar). **Cost:** a SwiftData migration.

2. **Silent task cancellation** — Creating a new task while one is in progress still marks every existing in-progress task `isCancelled = true` with no prompt.
   - `EasyModeTest1/ViewModels/TaskViewModel.swift:45-50`.

### Medium Priority

3. **DeviceActivity schedule doesn't repeat** — Schedule is midnight → 23:59 with `repeats: false`, so the monitored interval does not automatically roll each day.
   - `EasyModeTest1/Blocking/ScreenTimeManager.swift:228-232`.

4. **BlockViewModel bidirectional sync** — `selection.didSet` writes to `ScreenTimeManager.shared.activitySelection`; `syncSelection()` pulls the other way. No known break, but worth a pass for drift in edge cases.
   - `EasyModeTest1/ViewModels/BlockViewModel.swift:28-32`.

5. **SharedStorage App Group fallback** — When the App Group suite is missing, `makeDefaults()` silently returns `.standard`; extensions then see none of the shared state. A `print` warning is all we get.
   - `Shared/SharedStorage.swift:113-118`.

6. **Unit test gaps** — Present: `TaskViewModelTests`, `BlockSelectionTests`, `SharedStorageTests`, `LaunchStateCoordinatorTests`, `SelectionMetricsTests` (static helpers only), `ExtensionConfigurationTests` (extension bundle shape). Still thin/absent: `ScreenTimeManager` shield + scheduling integration, `LiveActivityManager`, `LogViewModel`, most UI flows beyond launch.

7. **`LogView` missing management UI** — `LogViewModel` exposes `deleteTasks` and `clearAll`, but `LogView` does not wire swipe-to-delete, edit menu, or clear-all. (Original PRD and REQUIREMENTS both called for delete + clear-all.)

---

## Phase 1: MVP / App Store Launch (Critical Path)

**Goal:** Ship a functional, blocking-capable build to the App Store.

### 1. App Blocking Engine ✅
Core value prop — restrict apps, not just remember selections.
- [x] `DeviceActivityMonitor` extension target.
- [x] `ManagedSettings` integration — shields applied during focus sessions.
- [x] Persistence — blocking survives app termination / reboot.
- [ ] **Notifications** — suppress notifications for blocked apps during focus where the API allows.

> **Setup**: `BLOCKING_SETUP.md` documents the Xcode target/entitlement wiring.

### 2. Onboarding Flow ✅
- [x] Welcome / value prop screen.
- [x] Permissions screen with `FamilyControls` authorization + Settings deep link (UX-008 / UX-023 fixed).
- [x] Initial app selection via `FamilyActivityPicker` (simulator fallback list).
- [x] First-launch gating via `@AppStorage` + `SharedStorage` backup (UX-001..003 fixed).

### 3. App Store Essentials
- [ ] Apple Developer account enrollment / certificates.
- [ ] Privacy policy hosted URL (mandatory for FamilyControls).
- [ ] Assets: App Icon 1024px, screenshots (iPhone 6.5", 5.5", 6.9").
- [x] Usage strings — main target sets `INFOPLIST_KEY_NSFamilyControlsUsageDescription` in the Xcode project. Add `NSUserTrackingUsageDescription` only if ATT is shipped (not in scope today).

### 4. Core Loop Refinement
- [ ] **Emergency Exit** — verify "Give Up" unblocks apps immediately end-to-end. Note button copy is currently **"Give Up"** with confirm alert **"End Session"** (`ActiveTaskView.swift:88, :102`); UX-009 is a pending copy decision below.
- [ ] **Haptics & sound** — de-duplicate and tune completion (see UX-018 in Active-Task Polish below).
- [ ] **Empty states** — History already has a quote empty state; "Settings"/Block tab empty state still needs a pass.

---

## Phase 2: Fast Follows (v1.1)

### UI / UX Polish
- [ ] **Loading state** — polished launch animation.
- [ ] **Focus timer** — subtle in-session duration display, also logged to history.
- [x] **Live Activities** — lock-screen widget with current task and blocking status. ✅

### Enhanced Blocking
- [ ] **Strict Mode** — option to disable or delay the Emergency Exit.
- [ ] **Pre-generated blocklists** — one-tap presets ("Social Detox", "News Blocker", etc.).

### Task Continuity (Pause & Resume)
Consolidates what was previously three Phase 3 bullets (*Task Resume/Pause*, *Focus Continuity*, *Defer to Later*) into a single coherent feature, and provides the real fix for **UX-009** by replacing "Give Up" as the primary exit action. Core idea: running out of time should not mean discarding the task — you **Pause**, phone goes back to normal, and the task resurfaces next time you open the app (and optionally fires a reminder).

- [ ] **Primary action rename** — in `ActiveTaskView`, promote **"Pause"** as the primary secondary action. Tapping it unblocks apps, leaves the `Item` in a `paused` state, and exits focus. Confirm alert softened ("You can pick this up later.").
- [ ] **"Give Up" decision** — keep as a smaller, more explicit destructive action below Pause, or remove entirely. **Recommendation:** keep but de-emphasize (three-dot menu or long-press); a clean discard is still useful for "this was a bad idea." **Open decision — revisit before build.**
- [ ] **Resume surface** — on app launch, if a paused task exists, `TaskEntryView` pre-fills its text and shows a subtle "Pick up where you left off?" affordance. User can edit the text, lock in, or dismiss.
- [ ] **Optional reminder** — when pausing, offer "Remind me in 1h / 3h / this evening" via local notification. Reuses the `UNUserNotificationCenter` permission from **Scheduled Focus**; deep-links back into task entry just like a scheduled prompt.
- [ ] **Data model change** — add a `paused` state. Current `Item` uses three booleans (`isInProgress` / `isCompleted` / `isCancelled`); a fourth boolean is a smell. **Recommend pairing with code-review #1** (`Item` → `FocusTask`) and migrating to a `status` enum (`pending | inProgress | paused | completed | cancelled`) plus `pausedAt: Date?`. One SwiftData migration, two roadmap items resolved.
- [ ] **Nag guardrail** — track pause/resume count per task; if a task gets paused repeatedly without progress, surface it more gently (or prompt the user to either commit or discard) rather than harder. Keeps the app from feeling like a to-do list that nags.
- [ ] **UX-009 closure** — once Pause ships as primary, mark UX-009 `fixed` with this feature as the fix.

### Scheduled Focus (on-thesis extension, not "routines")
Positioned as a prompt to **commit**, not a passive time block. Users schedule moments (e.g. weekdays 9am, evenings 7pm) and at those times get a local notification asking **"What do you want to accomplish next?"** Tapping deep-links into the normal task entry / lock-in flow. Blocking only kicks in if the user actually starts a session — nothing is enforced by the schedule itself. This keeps the product’s single-task commitment pillar intact instead of drifting into generic Screen Time scheduling.

- [ ] **Data model** — `ScheduledFocus` entity (name, weekday set, local time, enabled). Persisted via SwiftData; no new App Group state required for the prompt itself.
- [ ] **Notifications** — request `UNUserNotificationCenter` authorization (new permission surface; coordinate with Phase 1 onboarding or defer to first schedule creation). Schedule repeating local notifications per `ScheduledFocus`.
- [ ] **Deep link** — tapping the notification opens `TaskView` in task-entry mode with keyboard already up; aligns with existing `draftTaskInput` handling.
- [ ] **Settings UI** — list of schedules in the "Settings"/Block tab (or a new tab) with add / edit / toggle / delete.
- [ ] **Edge cases** — if a task is already in progress when a scheduled prompt fires, suppress the notification (don't nag mid-focus). Define snooze/ignore behavior.
- [ ] **Ties into code-review #3** — this is the natural moment to revisit `DeviceActivitySchedule(repeats: false)` in `ScreenTimeManager.swift:228-232`; scheduled focus may need repeating monitors.

### Deferred (possibly Phase 3+) — Broader time-based controls
Explicitly **not** a V1 goal; captured so it isn't forgotten. These are the Opal/Jomo-adjacent capabilities, kept only if they can be framed in a way that differentiates from a paid "digital wellbeing" tool. Don't build these until Scheduled Focus ships and you see real demand.

- [ ] **Guardrails / Quiet Hours** — always-on blocks for specific time windows (e.g. after 10pm), independent of an active focus session.
- [ ] **Per-app daily limits** — e.g. "Instagram, 20 min/day." Only ships if it can be tied back to the commitment thesis (e.g. limit-hit prompts "start a focus session instead").

---

## Phase 3: Future / Post-MVP (v2.0+)

### Advanced Task Management
_Note: **Task Resume/Pause**, **Focus Continuity**, and **Defer to Later** were consolidated into **Task Continuity (Pause & Resume)** in Phase 2._

- [ ] **Multi-session analytics** — if a task is paused and resumed multiple times, aggregate the sessions in the Log (e.g. "Report — 3 sessions, 1h 42m total").
- [ ] **Smart Suggestions (tasks)** — LLM-suggested tasks by time of day or history.
- [ ] **Task Decoration** — AI-generated background / imagery per task.

### Pro Blocking Features
- [ ] **Multiple Profiles** — e.g. "Deep Work" vs "Light Admin" app sets.
- [ ] **Smart Suggestions (blocks)** — recommend apps to block from actual usage.
- [ ] **Custom / Differentiated Shields** — per-app or per-category shield designs (within Apple constraints).

### Analytics & Social
- [ ] **Rich History** — charts for focus time per day / week.
- [ ] **Share Progress** — shareable completion images ("I just focused 2h").

---

## UX Polish Backlog

Open UX items rolled up from `UX_ISSUES.md` (as of 2026-04-18), grouped so each theme can be tackled in one sitting. Severity follows the original log.

### A. Onboarding & permissions pass
- [ ] **UX-004** _Medium_ — Add skip option (or "do this later" path) in onboarding.
- [ ] **UX-005** _Medium_ — Request Screen Time permission only at the moment the user needs it (defer from pre-task onboarding).
- [ ] **UX-006** _Low_ — Provide a way to re-trigger onboarding from Settings (e.g. re-select apps).
- [ ] **UX-007** _Low_ — `BlockView` currently has its own authorization flow; unify with onboarding’s flow.
- [ ] **UX-024** _Medium_ — Cold-launch race: `isAuthorized` starts `false` and updates async; views can see stale state.
- [ ] **UX-025** _Low_ — No caching of auth state; always fetches from `AuthorizationCenter`.
- [ ] **UX-026** _Low_ — `autoContinueIfAuthorized` differs between onboarding (`true`) and settings sheet (`false`); decide one behavior.

### B. Active-task flow polish
- [ ] **UX-009** _Medium_ — Soften "Give Up" copy (candidates: "End Session", "Take a Break"). Confirm alert already says "End Session".
- [ ] **UX-010** _Medium_ — Completion animation waits 2.5s (`ActiveTaskView.swift` `DispatchQueue.main.asyncAfter(... 2.5)`) — feels sluggish.
- [ ] **UX-014** _Low_ — No undo on cancellation; tapping confirm is immediate.
- [ ] **UX-018** _Medium_ — Duplicate completion haptic: `TaskView.completeTask` fires `UINotificationFeedbackGenerator`, then `ActiveTaskView.handleComplete` fires `HapticManager.shared.success()` 2.5s later.
- [ ] **UX-029** _Low_ — Ripple scale and text blur/fade animate separately; unify into one sequence.

### C. Brand & copy sweep (shields, Live Activity, comments)
- [ ] **UX-027** _Medium_ — Rewrite shield subtitles in `Shared/SharedStorage.swift:31,46` ("...get your shit done first.") — current copy is harsh for a productivity brand.
- [ ] **Live Activity icon (code-review #3)** — `birthday.cake.fill` appears **5** times in `EasyModeLiveActivity/FocusLiveActivity.swift` (lines 23, 46, 57, 73, 124). Either formally bless the cake metaphor (it is the tinted brand mark per UX-016) or replace.
- [ ] **UX-020** _Low_ — Stale "DigitalDetoxCoach" comments still appear in `ActiveTaskView.swift`, `BlockView.swift`, `LogView.swift`, `TaskEntryView.swift`, `AppTabView.swift` (verified present). Rename to EasyMode.
- [ ] **UX-021** _Low_ — Tab labeled "Settings" in `AppTabView.swift:34` actually hosts `BlockView`. Rename to "Block" (or split settings out).

### D. Design tokens, typography, dark mode
- [ ] **UX-019** _Low_ — Live Activity colors defined locally (`FocusLiveActivity.swift:82-84`). Expected (widget target can't import the main app module), but worth a shared-constants scheme.
- [ ] **UX-022** _Low_ — Typographic hierarchy mixed (task text 40pt, welcome 44pt, titles 36pt). Rationalize scale.
- [ ] **UX-030** _Medium_ — No dark mode: system dark inverts parchment incorrectly. Define dark palette or opt out explicitly.
- [ ] **UX-033** _Low_ — Tab bar labels at 10pt (`AppTabView.swift:80`); Apple recommends 11pt min.
- [ ] **UX-034** _Low_ — Unused `UIBlurEffect` variable in `AppTabView.swift:74` (verified declared, never applied).
- [ ] **UX-035** _Low_ — `serifTitle` and `serifLarge` nearly identical (same weight, only default size differs); merge or differentiate.
- [ ] **UX-038** _Medium_ — `Color.success` only used in `LogView`; extend to other success contexts.
- [ ] **UX-044** _Low_ — Font size ladder skips 14/20/24pt — add to remove visual gaps.
- [ ] **UX-045** _Low_ — `TaskEntryView.swift` uses non-token size (`.serifLarge(28)`) — introduce token or snap to scale.

### E. Layout & spacing consistency (verify before re-opening)
- [ ] **UX-039** _Medium_ — Horizontal padding reported inconsistent. Much of this was unified via `Layout.horizontalPadding` (UX-042 fixed); re-audit before acting.
- [ ] **UX-040** _Medium_ — Header top padding reported inconsistent. Likewise largely unified via `Layout.headerTop` (UX-041 fixed); re-audit.

### F. History (Log) polish
- [ ] **UX-028** _Low_ — No animation when log items appear / disappear.
- [ ] Management UI (see code-review item #7 above) — swipe-to-delete and clear-all still not wired.

### G. Icons & visual polish
- [ ] **UX-046** _Medium_ — Reconcile icon sizing (category 24, feature/info 20 at 40x40 frame).
- [ ] **UX-047** _Low_ — Shield UI explicitly sets `icon: nil` (`ShieldConfigurationExtension.swift:73`). Provide the EasyMode mark.
- [ ] **UX-048** _Low_ — Onboarding "Skip for Now" button looks disabled (gray). Give it a real secondary style.

### H. Historical / fixed UX items (for context)

21 UX issues are marked `fixed` in the old log — onboarding persistence, Settings deep-link, accent-color change, `mutedForeground` contrast, `Layout` constants, no-apps warning, draft-task preservation, haptic debouncing, shield color tokens, empty-state opacity, and Give-Up button opacity. Kept in `UX_ISSUES.md` as a fix log; treated as shipped.

---

## Archive pointers

- `docs/archive/spec.md` — older "current feature spec" snapshot (mostly accurate as a description of current behavior).
- `docs/archive/PRD.md` — original product brief / design language. Phase-3-equivalent items here have been promoted above.
- `docs/archive/REQUIREMENTS.md` — early engineering requirements. Notable stale claim: "V1 is storage-only" — blocking is now implemented. Notable stale schema: `Item` fields here do not match the current `Item` model.
- `docs/archive/2025-12-29-comprehensive-improvements.md` — prior implementation plan; most tasks landed (SharedStorage tests, extension config tests, task lifecycle).
