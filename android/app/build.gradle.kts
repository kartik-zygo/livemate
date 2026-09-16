import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Upload-key credentials live in android/key.properties, which is gitignored —
// see android/key.properties.example for how to create it and the keystore.
// When it is absent the release build falls back to the debug key so that
// `flutter run --release` still works locally; that build is NOT uploadable.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasUploadKey = keystorePropertiesFile.exists()
if (hasUploadKey) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}

android {
    namespace = "com.livematex.app"
    // Pinned rather than taken from flutter.compileSdkVersion: this Flutter
    // (3.32) still defaults to 35, and Play has required API 36 since
    // 31 Aug 2026. Compiling against 36 is also what makes the new APIs and
    // lint checks visible. Revisit when the Flutter SDK's own default catches
    // up — the pin is then redundant, not wrong.
    compileSdk = 36
    // Every bundled plugin asks for 27.0.12077973 and the NDK is backward
    // compatible, so pin the highest rather than letting Flutter pick 26 and
    // warn on every build.
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.livematex.app"
        minSdk = flutter.minSdkVersion
        // Google Play, from 31 Aug 2026: new apps and updates must target
        // API 36 (Android 16). Pinned for the same reason as compileSdk above.
        // Behaviour this opts the app into on Android 16 devices is listed in
        // RELEASING.md under "Targeting API 36".
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasUploadKey) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = keystoreProperties["storeFile"]?.let { file(it) }
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasUploadKey) {
                signingConfigs.getByName("release")
            } else {
                logger.warn(
                    "\n  WARNING: android/key.properties not found — signing the " +
                        "release build with the DEBUG key.\n" +
                        "  This artifact cannot be uploaded to Play. See " +
                        "android/key.properties.example.\n"
                )
                signingConfigs.getByName("debug")
            }

            // R8 strips unused Java/Kotlin from the plugins and the embedding.
            // Dart code is already tree-shaken by the Flutter toolchain.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }

        debug {
            // Lets a debug build sit alongside a store build on one device.
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-debug"
        }
    }

    // Play repacks the bundle per device; splitting by language would drop the
    // locales Flutter resolves at runtime rather than through Android resources.
    bundle {
        language {
            enableSplit = false
        }
    }
}

flutter {
    source = "../.."
}
