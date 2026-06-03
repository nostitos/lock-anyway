# Idle Lock Comparable Apps And Naming Research

Date: 2026-06-03

## Recommendation

Recommended app name: **Lock Anyway**

Positioning line: **Apps can keep your Mac awake. Not unlocked.**

Why this name:

- It matches the clarified product problem: one process should not leave the Mac unlocked all day.
- It says the Mac will lock even when YouTube, RustDesk, a download helper, or another process keeps the display awake.
- It avoids the anti-sleep/caffeine naming lane used by apps like Amphetamine, Caffeine, Lungo, and KeepingYouAwake.
- It avoids proximity-lock wording such as "away" or "near", which implies Bluetooth/iPhone/Apple Watch detection rather than real keyboard/mouse idle time.
- It is plain enough for an average Mac user: the app locks anyway.
- Search results did not show an obvious macOS app using "Lock Anyway" or "LockAnyway" as a product name during this pass.

Runner-up: **LockCue**. It is more visual and UI-focused, but it still describes the warning more than the core protection.

Keep **Idle Lock** as the internal/project name if you want, but for an average Mac user I would ship the app as:

> **Lock Anyway**  
> Apps can keep your Mac awake. Not unlocked.

## WebGPT Result Summary

The ChatGPT Web/WebGPT wrapper timed out while waiting for the answer, but both prompts completed in the browser. I exported the conversations locally, then folded the useful results into this report.

WebGPT's detailed research answer recommended **LockGrace** with the tagline:

> LockGrace - a countdown before your Mac locks.

The shorter naming-only answer recommended **AwayLock**, but direct research found an existing App Store app named AwayLock for proximity auto-locking. Because of that conflict, AwayLock should be avoided.

After user feedback, **LockGrace** was demoted because it over-emphasizes the grace/countdown UI. The real purpose is to stop one awake-keeping process from leaving the Mac unlocked all day. The revised recommendation is **Lock Anyway**.

## Competitive Landscape

### Built-In macOS Lock Screen

Apple's built-in Lock Screen settings can lock a Mac after screen saver or display sleep begins. The key limitation is that this depends on macOS display/screen-saver behavior and does not provide a custom always-on-top warning with add-time buttons.

Source: [Apple Support - Change Lock Screen settings on Mac](https://support.apple.com/en-mide/guide/mac-help/-mh11784/mac)

Implication for this app: the value is not "macOS cannot lock." The value is a clearer, more reliable user-facing lock workflow when media playback, remote sessions, or sleep blockers interfere with normal display idle behavior.

### Keep-Awake Menu Bar Apps

These apps are adjacent but mostly solve the opposite problem: they keep the Mac awake, often with timers and menu bar controls.

| App | What it does | Naming/positioning lesson |
| --- | --- | --- |
| [Amphetamine](https://apps.apple.com/us/app/amphetamine/id937984704?mt=12) | Powerful keep-awake app with sessions, triggers, display/system sleep controls, and an inactivity lock feature. | It owns the advanced keep-awake category, but the name and mental model are about preventing sleep, not enforcing lock. |
| [KeepingYouAwake](https://keepingyouawake.app/) | One-click menu bar utility to prevent sleep for predefined durations. | Very clear utility name; good proof that direct names work for Mac utilities. |
| [Lungo](https://apps.apple.com/us/app/lungo/id1263070803?mt=12) | Prevents sleep/dimming, supports default durations, shortcuts, and terminal/script control. | Short brand name, but requires a tagline to explain the purpose. |
| [Caffeine](https://www.caffeine-app.net/) | Classic menu bar cup toggle for preventing sleep/dimming/screensaver. | Strong icon metaphor, but the caffeine/awake metaphor points away from locking. |
| [Jolt of Caffeine](https://apps.apple.com/us/app/jolt-of-caffeine/id1437130425) | Free anti-sleep utility with preset/custom times and a menu bar countdown timer. | Timers and menu bar countdowns are expected in this category. |
| [Tostato](https://tostato.app/) | Native menu bar keep-awake app with display/no-idle/screen-saver suppression controls and timed sessions. | Modern small utilities emphasize no Dock icon, simple controls, and clear durations. |
| [RunningCat](https://runningcat.app/) | Menu bar app whose animation doubles as a keep-awake state indicator; includes timed sessions. | A stateful icon can replace status text in the menu bar. |

Gap: none of these are primarily "lock after HID idle with a visible warning and add-time choices." Amphetamine is the closest because it includes an inactivity lock option, but it is a broad keep-awake power-user tool.

### Break Reminder And Overlay Apps

These apps are useful references for the countdown panel and snooze UX.

| App | Relevant behavior | Lesson for Lock Anyway |
| --- | --- | --- |
| [Time Out](https://apps.apple.com/us/app/time-out-break-reminders/id402592703) | Break reminders, dimmed screens, progress, postpone/skip buttons, notifications/sounds/actions. | Users expect postpone controls to be visible during an interruption. |
| [Standup](https://getstandup.io/) | Menu bar native break app with floating warning, full-screen overlay, countdown, and configurable snooze. | A full-screen overlay can feel acceptable if the copy is concise and the choices are obvious. |
| [iRetina](https://iretina.app/) | Eye-care break app with heads-up alerts, snooze/skip/start-early, and themed full-screen overlays. | A 1-minute heads-up before a forced action is a familiar pattern. |
| [Workrave](https://workrave.org/docs/breaks/reminder/) | Gentle reminders escalate visually if ignored; break windows can include postpone/skip/lock behavior. | Escalation should be visual and predictable, not dim/ambiguous. |
| [BreakOverlay](https://apps.apple.com/us/app/breakoverlay-eye-break-timer/id6757116138?mt=12) | Full-screen overlay across monitors, menu bar app, snooze, opacity control. | Overlay brightness/opacity should be user-tunable or at least clearly visible by default. |
| [LookAway](https://apps.apple.com/us/app/lookaway-break-reminder/id6747192301?mt=12) | Menu bar break companion with skip/snooze and adaptive behavior. | "Snooze without nagging" is a good design principle for the add-time buttons. |
| [Take a break](https://apps.apple.com/ca/app/take-a-break-timer-reminder/id1457158844?mt=12) | Eye-break timer with menu bar countdown and optional automatic screen lock. | Relevant because it connects break enforcement and lock behavior, but the category remains wellness-first rather than security-first. |

Gap: break apps have the warning/snooze interaction, but they do not solve secure macOS locking after true idle time.

### Proximity And Presence Lock Apps

These apps lock when the user walks away, but require extra signals such as Bluetooth, iPhone/Apple Watch, or camera/face detection.

| App | What it does | Difference from Lock Anyway |
| --- | --- | --- |
| [AwayLock](https://apps.apple.com/us/app/awaylock-proximity-auto-lock/id6742342445) | Locks using iPhone/Apple Watch/Bluetooth proximity. | Good consumer name, but already in use; avoid "Away Lock." |
| [Near Lock](https://www.nearlock.me/) | Locks/unlocks Mac using iPhone proximity and related controls. | Requires a phone workflow; not a simple idle timer. |
| [GateKeeper Proximity](https://gatekeeperhelp.zendesk.com/hc/en-us/articles/360058188493-What-is-Walk-Away-Lock) | Enterprise proximity-based walk-away locking. | Strong compliance/security angle, but not average-user menu bar positioning. |
| [ProximityLock](https://proximitylock.app/) | Locks Mac when iPhone/Apple Watch Bluetooth signal indicates the user left. | Solves presence, not media/display-sleep-blocked idle locking. |
| [Avalw Shield](https://shield.avalw.ai/) | Uses face detection to lock/hide the screen when the user leaves or someone looks over. | More privacy/security surveillance positioning; heavier than this app's simple idle-lock behavior. |

Gap: these are security/privacy apps, but they are not "set a timer, show warning, add time, then lock."

### Admin Scripts And Compliance Tools

Admin-oriented solutions exist for enforcing idle lock, often by reading `HIDIdleTime` and running a launchd job.

Example: [Automox Worklet - Enforce Lock Screen on Inactivity](https://www.automox.com/worklets/enforce-lock-screen-inactivity-mac) describes polling `IOHIDSystem` / `HIDIdleTime` and using a launch daemon to enforce a configurable inactivity timeout.

Gap: these are not consumer-friendly. They usually have no menu bar control, no warning panel, no snooze buttons, and no clean first-run permission/install flow.

## Product Opportunity

The useful wedge is:

> A normal Mac user wants the machine to lock when they are truly idle, even if YouTube, RustDesk, screen sharing, or another app prevents display sleep. But they still need a visible last chance to add time.

That combines three categories that are usually separate:

- **Lock/security:** force macOS lock after true inactivity.
- **Menu bar timer:** simple current-state control and delay choices.
- **Break-reminder UX:** visible overlay, countdown, snooze/add-time buttons.

The most important differentiators to preserve:

- Real HID idle time, not display sleep.
- Lock enforcement that is independent of one process blocking display sleep.
- Clear countdown panel on all screens.
- Add-time buttons: 15 minutes, 30 minutes, 1 hour, 2 hours.
- Keyboard shortcuts: 1, 2, 3, 4 map left-to-right to those add-time choices.
- One canonical installed app location so permissions do not break after updates.
- No admin password prompt during normal updates/reloads.

## Naming Options

| Name | Pros | Cons | Verdict |
| --- | --- | --- | --- |
| **Lock Anyway** | Directly captures the clarified point: apps may keep the Mac awake, but it locks anyway. Plain, memorable, consumer-friendly. | Slightly phrase-like rather than a traditional app name. | Best overall. |
| **LockGrace** | WebGPT's strongest detailed-research pick. Captures the grace period before locking. | Over-weights the countdown UX and misses the rogue-process problem. | Good candidate, wrong emphasis. |
| **LockCue** | Short, distinctive, directly tied to the warning/countdown cue. | Needs a tagline the first time users see it. | Best runner-up. |
| **Idle Lock** | Very clear and already matches the current app. Good for SEO/search. | "Idle" is slightly technical and generic; harder to brand. | Best if you want zero rename risk. |
| **IdleBell** | Friendly warning-signal metaphor from WebGPT. | Softer; does not say "Mac will lock" as strongly. | Good friendly alternate. |
| **LastInput** | Technically accurate and specific to HID idle behavior. | Too technical for average users. | Better for a diagnostic/tooling audience. |
| **LockLater** | Captures the add-time/snooze behavior. Friendly. | Could sound like it weakens security or avoids locking. | Good alternate, not first choice. |
| **LockNotice** | Very clear about the warning. | Bland, less brandable. | Useful fallback. |
| **LockTimer** | Searchable and obvious. | Generic; may be confused with simple countdown/sleep timers. | Acceptable but not distinctive. |
| **Screen Sentry** | Security/privacy feel. | Sounds heavier and more enterprise than the app. | Not ideal for average users. |
| **LockNudge** | Communicates the warning before lock. | "Nudge" is already associated with Mac admin OS-update tooling and reminder apps. | Avoid unless you like the word strongly. |
| **AwayLock** | Very clear. | Already used by a proximity auto-lock app. | Avoid. |

## Final Naming Direction

Use:

# Lock Anyway

Subtitle:

> Apps can keep your Mac awake. Not unlocked.

Short description:

> Lock Anyway locks your Mac after real keyboard and mouse inactivity, even when media, remote desktop, or a single misbehaving process keeps the display awake. Before it locks, it shows a visible countdown with quick add-time buttons.

Installer/DMG name:

> `LockAnyway.dmg`

App bundle display name:

> `Lock Anyway.app`

Menu bar tooltip examples:

- `Lock Anyway: locks after 5 min idle`
- `Lock Anyway: countdown`
- `Lock Anyway: paused`
- `Lock Anyway: permission needed`

## Installability Notes For Average Mac Users

The naming and install flow should reinforce trust:

- Use a single canonical app location: `/Applications/Lock Anyway.app`.
- Avoid having both a build-folder app and an Applications-folder app running.
- Sign and notarize releases.
- Use a drag-to-Applications DMG for normal users, or a signed PKG if the app must install a LaunchAgent automatically.
- First-run screen should say exactly why Accessibility is needed: "Lock Anyway needs Accessibility permission only to send the macOS Lock Screen shortcut if the legacy lock command is unavailable."
- The warning panel should include the actual add-time choices, not hide them behind a menu.
- Do not ask for an administrator password during normal app updates unless the user explicitly chose an installer that needs it.

## Source Links

- [Apple Support - Change Lock Screen settings on Mac](https://support.apple.com/en-mide/guide/mac-help/-mh11784/mac)
- [Amphetamine on the Mac App Store](https://apps.apple.com/us/app/amphetamine/id937984704?mt=12)
- [KeepingYouAwake](https://keepingyouawake.app/)
- [KeepingYouAwake GitHub](https://github.com/newmarcel/KeepingYouAwake)
- [Lungo on the Mac App Store](https://apps.apple.com/us/app/lungo/id1263070803?mt=12)
- [Caffeine](https://www.caffeine-app.net/)
- [Jolt of Caffeine on the Mac App Store](https://apps.apple.com/us/app/jolt-of-caffeine/id1437130425)
- [Tostato](https://tostato.app/)
- [RunningCat](https://runningcat.app/)
- [Time Out on the Mac App Store](https://apps.apple.com/us/app/time-out-break-reminders/id402592703)
- [Standup](https://getstandup.io/)
- [iRetina](https://iretina.app/)
- [Workrave break reminders](https://workrave.org/docs/breaks/reminder/)
- [Workrave break windows](https://workrave.org/docs/breaks/breaks/)
- [BreakOverlay on the Mac App Store](https://apps.apple.com/us/app/breakoverlay-eye-break-timer/id6757116138?mt=12)
- [LookAway on the Mac App Store](https://apps.apple.com/us/app/lookaway-break-reminder/id6747192301?mt=12)
- [Take a break on the Mac App Store](https://apps.apple.com/ca/app/take-a-break-timer-reminder/id1457158844?mt=12)
- [AwayLock on the Mac App Store](https://apps.apple.com/us/app/awaylock-proximity-auto-lock/id6742342445)
- [Near Lock](https://www.nearlock.me/)
- [GateKeeper Walk Away Lock](https://gatekeeperhelp.zendesk.com/hc/en-us/articles/360058188493-What-is-Walk-Away-Lock)
- [ProximityLock](https://proximitylock.app/)
- [Avalw Shield](https://shield.avalw.ai/)
- [Automox macOS inactivity lock Worklet](https://www.automox.com/worklets/enforce-lock-screen-inactivity-mac)

## Method Note

The initial ChatGPT Web/WebGPT wrapper calls timed out while waiting for a completion signal, but the conversations did complete in the browser. I exported both completed conversations and reconciled them with direct web/source checks. The most important correction was rejecting WebGPT's shorter **AwayLock** recommendation because an App Store app with that name already exists.
