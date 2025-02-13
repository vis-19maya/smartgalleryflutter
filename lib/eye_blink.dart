
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:photo_manager/photo_manager.dart';

class EyeDetectionExample extends StatefulWidget {
  final List<AssetEntity> images;

  const EyeDetectionExample({super.key, required this.images});

  @override
  _EyeDetectionExampleState createState() => _EyeDetectionExampleState();
}

class _EyeDetectionExampleState extends State<EyeDetectionExample> {
  final FaceDetector faceDetector = FaceDetector(
    options: FaceDetectorOptions(enableClassification: true),
  );

  List<AssetEntity> eyeOpenImages = [];
  List<AssetEntity> eyeClosedImages = [];
  List<AssetEntity> noFaceImages = [];

  @override
  void initState() {
    super.initState();
    processImages(widget.images);
  }

  Future<void> processImages(List<AssetEntity> images) async {
    for (AssetEntity asset in images) {
      final file = await asset.file;
      if (file == null) continue;

      final inputImage = InputImage.fromFile(file);
      final List<Face> faces = await faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        noFaceImages.add(asset);
      } else {
        final face = faces.first;
        final double? leftEyeOpenProb = face.leftEyeOpenProbability;
        final double? rightEyeOpenProb = face.rightEyeOpenProbability;

        if (leftEyeOpenProb != null && rightEyeOpenProb != null) {
          bool areEyesOpen = leftEyeOpenProb > 0.5 && rightEyeOpenProb > 0.5;
          if (areEyesOpen) {
            eyeOpenImages.add(asset);
          } else {
            eyeClosedImages.add(asset);
          }
        } else {
          noFaceImages.add(asset);
        }
      }
    }

    setState(() {}); // Refresh UI after processing
  }

  @override
  void dispose() {
    faceDetector.close();
    super.dispose();
  }

  void navigateToGallery(List<AssetEntity> images, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GalleryScreen(images: images, title: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eye Detection')),
      body: Column(
        children: [
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              padding: const EdgeInsets.all(8),
              children: [
                FolderIcon(
                  title: 'Eyes Open',
                  count: eyeOpenImages.length,
                  icon: Icons.visibility,
                  onTap: () => navigateToGallery(eyeOpenImages, 'Eyes Open'),
                ),
                FolderIcon(
                  title: 'Eyes Closed',
                  count: eyeClosedImages.length,
                  icon: Icons.visibility_off,
                  onTap: () => navigateToGallery(eyeClosedImages, 'Eyes Closed'),
                ),
                FolderIcon(
                  title: 'No Face Detected',
                  count: noFaceImages.length,
                  icon: Icons.person_off,
                  onTap: () => navigateToGallery(noFaceImages, 'No Face Detected'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FolderIcon extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final VoidCallback onTap;

  const FolderIcon({super.key, 
    required this.title,
    required this.count,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50, color: Colors.blue),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text('$count images', style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class GalleryScreen extends StatefulWidget {
  final List<AssetEntity> images;
  final String title;

  const GalleryScreen({super.key, required this.images, required this.title});

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  Future<void> _deleteImage(int index) async {
    AssetEntity asset = widget.images[index];

    // Request permission if not granted
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission denied to delete images')),
      );
      return;
    }

    // Try to delete the image
    List<String>success = await PhotoManager.editor.deleteWithIds([asset.id]);
    
    if (success.isNotEmpty) {
      setState(() {
        widget.images.removeAt(index); // Remove from UI
      });
      Navigator.pop(context); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete image')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: widget.images.isEmpty
          ? const Center(child: Text('No images available'))
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                AssetEntity asset = widget.images[index];
                return FutureBuilder<Uint8List?>(
                  future: asset.thumbnailData,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return InkWell(
                      onLongPress: () {
                        _showDeleteDialog(index);
                      },
                      child: Image.memory(snapshot.data!, fit: BoxFit.cover),
                    );
                  },
                );
              },
            ),
    );
  }

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Image'),
          content: const Text('Are you sure you want to delete this image?'),
          actions: [
            TextButton(
              onPressed: () => _deleteImage(index), // Delete from phone storage
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}