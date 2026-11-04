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

---

# Electrical Weeding 1.0.0

A spin-off of Wheat Wars: you're a field tech for an electric-weeder company. Trade weeder parts between the same nine towns and answer customer support calls (pick the right fix from your van, keep your reputation up). Source and app projects live in `electrical-weeding/`.

| Platform | How to install |
|---|---|
| **Any phone / browser** | https://krazow.github.io/wheat-wars-android/electrical-weeding/ — Safari: Share → Add to Home Screen; Chrome: Install app. Plays offline. |
| **Android** | [ElectricalWeeding-1.0.0.apk](https://github.com/krazow/wheat-wars-android/releases/download/ew-v1.0.0/ElectricalWeeding-1.0.0.apk) |
| **iPhone / iPad (native)** | [ElectricalWeeding-1.0.0-unsigned.ipa](https://github.com/krazow/wheat-wars-android/releases/download/ew-v1.0.0/ElectricalWeeding-1.0.0-unsigned.ipa) via AltStore / Sideloadly |
| **Windows 10/11** | ElectricalWeeding-Setup-1.0.0.exe (release ew-v1.0.0) |

Both games can share a phone or website: separate saves (`ww.*` / `ew.*`), separate offline caches, separate apps.
