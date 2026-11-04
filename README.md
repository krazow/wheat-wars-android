# Wheat Wars 2.2.0 — mobile builds

A 1990s-shareware-style trading game of the Touchet Valley and the Tri-Cities. Same game file on every platform; fully offline.

| Platform | How to install |
|---|---|
| **Android** | [WheatWars-2.2.0.apk](https://github.com/krazow/wheat-wars-android/releases/download/v2.2.0/WheatWars-2.2.0.apk) — open on the phone, allow installs from that source. |
| **iPhone / iPad (no Apple account)** | Open https://krazow.github.io/wheat-wars-android/ in **Safari** → Share → **Add to Home Screen**. Plays offline, full-screen. |
| **iPhone / iPad (native app)** | [WheatWars-2.2.0-unsigned.ipa](https://github.com/krazow/wheat-wars-android/releases/download/v2.2.0/WheatWars-2.2.0-unsigned.ipa) — sign & install with [AltStore](https://altstore.io) or [Sideloadly](https://sideloadly.io) using your Apple ID (free IDs: re-sign every 7 days; paid developer account: 1 year). |

Folders: `app/` Android project · `ios/` iOS project (XcodeGen) · `web/` offline web version.
Every push to `main` rebuilds the APK, the iOS app and the web version (see the Actions tab).

Saved games: Android and iOS apps keep saves across app updates (lost on uninstall). The web version keeps them in Safari/Chrome storage for that site.
