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
    // Only call evaluationDependsOn for projects that actually exist and aren't the app itself
    if (project.name != "app") {
        project.evaluationDependsOn(":app")
    }
}

// 🌟 Ultimate Fix: Automatically resolve namespace errors and Java compatibility for ALL plugins
subprojects {
    val fixLegacyPlugin: Project.() -> Unit = {
        // 1. Suppress "obsolete source value 8" warnings globally
        tasks.withType<JavaCompile>().configureEach {
            options.compilerArgs.add("-Xlint:-options")
        }

        val android = extensions.findByName("android") as? com.android.build.gradle.BaseExtension
        android?.let {
            // 2. Force a namespace if missing (required by AGP 8.0+)
            if (it.namespace == null || it.namespace!!.isEmpty()) {
                it.namespace = "com.fix.namespace.${project.name.replace("-", "_").replace(":", ".")}"
            }
            
            // 3. Safely handle legacy manifest issues
            val manifestFile = project.file("src/main/AndroidManifest.xml")
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

    // Check project state to avoid "already evaluated" errors
    if (state.executed) {
        fixLegacyPlugin()
    } else {
        afterEvaluate {
            fixLegacyPlugin()
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
