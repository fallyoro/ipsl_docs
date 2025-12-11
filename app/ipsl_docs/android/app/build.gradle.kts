plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")// version "4.4.4" apply false    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.ipsl_docs"
    compileSdk = 36
    buildToolsVersion = "36.0.0"
    ndkVersion = "28.1.13356709"


    signingConfigs {
        getByName("debug").apply {
            keyAlias = "androidkey"
            keyPassword = "android"
            storeFile = file("mykey.jks")
           // storePassword = "domada"
        }
    }
    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    dependencies {
        implementation(platform("com.google.firebase:firebase-bom:34.4.0"))
        implementation("com.google.android.gms:play-services-auth:21.2.0")
        implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
        coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5") // ✅ Kotlin DSL utilise des parenthèses
    }

    // kotlinOptions {
    //     jvmTarget = "17"
    // }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.ipsl_docs"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        ndk {
            abiFilters("armeabi-v7a", "arm64-v8a")
        }

        
    }

    buildTypes {
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
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
