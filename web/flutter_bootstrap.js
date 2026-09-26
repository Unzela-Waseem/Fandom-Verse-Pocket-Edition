{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}},
  },
  onEntrypointLoaded: async function(engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine({
      // Force HTML renderer for maximum browser compatibility.
      // This avoids WebGL / CanvasKit shader compilation errors
      // on older GPUs, VMs, and browsers with limited WebGL support.
      renderer: "html",
    });
    await appRunner.runApp();
  }
});
