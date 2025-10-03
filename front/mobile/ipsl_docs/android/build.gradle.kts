// import org.jetbrains.kotlin.gradle.tasks.KotlinCompile
import java.io.File

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}


val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)


subprojects {
    project.layout.buildDirectory.set(newBuildDir.dir(project.name))
    project.evaluationDependsOn(":app")

 
    plugins.withId("java") {
        the<JavaPluginExtension>().apply {
            sourceCompatibility = JavaVersion.VERSION_17
            targetCompatibility = JavaVersion.VERSION_17
        }
    }

 

  
}

// 🧹 Tâche clean
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

//TODO just for test