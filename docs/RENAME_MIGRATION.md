# Rename Migration Plan

The recommended public name is **Lock Anyway**, but the current app still ships as `Idle Lock.app` with bundle id `com.user.IdleLock`.

Do not rename the app casually during active testing. macOS Accessibility permission is sensitive to the signed app identity and path. A rename should be a deliberate release step.

## Target Public Identity

- App display name: `Lock Anyway`
- App bundle: `/Applications/Lock Anyway.app`
- Bundle id: `com.user.LockAnyway` or a future production identifier
- Executable: `LockAnyway`
- LaunchAgent: keep `com.user.idle-lock` for continuity, or migrate deliberately to `com.user.lock-anyway`
- Log file: keep `~/Library/Logs/IdleLock.log` for continuity, or migrate deliberately to `~/Library/Logs/LockAnyway.log`

## Migration Steps

1. Decide whether to keep the old bundle id for Accessibility continuity or move to a new production bundle id.
2. Update `Package.swift` product names only if the executable should be renamed.
3. Update `Resources/Info.plist`.
4. Update app-facing strings in `Sources/IdleLockCore`.
5. Update `scripts/build-app.sh`, `scripts/package-app.sh`, `scripts/reload-app.sh`, and `scripts/install-app.sh`.
6. Update `Packaging/scripts/postinstall`.
7. Update docs and package names.
8. Build, sign, and verify the new app path.
9. Install the new app to `/Applications/Lock Anyway.app`.
10. Boot out the old LaunchAgent and write the new one.
11. Remove or archive `/Applications/Idle Lock.app`.
12. Ask the user to grant Accessibility permission to the new app if macOS does not preserve trust.

## Recommended Timing

Do the rename just before a clean release package, not during active UI/lock behavior debugging.

Until then:

- Product/docs name: **Lock Anyway**
- Development app identity: **Idle Lock**
