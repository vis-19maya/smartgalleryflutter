import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class FullScreenImageView extends StatefulWidget {
  final List<AssetEntity> image;
  final int initialIndex;

  const FullScreenImageView({super.key, required this.image, required this.initialIndex});

  @override
  _FullScreenImageViewState createState() => _FullScreenImageViewState();
}

class _FullScreenImageViewState extends State<FullScreenImageView> {
  late PageController _pageController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String?>(
          future: widget.image[currentIndex].titleAsync,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...');
            }
            final imageName = snapshot.data ?? 'Unnamed Image';
            return Text(imageName);
          },
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.image.length,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return FutureBuilder<Uint8List?>(
            future: widget.image[index].originBytes,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final imageData = snapshot.data;
              if (imageData == null) {
                return const Center(child: Text('Failed to load image'));
              }

              return Center(
                child: Image.memory(imageData, fit: BoxFit.contain),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
