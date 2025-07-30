// android/app/build.gradle.kts (App-level)

plugins {
    // These apply the plugins whose versions are defined in the project-level build.gradle.kts
    id("com.android.application")
    id("kotlin-android") // No version here, it uses the one defined in project-level build.gradle.kts
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // No version here, it uses the one defined in project-level build.gradle.kts
}

android {
    namespace = "com.example.mamasave"
    compileSdk = 35 // Confirmed from previous steps
    ndkVersion = "27.0.12077973" // Confirmed from previous steps

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.mamasave"
        minSdk = 23 // Confirmed from previous steps
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode.toInt() // Use .toInt() for versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Use the latest stable Firebase BOM if possible. 34.0.0 is fine.
    implementation(platform("com.google.firebase:firebase-bom:34.0.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
    // Add any other Firebase products your app uses (e.g., firebase-storage, firebase-messaging)
}