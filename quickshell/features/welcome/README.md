# features/welcome

Main-shell side of the Hermit welcome app. The welcome window itself is a separate Quickshell
instance in `welcome/` (run with `quickshell -c welcome`), so switching to AGS does not close it.

- `WelcomeBridge.qml` — watches `state/welcome-request.json` and opens Settings, the theme
  switcher or the wallpaper picker when the welcome app asks.

Request format: `{ "id": <number>, "action": "settings" | "page" | "wallpaper", "arg": "<name>" }`.
A new `id` is a new request; the file left over from a previous session is ignored.