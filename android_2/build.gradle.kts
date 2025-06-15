plugins {
    id("com.google.gms.google-services") version "4.4.2" apply false
    id("org.jetbrains.kotlin.android") apply false
}


allprojects {
    repositories {
        google()
        mavenCentral()
    }
}


/*import com.android.build.gradle.internal.cxx.configure.gradleLocalProperties

plugins {
    id("com.google.gms.google-services") version "4.4.2" apply false
		id("com.android.application")
    id("org.jetbrains.kotlin.android")
}


dependencies {
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.10")
    // inne zale�no�ci
}
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
} */

