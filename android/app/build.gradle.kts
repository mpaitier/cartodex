import java.io.FileInputStream
import java.util.Properties

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

// Clé de signature de la release, lue dans android/key.properties
// (jamais versionné, voir android/key.properties.example). Sans ce
// fichier, la release retombe sur la clé de debug pour que
// `flutter run --release` reste possible sur une machine qui n'a pas
// la clé, avec un avertissement : un tel APK ne doit pas être publié.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}

android {
    namespace = "com.mpaitier.cartodex"
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
        // Identifiant définitif de l'application : il ne peut plus
        // changer une fois l'app publiée sur le Play Store.
        applicationId = "com.mpaitier.cartodex"
        // Firebase (firebase_auth notamment) exige minSdk 23 — plus
        // élevé que le minimum habituel de Flutter, d'où la valeur
        // fixée en dur ici plutôt que flutter.minSdkVersion.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                logger.warn(
                    "android/key.properties introuvable : la release est " +
                        "signée avec la clé de debug (APK à ne pas publier).",
                )
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
