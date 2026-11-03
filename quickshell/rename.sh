#!/usr/bin/env bash
# V3 naming: a settings page is <Title>Settings.qml, saved state is <Name>State.qml.
# Dry run by default. Run with APPLY=1 to change files. Refuses to run twice.
set -u
cd ~/.config/quickshell || exit 1
APPLY="${APPLY:-0}"
MARK=".hermit-rename-v3-done"
[ -e "$MARK" ] && { echo "Already applied ($MARK exists). Stopping."; exit 1; }
[ "$APPLY" = "1" ] && [ -n "$(git status --porcelain 2>/dev/null)" ] \
  && echo "WARNING: you have uncommitted changes. Commit them first so the diff stays readable."

files() { find . -path ./.git -prune -o -type f \( -name '*.qml' -o -name qmldir -o -name '*.md' \) -print; }
declare -A VACATED

# rename_one <old path> <new base name>   returns 1 when skipped
rename_one() {
  local old="$1" new="$2" dir old_name hits
  dir="$(dirname "$old")"; old_name="$(basename "$old" .qml)"
  if [ ! -e "$old" ]; then echo "SKIP   $old (not found)"; return 1; fi
  if [ -e "$dir/$new.qml" ] && [ -z "${VACATED[$dir/$new.qml]:-}" ]; then
    echo "SKIP   $dir/$new.qml already exists"; return 1
  fi
  hits=$(files | xargs grep -lw "$old_name" 2>/dev/null | wc -l)
  echo "RENAME $old -> $dir/$new.qml   ($hits file(s) mention $old_name)"
  if [ "$APPLY" = "1" ]; then
    git mv "$old" "$dir/$new.qml" 2>/dev/null || mv "$old" "$dir/$new.qml"
    files | xargs sed -i "s/\b$old_name\b/$new/g"
  fi
  return 0
}

echo "== Step 1: saved state (singletons named ...Settings) -> ...State =="
while IFS= read -r f; do
  f="${f#./}"
  base="$(basename "$f" .qml)"
  rename_one "$f" "${base%Settings}State" && VACATED["$f"]=1
done < <(grep -rl --include='*Settings.qml' '^pragma Singleton' . | grep -v '^./.git')

echo; echo "== Step 2: settings pages -> ...Settings =="
PAGES=(
  "features/launcher/LauncherPage.qml LauncherSettings"
  "features/launcher/SearchToolsPage.qml SearchToolsSettings"
  "features/launcher/NotesSnippetsPage.qml NotesSnippetsSettings"
  "features/clipboard/ClipboardPage.qml ClipboardSettings"
  "features/lockscreen/LockScreenPage.qml LockScreenSettings"
  "features/lockscreen/KnowledgePage.qml KnowledgeSettings"
  "features/network/WifiPage.qml WifiSettings"
  "features/network/BluetoothPage.qml BluetoothSettings"
  "features/hyprland/KeybindsPage.qml KeybindsSettings"
  "features/hyprland/KeybindListPage.qml KeybindListSettings"
  "features/settings/pages/home/HomePage.qml HomeSettings"
  "features/dashboard/DashboardQuickNoteSettings.qml QuickNoteSettings"
  "features/dashboard/DashboardMediaSettings.qml MediaSettings"
  "features/dashboard/DashboardStatsSettings.qml SystemStatsSettings"
  "features/dashboard/DashboardCalendarSettings.qml CalendarSettings"
  "features/theme/ThemeSettings.qml ColorsSettings"
  "features/theme/OpacitySettings.qml SurfacesSettings"
  "features/account/AccountSettings.qml AccountsSettings"
  "features/settings/pages/language/LanguageSettings.qml LanguageRegionSettings"
)
for entry in "${PAGES[@]}"; do rename_one "${entry%% *}" "${entry##* }"; done

# About.qml: the word "About" is too common to replace everywhere, so only the file name changes.
about_dir="features/settings/pages/about"
if [ -e "$about_dir/About.qml" ] && [ ! -e "$about_dir/AboutSettings.qml" ]; then
  echo "RENAME $about_dir/About.qml -> $about_dir/AboutSettings.qml"
  if [ "$APPLY" = "1" ]; then
    git mv "$about_dir/About.qml" "$about_dir/AboutSettings.qml" 2>/dev/null \
      || mv "$about_dir/About.qml" "$about_dir/AboutSettings.qml"
    files | xargs sed -i 's/\bAbout\.qml\b/AboutSettings.qml/g'
    [ -f "$about_dir/qmldir" ] && sed -i 's/^About /AboutSettings /' "$about_dir/qmldir"
  fi
fi

REG="features/settings/core/SettingsRegistry.qml"
echo; echo "== Step 3: titles in $REG =="
echo "Bar & Island -> Bar, Displays -> Display, Music visualizer -> Visualizer"
if [ "$APPLY" = "1" ]; then
  sed -i -e 's/title: "Bar & Island"/title: "Bar"/' \
         -e 's/title: "Displays"/title: "Display"/' \
         -e 's/title: "Music visualizer"/title: "Visualizer"/' "$REG"
  touch "$MARK"
  echo; echo "== Check: registry sources that do not exist =="
  grep -o 'source: "[^"]*"' "$REG" | sed 's/source: "//; s/"$//' | while read -r p; do
    [ -e "features/settings/$p" ] || echo "  MISSING $p"
  done
  echo "(nothing listed above means every page path resolves)"
  echo "Done. Restart Quickshell fully."
else
  echo; echo "Dry run only. Run again with APPLY=1 to apply."
fi