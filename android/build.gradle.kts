buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.2")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Configure Flutter's expected build output directory
rootProject.layout.buildDirectory.set(
    rootProject.layout.projectDirectory.dir("../build")
)

subprojects {
    layout.buildDirectory.set(
        rootProject.layout.buildDirectory.dir(project.name)
    )
}
