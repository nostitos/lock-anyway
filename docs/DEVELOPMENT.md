# Development Guide

## Requirements

- macOS
- Swift 6.2.3 or newer
- Developer ID Application certificate for stable Accessibility trust across rebuilds
- Developer ID Installer certificate for signed packages

The project is a Swift Package and does not require `xcodebuild`.

## Build

```sh
scripts/build-app.sh
```

Output:

```text
.build/release/Idle Lock.app
```

The script signs with `Developer ID Application` when available. Without a Developer ID identity, it falls back to ad-hoc signing.

## Test

```sh
swift run IdleLockSelfTest
```

This project uses the included `IdleLockSelfTest` executable instead of `swift test`.

## Reload After App Changes

```sh
scripts/reload-app.sh
```

The reload script:

- Builds the release app.
- Stops the running LaunchAgent/app.
- Installs to `/Applications/Idle Lock.app`.
- Rewrites `~/Library/LaunchAgents/com.user.idle-lock.plist`.
- Starts the LaunchAgent again.

Verify the active path:

```sh
for pid in $(pgrep -x IdleLock); do ps -p "$pid" -o pid=,command=; done
```

Expected path:

```text
/Applications/Idle Lock.app/Contents/MacOS/IdleLock
```

## Package

```sh
scripts/package-app.sh
```

Output:

```text
dist/IdleLock-1.0.pkg
```

Check package signing:

```sh
pkgutil --check-signature dist/IdleLock-1.0.pkg
```

## DMG

```sh
scripts/package-dmg.sh
```

Output:

```text
dist/LockAnyway-1.0.dmg
```

The DMG flow is drag-to-Applications. The app refuses to run from `/Volumes/...` so users do not accidentally bind Accessibility permission or Start at Login to the mounted image.

## Manual Verification

1. Run `swift run IdleLockSelfTest`.
2. Run `scripts/reload-app.sh`.
3. Set custom delay `30s` and countdown warning `10 sec`.
4. Verify overlay visibility over fullscreen video and all Spaces.
5. Verify mouse/key activity cancels the countdown.
6. Verify buttons and number keys add time:
   - `1`: 15 minutes
   - `2`: 30 minutes
   - `3`: 1 hour
   - `4`: 2 hours
7. Verify countdown reaches lock.
8. Verify RustDesk remains connected while the local Mac locks.

## Do Not Create Duplicate App Copies

Use one canonical installed app:

```text
/Applications/Idle Lock.app
```

Do not run a second copy from:

- `.build/release/Idle Lock.app`
- `~/Applications/Idle Lock.app`
- another downloaded copy

Duplicate app paths can make macOS Accessibility permission appear broken because permission may have been granted to a different signed app instance.
