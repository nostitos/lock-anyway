# Lock Anyway

Lock Anyway is a native macOS menu bar utility that locks the local Mac after real keyboard and mouse inactivity, even when media playback, remote desktop, or a single misbehaving process keeps the display awake.

The app is currently implemented under the bundle name **Idle Lock** (`com.user.IdleLock`) to keep Accessibility permission stable across development builds.

## Screenshots

![Countdown overlay](docs/screenshots/countdown.png)

| Preferences | DMG installer |
| --- | --- |
| ![Preferences window](docs/screenshots/preferences.png) | ![DMG drag-to-Applications window](docs/screenshots/dmg.png) |

## What It Does

- Reads real HID idle time from `IOHIDSystem`.
- Shows a visible countdown before locking.
- Lets the user add time from the countdown panel: 15 minutes, 30 minutes, 1 hour, or 2 hours.
- Lets the user disable locking entirely from the countdown panel until manually resumed.
- Cancels the countdown immediately on keyboard or mouse activity.
- Locks with `CGSession -suspend` when available, otherwise uses the native `Control-Command-Q` shortcut with Accessibility permission.
- Starts at login through a user LaunchAgent with crash restart behavior.

## Recommended Name

Product name: **Lock Anyway**

Tagline: **Apps can keep your Mac awake. Not unlocked.**

The important product promise is not the grace period itself; it is that one app should not leave the Mac unlocked all day.

## Typical User Story

You set macOS to lock after a few minutes, then leave the desk expecting the Mac to protect itself. Later you find it still unlocked because one browser tab, meeting app, remote access session, or helper process kept the display awake.

Lock Anyway treats that as the normal case. It does not ask whether the display is asleep, whether Chrome is playing media, or whether a remote session is active. It only asks one question: has anyone touched the local keyboard or mouse recently? If not, it shows a countdown and locks the Mac anyway.

Chrome and Chromium-based apps can interfere with normal display-sleep or screen-lock flows in several common ways:

- video or audio playback, including YouTube, streaming sites, playlists, and muted tabs that are still considered active media
- WebRTC sessions, including Meet, Zoom in the browser, Discord, Slack huddles, camera, microphone, and screen sharing
- remote desktop or remote support sessions running in a tab or Chromium shell
- web apps that request a screen wake lock, presentation mode, kiosk behavior, or fullscreen playback
- active downloads, uploads, sync, backups, or long-running web jobs that keep the browser process busy
- Chrome extensions, PWAs, native messaging helpers, or background service workers that keep Chrome alive after the visible tab is closed
- Electron apps built on Chromium that make the same power-management requests as Chrome tabs

Those behaviors can be useful. A movie should not stop halfway through, a meeting should not blank the screen, and a remote desktop session should stay connected. The problem is when “keep the display awake” accidentally becomes “leave the Mac unlocked all day.” Lock Anyway separates those two things.

## Install

For a normal user, build the DMG:

```sh
scripts/package-dmg.sh
```

Then open:

```text
dist/LockAnyway-1.0.dmg
```

Drag `Idle Lock.app` to Applications, then open it from `/Applications`. The app intentionally refuses to run from the mounted disk image so Start at Login and Accessibility permission stay attached to the installed copy.

For managed installs, build the signed package:

```sh
scripts/package-app.sh
```

Then open the package in Finder:

```text
dist/IdleLock-1.0.pkg
```

The current package installs:

- App: `/Applications/Idle Lock.app`
- LaunchAgent: `~/Library/LaunchAgents/com.user.idle-lock.plist`
- Log: `~/Library/Logs/IdleLock.log`

On first launch, grant Accessibility permission when prompted. Modern macOS needs that permission so the app can send the native lock shortcut when `CGSession` is unavailable.

See [docs/INSTALL.md](docs/INSTALL.md) for the full install and permission flow.

## Development

Build only:

```sh
scripts/build-app.sh
```

Test:

```sh
swift run IdleLockSelfTest
```

Reload after app changes:

```sh
scripts/reload-app.sh
```

The canonical development install location is `/Applications/Idle Lock.app`. Do not run a second copy from `.build` or `~/Applications`; duplicate app paths can confuse macOS Accessibility permission.

See [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md) for build, test, package, and reload details.

## Manual Verification

1. Run `scripts/reload-app.sh`.
2. Confirm the running app path is `/Applications/Idle Lock.app/Contents/MacOS/IdleLock`.
3. Set a short custom delay such as `30s` and countdown warning `10 sec`.
4. Confirm the overlay appears over fullscreen content, mouse/key activity or a click on the dimmed background cancels it, add-time buttons work, Disable Locking pauses until resumed, and the countdown reaches lock.
5. Confirm RustDesk or other remote access stays connected while the local Mac locks.

## Documentation

- [Product and naming](docs/PRODUCT.md)
- [Install guide](docs/INSTALL.md)
- [Development guide](docs/DEVELOPMENT.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)

## Old Watchdog Migration

Keep `com.user.idle-lock-watchdog` enabled until the native app is verified. After verification:

```sh
scripts/disable-old-watchdog.sh
```

The old script at `/Users/t/.local/bin/idle-lock-watchdog` is left on disk for rollback.

## Distribution Note

When Developer ID certificates are available in the keychain, `scripts/build-app.sh` signs the app with `Developer ID Application` and `scripts/package-app.sh` signs the package with `Developer ID Installer`. Notarization is still required for broad distribution outside this machine.
