# welcome

The Hermit welcome app: a standalone Quickshell instance, separate from the main shell, so it
stays open when the user switches between Quickshell and AGS.

Run it with `quickshell -c welcome` (config name `welcome`). Normally the launcher does that:

    ~/.config/hypr/scripts/hermit-welcome.sh           # only if not completed yet (use in autostart)
    ~/.config/hypr/scripts/hermit-welcome.sh --force   # open it again

## Files

- `shell.qml` — entry point.
- `WelcomeApp.qml` — the window, its five steps and its small components.
- `WelcomeStore.qml` — "seen" flag (`state/welcome.json`), active shell (`~/.config/hypr/.active-shell`),
  shell switching, and requests to the main shell.
- `WelcomeTheme.qml` — Hermit default dark palette and sizes.

## Rules

- Do not import the main shell's `Colors`, `ShellState` or any service here: this is a second process,
  and those singletons start services (notifications, Hyprland animation sync, ...).
- Settings buttons never touch settings directly. They write `state/welcome-request.json`, and
  `features/welcome/WelcomeBridge.qml` in the main shell acts on it.
- `switch-shell.sh` ignores quickshell processes whose command line contains "welcome".
- The shortcut list on the Shortcuts step is static and mirrors `common.lua`.