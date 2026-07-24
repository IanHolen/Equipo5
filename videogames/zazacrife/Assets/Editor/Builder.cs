using System;
using System.Linq;
using UnityEditor;
using UnityEditor.Build.Reporting;
using UnityEngine;

// Script de build para compilar el juego a WebGL en modo batch (CI).
// Se invoca con: -executeMethod Builder.PerformWebGLBuild
public class Builder
{
    public static void PerformWebGLBuild()
    {
        string outputPath = Environment.GetEnvironmentVariable("WEBGL_OUTPUT");
        if (string.IsNullOrEmpty(outputPath)) outputPath = "build/WebGL";

        string[] scenes = EditorBuildSettings.scenes
            .Where(s => s.enabled)
            .Select(s => s.path)
            .ToArray();

        Debug.Log($"[Builder] Compilando {scenes.Length} escenas -> {outputPath}");
        foreach (var s in scenes) Debug.Log($"[Builder] escena: {s}");

        var options = new BuildPlayerOptions
        {
            scenes = scenes,
            locationPathName = outputPath,
            target = BuildTarget.WebGL,
            options = BuildOptions.None,
        };

        BuildReport report = BuildPipeline.BuildPlayer(options);
        if (report.summary.result != BuildResult.Succeeded)
        {
            Debug.LogError($"[Builder] Build FALLÓ: {report.summary.result} ({report.summary.totalErrors} errores)");
            EditorApplication.Exit(1);
        }
        Debug.Log($"[Builder] Build OK ({report.summary.totalSize} bytes)");
        EditorApplication.Exit(0);
    }
}
