import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gallery/album.dart';
import 'package:gallery/complaintScreen.dart';
import 'package:gallery/fakeimage.dart';
import 'package:gallery/fullscreen_image_page.dart';
import 'package:gallery/grouped%20images.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';
import 'dart:io';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<AssetEntity> _images = [];
  int _currentIndex = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions();
  }

  Future<bool> _checkAndRequestPermissions() async {
    // For Android
    if (Platform.isAndroid) {
      final sdk = await PhotoManager.requestPermissionExtend();
      if (sdk == PermissionState.authorized) {
        return true;
      }
      if (sdk == PermissionState.denied) {
        // Request multiple permissions for Android
        final permissions = await [
          Permission.storage,
          Permission.photos,
          Permission.videos,
        ].request();

        return permissions.values.every((status) => status.isGranted);
      }
      return false;
    }

    return false;
  }

  Future<void> _fetchImages() async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      final hasPermission = await _checkAndRequestPermissions();
      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please grant photo access permission from settings'),
            duration: Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: openAppSettings,
            ),
          ),
        );
        return;
      }

      await _loadImages();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading images: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadImages() async {
    try {
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
      );

      if (albums.isEmpty) {
        setState(() {
          _images = [];
        });
        return;
      }

      final List<AssetEntity> images = await albums[0].getAssetListPaged(
        page: 0,
        size: 20,
      );

      setState(() {
        _images = images;
      });
    } catch (e) {
      print('Error loading images: $e');
      rethrow;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Add your logo image here
            Image.asset(
              'assets/Logo.png', // Path to your logo image
              height: 40, // Adjust the height of the logo
            ),
            const SizedBox(width: 10), // Space between logo and title
            const Text('Gallery'), // Title
          ],
        ),
        actions:  [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: openAppSettings,
          ),
           IconButton(
            icon: Icon(Icons.feedback),
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (cfb)=>ComplaintScreen()));
            },
          ),
        ],
      ),
      body: _currentIndex == 0
          ? _buildPhotosView():_currentIndex == 1?ImageUploadScreen():_currentIndex == 3?ImageGroupScreen()
          : AlbumPage(
              images: _images,
            ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
       
        type: BottomNavigationBarType.fixed,
        // Add your bottom navigation items here
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.photo),
            label: 'Photos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.album),
            label: 'fake',
          ),
            BottomNavigationBarItem(
            icon: Icon(Icons.album),
            label: 'Albums',
          ),
           BottomNavigationBarItem(
            icon: Icon(Icons.album),
            label: 'Groups',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildPhotosView() {
    return RefreshIndicator(
      onRefresh: _fetchImages,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _images.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No images found'),
                      ElevatedButton(
                        onPressed: _fetchImages,
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder<Uint8List?>( 
                      future: _images[index].thumbnailData,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data == null) {
                          return const Center(child: Icon(Icons.error));
                        }

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullScreenImageView(
                                  image: _images,
                                  initialIndex: index,
                                ),
                              ),
                            );
                          },
                          child: Image.memory(
                            snapshot.data!,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
