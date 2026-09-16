# Releasing Livemate to Google Play

Package name: **`com.livematex.app`** — this is permanent once the first
bundle is uploaded. It cannot be changed for that listing afterwards.

## One-time setup

### 1. Create the upload keystore

```bash
bash tool/release/create_upload_keystore.sh
```

It runs `keytool`, prompts for the passwords on your terminal, and writes
`android/key.properties` pointing at the new keystore. Both are gitignored.

Doing it by hand instead is fine — see `android/key.properties.example` for
the exact `keytool` invocation and the fields to fill in.

**Back the keystore up somewhere off this machine.** Losing it means you
cannot publish an update to this listing again unless Google can reset the
upload key for you.

### 2. Enrol in Play App Signing

Play re-signs your app with a key Google holds; the keystore above is only the
*upload* key. Enrolment happens on the first upload and is the default for new
apps, which is what makes a lost upload key recoverable rather than fatal.

## Every release

1. **Bump the version** in `pubspec.yaml`:

   ```yaml
   version: 1.0.0+1     # versionName+versionCode
   ```

   The build number after `+` becomes Android's `versionCode`. Play rejects a
   `versionCode` it has already accepted, so it must increase every upload.

2. **Build the bundle:**

   ```bash
   flutter build appbundle --release
   ```

   Output: `build/app/outputs/bundle/release/app-release.aab`

   If `android/key.properties` is missing, the build still succeeds but signs
   with the **debug** key and prints a warning. Play will reject that file.

3. **Smoke-test the release build on a real device** before uploading:

   ```bash
   flutter install --release
   ```

   The release build runs through R8 (`isMinifyEnabled` and
   `isShrinkResources` are on) while the debug build does not, so this is the
   only build that exercises `android/app/proguard-rules.pro`. Check the
   photo picker, the dial/email actions on an accepted enquiry, and sign-in.

4. **Upload** the `.aab` in the Play Console.

## What is already configured

| Piece | Where |
|---|---|
| Application ID `com.livematex.app` | `android/app/build.gradle.kts` |
| Kotlin package + `MainActivity` | `android/app/src/main/kotlin/com/livematex/app/` |
| Release signing from `key.properties` | `android/app/build.gradle.kts` |
| R8 / resource shrinking + keep rules | `android/app/proguard-rules.pro` |
| Debug builds installable alongside release | `applicationIdSuffix = ".debug"` |
| Launcher + adaptive + themed icons | `pubspec.yaml` → `flutter_launcher_icons` |
| App label "Livemate" | `android/app/src/main/AndroidManifest.xml` |
| Language splits disabled | `bundle { language { enableSplit = false } }` |

## Store listing notes

- **App name:** Livemate
- **Tagline:** Find your place. Find your people.
- **Icon source:** `assets/brand/icon.png` (1024×1024, no alpha) — regenerate
  with `python tool/brand/generate_brand_assets.py`, then
  `dart run flutter_launcher_icons`.
- **API:** HTTPS at `https://www.zygonich.com/livemate`. Neither platform
  carries a cleartext exception.
- **Privacy policy URL:** `https://www.zygonich.com/livemate/privacy-policy`
- **Account deletion URL:** `https://www.zygonich.com/livemate/delete-account`

## Data safety declaration

The Play Console will ask what the app collects. Currently: email and name
(account), phone number (profile, revealed only on an accepted enquiry),
photos (listing images), and city. Contact details are shared with another
user only after that user's enquiry is accepted — worth stating explicitly in
the form. The app takes no payments, so declare no purchase or financial
information, and remove it if an earlier submission declared it.

---

# Releasing Livemate to the App Store (iOS)

iOS builds need a Mac. Everything inside `ios/` is already configured; the Mac
needs the toolchain, a signing team, and the steps below.

| Piece | Value / where |
|---|---|
| Bundle identifier | `com.livematex.app` — `ios/Runner.xcodeproj/project.pbxproj` |
| Display name | Livemate — `ios/Runner/Info.plist` |
| Minimum iOS | 15.0 — `ios/Podfile`, `project.pbxproj` and `ios/Flutter/AppFrameworkInfo.plist` |
| Devices | iPhone and iPad |
| CocoaPods | `ios/Podfile`, included from `ios/Flutter/Debug.xcconfig` and `Release.xcconfig` |
| Camera and photo library prompts | `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription` |
| Dial / email a revealed contact | `LSApplicationQueriesSchemes` → `tel`, `mailto` |
| Networking | HTTPS only — no App Transport Security exceptions |
| Export compliance | `ITSAppUsesNonExemptEncryption` = `false` (standard HTTPS only) |
| App icon | `flutter_launcher_icons`, alpha channel removed |
| Privacy policy and in-app account deletion | Profile screen (guideline 5.1.1) |

## One-time setup on the Mac

1. Install **Xcode** from the App Store, open it once and accept the licence,
   then:

   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -runFirstLaunch
   ```

2. Install **CocoaPods**: `brew install cocoapods`
3. Install **Flutter** 3.32 or newer and run `flutter doctor` until the Xcode
   and CocoaPods lines are green.
4. Copy the project over **including `.env`** — it is declared as an asset, so
   the build fails without it. Then, from the project root:

   ```bash
   flutter clean        # drops build output generated on Windows
   flutter pub get      # regenerates ios/Flutter/Generated.xcconfig for this Mac
   cd ios && pod install --repo-update && cd ..
   ```

5. Open **`ios/Runner.xcworkspace`** (the workspace, not the `.xcodeproj`) →
   *Runner* target → *Signing & Capabilities* → choose your **Team**. Automatic
   signing is already on, so Xcode creates the certificates and profiles.
6. In **App Store Connect**, create the app with bundle ID `com.livematex.app`.

## Every iOS release

1. **Bump the version** in `pubspec.yaml`. The number after `+` is also the iOS
   build number, and App Store Connect rejects one it has already accepted.
2. **Smoke-test a release build on a real iPhone:**

   ```bash
   flutter run --release
   ```

   Check sign-in, adding listing photos from the camera and the library,
   dialling or emailing an accepted enquiry, and opening the privacy policy.
3. **Build the archive:**

   ```bash
   flutter build ipa --release
   ```

   Output: the `.ipa` in `build/ios/ipa/` and the archive at
   `build/ios/archive/Runner.xcarchive`.
4. **Upload** by dragging the `.ipa` into Apple's **Transporter** app, or open
   the `.xcarchive` in Xcode → *Distribute App* → *App Store Connect*.

## App Store Connect notes

- **Privacy policy URL:** `https://www.zygonich.com/livemate/privacy-policy`
- **App Privacy:** name, email, phone number and photos, all used for app
  functionality. No tracking, no purchases.
- **Sign-in required:** every screen is behind an account, so give App Review a
  working demo email and password under *App Review Information*.
- **Account deletion:** Profile → *Delete account* calls `DELETE /users/me`
  from inside the app.
