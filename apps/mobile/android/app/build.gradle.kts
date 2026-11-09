plugins {
    id("com.android.application")
    // Declared in settings.gradle.kts but was never applied here — without it
    // `kotlinOptions` is unresolved and MainActivity.kt can't compile.
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // id("com.google.gms.google-services")
    // id("com.google.firebase.crashlytics")
}

android {
    namespace = "com.yourcompany.baseapp"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.yourcompany.baseapp"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "environment"

    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationId = "com.yourcompany.baseapp.dev"
            resValue("string", "app_name", "BaseApp Dev")
            resValue("string", "base_url", "https://pokeapi.co/api/v2/")
            resValue("string", "google_server_client_id", "YOUR_GOOGLE_SERVER_CLIENT_ID_DEV")
        }
        create("staging") {
            dimension = "environment"
            applicationId = "com.yourcompany.baseapp.staging"
            resValue("string", "app_name", "BaseApp Staging")
            resValue("string", "base_url", "https://pokeapi.co/api/v2/")
            resValue("string", "google_server_client_id", "YOUR_GOOGLE_SERVER_CLIENT_ID_STAGING")
        }
        create("prod") {
            dimension = "environment"
            applicationId = "com.yourcompany.baseapp"
            resValue("string", "app_name", "BaseApp")
            resValue("string", "base_url", "https://pokeapi.co/api/v2/")
            resValue("string", "google_server_client_id", "YOUR_GOOGLE_SERVER_CLIENT_ID_PROD")
        }
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

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    // Chucker - HTTP Inspector for Android
    debugImplementation("com.github.chuckerteam.chucker:library:4.0.0")
    releaseImplementation("com.github.chuckerteam.chucker:library-no-op:4.0.0")
}
