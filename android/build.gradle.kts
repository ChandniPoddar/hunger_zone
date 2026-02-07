// android/build.gradle.kts
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

// 🌟 Ultimate Fix: Automatically resolve namespace errors for ALL plugins
// This version is state-aware to avoid "Project already evaluated" errors.
subprojects {
    val fixLegacyPlugin: (Project) -> Unit = { p ->
        if (p.plugins.hasPlugin("com.android.library") || p.plugins.hasPlugin("com.android.application")) {
            val android = p.extensions.findByName("android") as? com.android.build.gradle.BaseExtension
            if (android != null) {
                // 1. Force a namespace if missing (required by AGP 8.0+)
                if (android.namespace == null || android.namespace!!.isEmpty()) {
                    android.namespace = "com.fix.namespace.${p.name.replace("-", "_").replace(":", ".")}"
                }
                
                // 2. Safely handle legacy manifest issues
                val manifestFile = p.file("src/main/AndroidManifest.xml")
                if (manifestFile.exists()) {
                    try {
                        val content = manifestFile.readText()
                        if (content.contains("package=")) {
                            val cleaned = content.replace(Regex("package=\"[^\"]*\""), "")
                            manifestFile.writeText(cleaned)
                        }
                    } catch (e: Exception) {
                        // Skip if file is locked or inaccessible
                    }
                }
            }
        }
    }

    if (state.executed) {
        fixLegacyPlugin(this)
    } else {
        afterEvaluate {
            fixLegacyPlugin(this)
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
