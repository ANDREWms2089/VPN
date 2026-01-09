plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.vpn_front"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.vpn_front"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion  // Минимум 23 для VPN функциональности
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
    
    packaging {
        jniLibs {
            // Разрешаем конфликт дублирующихся нативных библиотек
            // Используем первую найденную библиотеку (из flutter_v2ray_plus)
            pickFirsts += listOf("**/libtun2socks.so")
            pickFirsts += listOf("**/libv2ray.so")
            pickFirsts += listOf("**/libxray.so")
            pickFirsts += listOf("**/lib*.so")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Kotlin Coroutines для асинхронной работы в VPN Service
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.7.3")
    
    // TODO: Добавьте v2ray-core библиотеку после интеграции
    // implementation(files("libs/v2ray-core.aar"))
    // или
    // implementation("com.github.v2fly:v2ray-core:latest")
}
