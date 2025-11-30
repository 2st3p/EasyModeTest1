# Brief

## Problem

1. Everyone is addicted to their phone, picking it up hundreds of times per day. This constantly interrupts deep work and prevents people from getting things done.
2. Even for high-agency people who prioritize their work and block out distractions, current options are limited. Task manager apps are great for capturing and organizing, but they don't have a true ACTION user mode. They leave you with large, overwhelming to-do lists. Focus products don’t encourage accomplishing a single action.

## Solution

**Easy Mode**: a barebones, open sourced iOS app that empowers people by choosing one thing to knock down (after all, we can really only focus on one thing at a time).

The user chooses what they want to accomplish, they type it in, and hit go. By entering the task, they are announcing their goal, making a commitment with themselves to focus on it until complete. There is also a functional angle -- entering a task "takes over" your phone, preventing you from accessing distracting (or addicting) apps, and giving you a visual focus/reminder of what you're supposed to be doing.

When you complete the task, an extremely satisfying and joyful animation celebrates your hard work, giving you access back to your phone and inviting you to start the next task. We track your hard work in a log to review all the progress.

# Specs

## Onboarding (New)

Core goal: specific onboarding to establish value and gain necessary permissions for blocking apps.

- **Screen 1: Value Prop**
    - "Welcome to Easy Mode."
    - Brief explanation: "Focus on one task at a time. We help you block distractions so you can get work done."
- **Screen 2: Permissions**
    - Explanation: "To help you focus, Easy Mode needs permission to manage apps during your focus sessions."
    - Button: "Grant Permission" (Triggers FamilyControls/Screen Time API request).
    - *Critical*: User must approve this to proceed.
- **Screen 3: Initial App Selection**
    - "Select the apps that distract you the most."
    - Presents a list of installed apps/categories using the FamilyControls picker.
    - User selects apps to **Block** (Blacklist strategy).

## Features

### [Home tab] Empty State

Core goal: Easily let users input what they want to get done so they can get to work.

- Header copy
    - Prompt: What do you want to accomplish next?
- Empty text box, 1/3 down the screen.
    - Strong outline and bold blinking cursor to invite typing
    - Character limit: 90
- Tapping box pulls up keyboard and surfaces a submit button
    - Button copy: Lock in
    - Tapping button triggers transition to Focus Mode

### Preferences Tab
- Empty state following iOS components
- **App Selection (Blacklist Strategy)**:
    - Display currently blocked apps/categories.
    - Button/Control to "Edit Blocked Apps" which re-opens the FamilyControls picker.
    - User selects apps to **ADD** to the blocked list (Blacklist).

### Log Tab
- Reverse chron vertical list of tasks completed

### [Home tab] Focus Mode In-app

Core goal: Show a user what they’re focusing on to motivate them. Represent the state of the app which controls access to other apps.

- Large, high-impact text displays the focusing task in the middle 1/3 of the screen
    - Scale text to fit. Maximum 90 characters
- One button below the text to complete the task, with a sleek checkmark icon.
- Tapping the complete button triggers an extremely satisfying completion animation, like a strong, vibrating haptic pulse and a ding (ie Apple airdrop tap connection). The text of the current task dissolves away.
- **Emergency Exit (Cancel Flow)**
    - Small, low-emphasis "Cancel" or "Give Up" button (secondary UI).
    - Confirmation Alert: "Are you sure? You will lose progress on this session."
    - If confirmed: Ends focus mode, unblocks apps, does *not* log the task as complete.

### Focus Mode Functionality & Blocking

- **Blocking Logic:**
    - When Focus Mode is active, the selected apps (from Preferences) are restricted using `DeviceActivity` and `ManagedSettings`.
    - **Notifications:** Attempt to suppress notifications from blocked apps during focus sessions (via `shield.application(categories: ...)` settings if available/reliable, otherwise rely on standard Shield behavior).
- **Shield UI (Restricted Apps):**
    - When user opens a blocked app, iOS presents a "Shield" view.
    - *Constraint*: We cannot use custom buttons or arbitrary interactive UI here due to Apple's restrictions.
    - **Customization:**
        - Background color: Match app theme (Light parchment/sepia).
        - Icon: App logo.
        - Title: "Focus Mode Active"
        - Subtitle: Display the current task text (e.g., "Finish the report").
        - Primary Button: Standard system button (e.g., "OK" or strict blocking with no override).
- **Persistence:**
    - If the user force-quits Easy Mode, the restrictions *must* remain active (managed by the system extension).
    - If the phone reboots, restrictions should persist until the session is explicitly ended or times out.

# Design
## Design language

- Retro-future
    - Familiar but inspiring
    - Inspiration: Arc Browser, Rabby R1
- Minimal, but bold
    - High-contrast, high-impact, strong lines
    - Inspiration: Notion, Things 3
- Fun
    - Not a stuffy to-do app
    - Inspiration: Anthropic Claude
- Spiritual-nouveau 
	- A nod to the zen, but not too mumbo jumbo
	- Inspiration: erewhon, online ceramics
- Color story
    - Light parchment/sepia backgrounds
    - Strong black lines and outlines
    - Splashes of yellow-orange or hot pink
- Iconography
    - Modern, playful
    - Inspiration: Notion

# Post-MVP / Future

### Advanced Task Management
- **Task Resume & Pausing**: Option to pause tasks and pick up on them later. This handles interruptions or long tasks by logging two different sessions (e.g., "Report - Session 1" and "Report - Session 2").
- **Focus Continuity**: "Focus again" or "Keep focusing" option that surfaces the prior task for quick re-entry.
- **Smart Suggestions**: LLM-suggested tasks based on history or time of day.
- **Task Decoration**: LLM-generated imagery, icons, or themes for a specific task to create a unique, interesting background while focusing.

### Enhanced Blocking & Profiles
- **Multiple Focus Profiles**: Create distinct app lists for different contexts (e.g., "Deep Work" blocks everything, "Light Admin" allows Slack/Email but blocks Social).
- **Pre-generated Lists**: "One-click" block lists (e.g., "Social Media Detox," "News Blocker").
- **Smart Suggestions**: Suggested apps to block based on usage patterns.
- **Differentiated Shields**: Custom blocking screens (Shields) based on the specific app or category being blocked (if technically feasible within Apple's constraints).

### UI/UX Polish
- **Loading State**: Polished launch experience with logo animation and fade-in.
- **Live Activities**: iOS Live Activity widget on the lock screen showing the current task and focus status.
- **Focus Timer**: Small, plain-text timer counting the duration of the current focus session, which is then logged in the history.


