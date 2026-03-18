# Product Roadmap: Easy Mode

## Phase 1: MVP / App Store Launch (Critical Path)
**Goal:** Get a fully functional, blocking-capable app into the App Store.

### 1. App Blocking Engine (Highest Priority) ✅
The core value proposition requires actual app restriction, not just selection storage.
- [x] **DeviceActivity Extension**: Create a new target for `DeviceActivityMonitor`.
- [x] **ManagedSettings Integration**: Implement the logic to apply shields to the `BlockedApp` list during focus sessions.
- [x] **Persistence**: Ensure blocking rules survive app termination and device reboots.
- [ ] **Notifications**: Suppress notifications for blocked apps during focus (if permitted by API).

> **Setup Required**: See `BLOCKING_SETUP.md` for Xcode configuration steps.

### 2. Onboarding Flow ✅
Educate users and secure critical permissions before they start.
- [x] **Screen 1: Value Prop**: "Focus on one task at a time."
- [x] **Screen 2: Permissions**: Explainer + System prompt for FamilyControls (`AuthorizationCenter`).
- [x] **Screen 3: Initial Setup**: Quick access to the App Picker to set the first blocklist.
- [x] **Logic**: Show only on first launch (`@AppStorage`).

### 3. App Store Essentials
Non-code requirements that block submission.
- [ ] **Apple Developer Account**: Enrollment and certificates.
- [ ] **Privacy Policy**: Hosted URL explaining data usage (Mandatory for FamilyControls).
- [ ] **Assets**: App Icon (1024px), Screenshots (iPhone 6.5", 5.5", 6.9" displays).
- [ ] **Info.plist**: Add `NSScreenTimeUsageDescription` and `NSUserTrackingUsageDescription` (if needed).

### 4. Core Loop Refinement
Ensure the "Happy Path" is bug-free.
- [ ] **Emergency Exit**: Verify "Give Up" flow correctly unblocks apps immediately.
- [ ] **Haptics & Sound**: Tuning the completion event for maximum satisfaction (Pulse + Ding).
- [ ] **Empty States**: Ensure "Log" and "Settings" look good before data is added.

---

## Phase 2: Fast Follows (v1.1)
High-impact features that missed the MVP cut but are essential for retention.

### UI/UX Polish
- [ ] **Loading State**: Polished launch animation.
- [ ] **Focus Timer**: Subtle timer during focus mode to track session duration.
- [x] **Live Activities**: Lock screen widget showing current task and blocking status. ✅

### Enhanced Blocking
- [ ] **Strict Mode**: Option to disable the "Emergency Exit" or make it harder to cancel.
- [ ] **Pre-generated Lists**: One-tap blocklists (e.g., "Social Media Detox," "News Blocker").

---

## Phase 3: Future / Post-MVP (v2.0+)
Expanding the feature set for power users.

### Advanced Task Management
- [ ] **Task Resume/Pause**: Handle interruptions by splitting sessions.
- [ ] **Focus Continuity**: "Focus Again" button for recurring tasks.
- [ ] **Defer to Later**: Let users mark a task as "not now" so it is pre-filled the next time they open the app, turning abandonment into a deliberate recommitment.
  Track defer count and suggestion timing so repeated deferrals can resurface later as a gentle prompt instead of feeling like the app is nagging on every launch.
- [ ] **Smart Suggestions**: LLM-based task suggestions based on time of day/history.
- [ ] **Task Decoration**: AI-generated backgrounds/icons for specific tasks.

### Pro Blocking Features
- [ ] **Multiple Profiles**: Context-switching (e.g., "Deep Work" vs. "Light Admin").
- [ ] **Smart Suggestions**: Recommend apps to block based on actual usage stats.
- [ ] **Custom Shields**: Custom designs for the "App Blocked" screen (tech dependent).

### Analytics & Social
- [ ] **Rich History**: Charts showing focus time per day/week.
- [ ] **Share Progress**: Social share images for completed tasks ("I just focused for 2 hours").
