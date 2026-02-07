// android/build.gradle.kts
// DO NOT add repositories here (they are defined in settings.gradle.kts)

import org.gradle.api.tasks.Delete
import org.gradle.api.file.Directory

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()

rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

// 🌟 Ultimate Fix: Handle missing namespaces AND strip legacy package attributes
subprojects {
    val fixLegacyPlugin = Action<Project> {
        if (plugins.hasPlugin("com.android.library") || plugins.hasPlugin("com.android.application")) {
            val android = extensions.findByName("android") as? com.android.build.gradle.BaseExtension
            if (android != null) {
                val manifestFile = file("src/main/AndroidManifest.xml")
                if (manifestFile.exists()) {
                    val manifestContent = manifestFile.readText()
                    
                    // 1. Extract package name if namespace is missing
                    if (android.namespace == null || android.namespace!!.isEmpty()) {
                        val match = Regex("package=\"([^\"]*)\"").find(manifestContent)
                        val packageName = match?.groups?.get(1)?.value
                        android.namespace = packageName ?: "dev.upi.india.fix.${project.name.replace("-", "_")}"
                    }

                    // 2. Strip package attribute to satisfy AGP 8.0+
                    if (manifestContent.contains("package=")) {
                        val cleanedContent = manifestContent.replace(Regex("package=\"[^\"]*\""), "")
                        manifestFile.writeText(cleanedContent)
                        logger.lifecycle("Successfully healed manifest for legacy plugin: ${project.name}")
                    }
                }
            }
        }
    }

    if (state.executed) {
        fixLegacyPlugin.execute(this)
    } else {
        afterEvaluate {
            fixLegacyPlugin.execute(this)
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
