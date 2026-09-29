plugins {
    id("com.android.application")
    // Traite google-services.json (voir android/settings.gradle.kts
    // pour la déclaration de version) : place le fichier téléchargé
    // depuis la console Firebase dans ce dossier (android/app/)
    // avant de lancer un build.
    id("com.google.gms.google-services")
    // AGP 9+ fournit Kotlin nativement ("Built-in Kotlin") : le plugin
    // "kotlin-android" (Kotlin Gradle Plugin classique) n'est plus
    // appliqué ici, et le bloc `kotlinOptions` qu'il fournissait est
    // remplacé plus bas par le DSL `compilerOptions` — voir le guide
    // de migration officiel :
    // https://docs.flutter.dev/release/breaking-changes/migrate-to-agp-9
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.cartodex"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        compilerOptions {
            jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.cartodex"
        // Firebase (firebase_auth notamment) exige minSdk 23 — plus
        // élevé que le minimum habituel de Flutter, d'où la valeur
        // fixée en dur ici plutôt que flutter.minSdkVersion.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
