plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.fanchen.neo_light"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // 注释掉 jvmToolchain，改用旧的 kotlinOptions
    // kotlin {
    //     jvmToolchain(17)
    // }
    kotlinOptions {
        jvmTarget = "11" // 匹配 Java 11
    }

    defaultConfig {
        applicationId = "com.fanchen.neo_light"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // 最简签名配置（直接硬编码，避开 Properties 加载问题）
    signingConfigs {
        create("release") {
            // 替换为你自己的签名信息
            keyAlias = "my-key-alias"          // 你的密钥别名
            keyPassword = "neolight"        // 生成密钥时设置的密码
            storePassword = "neolight"    // 生成密钥时设置的库密码
            storeFile = file("my-release-key.jks") // 确保 jks 文件在 android/app 目录下
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
}