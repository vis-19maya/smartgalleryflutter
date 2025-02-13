import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:gallery/fullscreen_image_page.dart';
import 'package:gallery/ipaddress_page.dart';
import 'package:photo_manager/photo_manager.dart';

class DetectPage extends StatefulWidget {
  final List<AssetEntity> images;

  const DetectPage({Key? key, required this.images}) : super(key: key);

  @override
  State<DetectPage> createState() => _DetectPageState();
}

class _DetectPageState extends State<DetectPage> {
  final TextEditingController _objectController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  List<Map<String, dynamic>> _detectedImages = [];

  // Add a gradient for visual appeal
  final _gradient = LinearGradient(
    colors: [Colors.blue.shade600, Colors.blue.shade400],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  Future<void> _detectObjects() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _detectedImages = [];
    });

    try {
      final dio = Dio();
      final formData = FormData();

      formData.fields.add(
        MapEntry('object_name', _objectController.text.trim()),
      );

      final Map<String, AssetEntity> assetMap = {};

      for (var i = 0; i < widget.images.length; i++) {
        final File? file = await widget.images[i].file;
        if (file != null) {
          final filename = file.path.split('/').last;
          assetMap[filename] = widget.images[i];
          formData.files.add(
            MapEntry(
              'images[]',
              await MultipartFile.fromFile(file.path),
            ),
          );
        }
      }

      final response = await dio.post(
        '$baseurl/detect',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      if (response.statusCode == 200 && mounted) {
        final data = response.data;
        final detections = List<Map<String, dynamic>>.from(data['detections']);

        final detectedImages = detections.map((detection) {
          final filename = detection['file'] as String;
          return {...detection, 'asset': assetMap[filename]};
        }).toList();

        setState(() => _detectedImages = detectedImages);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Found ${data['total_detected']} matches out of ${data['total_processed']} images'),
            backgroundColor: Colors.green.shade800,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Text('Error: ${e.toString()}'),
              ],
            ),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _objectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Object Detection'),
        centerTitle: true,
        elevation: 4,
        shadowColor: Colors.black26,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _objectController,
                    decoration: InputDecoration(
                      labelText: 'Object Name',
                      hintText: 'Enter the object to detect',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) => value?.trim().isEmpty ?? true
                        ? 'Please enter an object name'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  _buildImageCountBadge(),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _detectObjects,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      shadowColor: Colors.blue.shade200,
                    ),
                    child: _isLoading
                        ? const _LoadingIndicator()
                        : Text(
                            'Detect Objects',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (_detectedImages.isNotEmpty) ...[
              _buildSectionTitle('Detection Results'),
              const SizedBox(height: 16),
              Expanded(
                child: _buildDetectionGrid(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImageCountBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.photo_library, color: Colors.grey.shade600, size: 18),
          const SizedBox(width: 8),
          Text(
            'Selected Images: ${widget.images.length}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
    );
  }

  Widget _buildDetectionGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _detectedImages.length,
      itemBuilder: (context, index) {
        final detection = _detectedImages[index];
        final asset = detection['asset'] as AssetEntity?;

        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              GestureDetector(
                onTap: () {
                  if (asset != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenImageView(
                          image: _detectedImages
                              .map((e) => e['asset'] as AssetEntity)
                              .toList(),
                          initialIndex: index,
                        ),
                      ),
                    );
                  }
                },
                child: _buildImageThumbnail(asset),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageThumbnail(AssetEntity? asset) {
    return FutureBuilder<Uint8List?>(
      future: asset?.thumbnailDataWithSize(const ThumbnailSize.square(300)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(color: Colors.grey.shade100);
        }
        if (snapshot.hasError || snapshot.data == null) {
          return Container(
            color: Colors.grey.shade200,
            child: const Center(
                child: Icon(Icons.broken_image, color: Colors.grey)),
          );
        }
        return Image.memory(
          snapshot.data!,
          fit: BoxFit.cover,
        );
      },
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Processing...',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color.fromARGB(255, 201, 159, 159),
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}