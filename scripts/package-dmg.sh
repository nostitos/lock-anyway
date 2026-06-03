#!/bin/zsh
set -euo pipefail
setopt NULL_GLOB

repo_dir="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_dir"
export COPYFILE_DISABLE=1

if ! command -v create-dmg >/dev/null 2>&1; then
  echo "create-dmg is required. Install it with: npm install --global create-dmg" >&2
  exit 1
fi

version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' Resources/Info.plist)"
app_src="$("$repo_dir/scripts/build-app.sh")"
dist_dir="$repo_dir/dist"
marker="$repo_dir/.build/dmg-start-marker"
final_dmg="$dist_dir/LockAnyway-$version.dmg"

mkdir -p "$dist_dir" "$repo_dir/.build"
rm -f "$final_dmg" "$dist_dir"/Idle\ Lock*.dmg "$dist_dir"/Lock\ Anyway*.dmg
: > "$marker"

create-dmg \
  --overwrite \
  --dmg-title "Lock Anyway" \
  "$app_src" \
  "$dist_dir" >&2

created_dmg="$(
  find "$dist_dir" -maxdepth 1 -type f -name '*.dmg' -newer "$marker" -print | head -n 1
)"

if [[ -z "$created_dmg" || ! -f "$created_dmg" ]]; then
  echo "create-dmg finished, but no DMG was found in $dist_dir" >&2
  exit 1
fi

mv "$created_dmg" "$final_dmg"

if command -v hdiutil >/dev/null 2>&1; then
  hdiutil verify "$final_dmg" >/dev/null
fi

echo "$final_dmg"
