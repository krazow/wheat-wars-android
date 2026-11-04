# Wheat Wars for Android (v2.2.0)

A native Android app wrapping the same game file as the PC and web versions. Everything is bundled in the
APK (game, intro video, previous version 2.1.0), so it plays fully offline and asks for no permissions.

Android touches: Back works like ESC (closes menus and help; on the market it asks before quitting; on the
title screen it exits); the game saves the moment you switch apps; the screen stays awake while playing;
full-screen with the system bars hidden (swipe from an edge to show them); rotates freely; Android 7.0+.

## Build the APK (no tools needed on your PC)
1. Create a new GitHub repository and upload the contents of this folder (keep the `.github` folder).
2. Open the repository's **Actions** tab, choose **Build Android APK**, then **Run workflow**.
3. When the run finishes (about 5 minutes), download **WheatWars-apk** from the run page and unzip it.

## Build with Android Studio
Open this folder in Android Studio and choose Build > Build APK(s). Output:
`app/build/outputs/apk/debug/app-debug.apk`.

## Install on a phone
Copy the APK to the phone and open it. Android will ask you to allow installs from that app (Files,
Chrome, etc.) the first time. The APK is debug-signed, which is fine for sideloading; publishing on
Google Play would need a release signing key.

## Updating the game inside the app
Replace `app/src/main/assets/index.html` with the new game file, raise `versionCode`/`versionName` in
`app/build.gradle`, and rebuild. Saved games are kept across app updates (same app id
`com.fictionalsoftworks.wheatwars`), but are removed if the app is uninstalled.
