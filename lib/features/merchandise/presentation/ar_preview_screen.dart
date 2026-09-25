import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ARPreviewScreen extends StatelessWidget {
  final String productName;
  
  const ARPreviewScreen({
    super.key,
    required this.productName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AR Preview: $productName'),
      ),
      body: Stack(
        children: [
          const ModelViewer(
            backgroundColor: Color(0xFF09040E),
            // Dummy 3D model provided by Google for testing AR
            src: 'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
            alt: 'A 3D model of an astronaut',
            ar: true,
            arModes: ['scene-viewer', 'webxr', 'quick-look'],
            autoRotate: true,
            cameraControls: true,
            // Styling for the AR button that appears in the viewer
            arScale: ArScale.auto,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Tip: Use the AR button in the bottom right corner of the viewer to project this model into your real room using your camera!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
