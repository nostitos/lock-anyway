#!/bin/zsh
set -euo pipefail

repo_dir="$(cd "$(dirname "$0")/.." && pwd)"
app_src="$("$repo_dir/scripts/build-app.sh")"
app_dst="/Applications/Idle Lock.app"
plist="$HOME/Library/LaunchAgents/com.user.idle-lock.plist"
uid="$(id -u)"

if [[ ! -w /Applications ]]; then
  echo "Cannot write to /Applications without administrator authorization." >&2
  echo "Run scripts/package-app.sh and open dist/IdleLock-1.0.pkg to install manually." >&2
  exit 1
fi

mkdir -p "$HOME/Library/LaunchAgents" "$HOME/Library/Logs"

if launchctl print "gui/$uid/com.user.idle-lock" >/dev/null 2>&1; then
  launchctl bootout "gui/$uid" "$plist" >/dev/null 2>&1 || true
fi
pkill -x IdleLock >/dev/null 2>&1 || true

rm -rf "$app_dst"
ditto --norsrc --noextattr "$app_src" "$app_dst"

cat > "$plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.idle-lock</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Applications/Idle Lock.app/Contents/MacOS/IdleLock</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <dict>
        <key>SuccessfulExit</key>
        <false/>
    </dict>
    <key>StandardOutPath</key>
    <string>$HOME/Library/Logs/IdleLock.out.log</string>
    <key>StandardErrorPath</key>
    <string>$HOME/Library/Logs/IdleLock.err.log</string>
</dict>
</plist>
PLIST

plutil -lint "$plist" >/dev/null

launchctl bootstrap "gui/$uid" "$plist"
launchctl enable "gui/$uid/com.user.idle-lock"

echo "Installed $app_dst"
echo "Loaded $plist"
