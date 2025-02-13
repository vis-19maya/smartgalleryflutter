import 'package:flutter/material.dart';
import 'package:gallery/face_images_view.dart';
import 'package:gallery/image_api.dart';
import 'package:gallery/ipaddress_page.dart';
import 'package:photo_manager/photo_manager.dart';

Map<String, List<String>> uploadedImages = {};

class FaceListView extends StatefulWidget {
  final List<AssetEntity> images;
  final Map<String, List<String>>? uploadedImages;

  const FaceListView({super.key, required this.images, this.uploadedImages});

  @override
  _FaceListViewState createState() => _FaceListViewState();
}

class _FaceListViewState extends State<FaceListView> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.uploadedImages != null) {
      uploadedImages = widget.uploadedImages!;
    }
    if (uploadedImages.isEmpty) {
      _sendImage();
    }
  }

  Future<void> _sendImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await sendAllImagesToApi(widget.images);
      if (mounted) {
        setState(() {
          uploadedImages = response;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to upload images: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToGridView(String folderName, List<String> images) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ImageGridView(folderName: folderName, images: images),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Face List View",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        // backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: _isLoading && uploadedImages.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    "Uploading images...",
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : uploadedImages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_upload_rounded,
                          size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        "No images uploaded yet",
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _sendImage,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Number of columns in the grid
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: uploadedImages.keys.length,
                    itemBuilder: (context, index) {
                      String folderName = uploadedImages.keys.elementAt(index);
                      List<String> images = uploadedImages[folderName] ?? [];
                      String? folderImage =
                          images.isNotEmpty ? images.first : null;

                      return GestureDetector(
                        onTap: () => _navigateToGridView(folderName, images),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              folderImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        '$baseurl/static/images/grouped_photos/$folderImage',
                                        height: 80,
                                        width: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error,
                                            stackTrace) {
                                          return const Icon(
                                              Icons.broken_image_rounded,
                                              size: 50,
                                              color: Colors.red);
                                        },
                                        loadingBuilder: (context, child,
                                            loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return const CircularProgressIndicator();
                                        },
                                      ),
                                    )
                                  : const Icon(Icons.broken_image_rounded,
                                      size: 50, color: Colors.red),
                              const SizedBox(height: 8),
                              Text(
                                folderName,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}


