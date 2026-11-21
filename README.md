# Speedrr

A speed reading trainer for iPhone: a 30-day plan, a Duolingo-style path, timed drills (eye training, reading range, scanning, comprehension, vocabulary) in English and Spanish, and an EPUB/text reader with guided pacing.

## Run it on your iPhone
1. Open `ios/Speedrr.xcodeproj` in Xcode 15 or newer.
2. Select the Speedrr target, open Signing & Capabilities, choose your Team (a free Apple ID works) and change the bundle identifier if Xcode asks.
3. Plug in your iPhone (or pick a simulator), press Run.

Apps installed with a free Apple ID expire after 7 days and need to be run again from Xcode. A paid developer account avoids that.

## Updates
The app downloads the latest `web/index.html` from this repo each time you open it and shows "Updated to the latest version". You can also tap **Check for updates** at the bottom of the Drills tab. Updates need an internet connection; offline, it uses the last saved copy. GitHub can take a few minutes to serve a new push.

Your progress stays on the phone and survives updates.

## Layout
- `web/index.html`: the whole app.
- `ios/`: the Xcode project (SwiftUI + WKWebView). The app icon and bundled offline copy are included.
