# Speedrr

Speed reading trainer. The whole app is one file: `web/index.html` (HTML, CSS and JS, no build step).
The iOS app in `ios/` is a thin shell: a WKWebView that serves `web/index.html` and, every time the app
opens, downloads the newest copy from `main` on GitHub and reloads it.

## How to change the app
1. Edit `web/index.html` only. Do not edit the Swift code for feature changes.
2. Bump `<meta name="build" content="YYYY-MM-DD.N">` in the head.
3. Check the script: extract the last `<script>` block and run `node --check` on it.
4. Commit and push to `main`. Open the app on the phone to get the update (GitHub's raw files can take a few minutes to refresh).

The Xcode project bundles `web/index.html` as the offline fallback, so a rebuild in Xcode is only needed when the Swift code changes.

## Facts to keep in mind
- Progress (plan, scores, streak, settings) is saved in localStorage under the fixed address `speedrr://app/`. Do not rename the keys without a migration.
- English and Spanish content live in the `C` object and the `W`, `PL`, `PT` text tables inside the script.
- Test drills at phone size (393 x 852) in Chrome before pushing.
