plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.android_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.android_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24  // AUMENTAR para suporte MediaPipe
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // MediaPipe GenAI configurações
        ndk {
            abiFilters += listOf("arm64-v8a", "x86_64") // Otimizar para 64-bit
        }
        
        // Configurações para resolver problemas de EGL/OpenGL
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        vectorDrawables {
            useSupportLibrary = true
        }
    }
    
    // Configurações para MediaPipe GenAI
    aaptOptions {
        noCompress += "tflite"
        noCompress += "lite"
        noCompress += "task"  // ADICIONAR para modelos .task
    }
    
    // CONFIGURAÇÕES AVANÇADAS PARA MEDIAPIPE
    packagingOptions {
        pickFirst "**/libc++_shared.so"
        pickFirst "**/libjsc.so"
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

// Dependências MediaPipe GenAI
dependencies {
    // MediaPipe GenAI (comentado até estar disponível)
    // implementation 'com.google.mediapipe:tasks-genai:0.10.8'
    // implementation 'com.google.mediapipe:framework:0.10.8'
    // implementation 'org.tensorflow:tensorflow-lite:2.13.0'
    // implementation 'org.tensorflow:tensorflow-lite-gpu:2.13.0'
}
