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
            
            // Fix legacy compileSdkVersion in build.gradle if present
            val buildGradleFile = project.file("build.gradle")
            if (buildGradleFile.exists()) {
                try {
                    val bgText = buildGradleFile.readText()
                    if (bgText.contains("compileSdkVersion 30")) {
                        buildGradleFile.writeText(bgText.replace("compileSdkVersion 30", "compileSdkVersion 34"))
                    }
                } catch (e: Exception) {
                    // Skip if locked
                }
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

            // 4. Safely handle removed PluginRegistry.Registrar in legacy plugins (Flutter 3.29+)
            val srcDir = project.file("src/main/java")
            if (srcDir.exists()) {
                srcDir.walkTopDown().filter { it.extension == "java" }.forEach { javaFile ->
                    try {
                        val text = javaFile.readText()
                        if (text.contains("import io.flutter.plugin.common.PluginRegistry.Registrar;")) {
                            javaFile.writeText(text.replace("import io.flutter.plugin.common.PluginRegistry.Registrar;", "// import io.flutter.plugin.common.PluginRegistry.Registrar;"))
                        }
                    } catch (e: Exception) {
                        // Skip if file is locked or inaccessible
                    }
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
