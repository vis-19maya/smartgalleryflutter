import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:photo_manager/photo_manager.dart';
import 'fullscreen_image_page.dart';

class LocationScreen extends StatefulWidget {
  final List<AssetEntity> images;
  const LocationScreen({super.key, required this.images});

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  Map<String, List<AssetEntity>> _groupedImages = {};

  @override
  void initState() {
    super.initState();
    _groupImagesByLocation();
  }

  Future<void> _groupImagesByLocation() async {
    Map<String, List<AssetEntity>> groupedImages = {};

    for (var image in widget.images) {
      String location = 'No Location';
      final latLng = await image.latlngAsync();
      if (latLng.latitude != null && latLng.longitude != null) {
        if (latLng.latitude == 0.00 && latLng.longitude == 0.00) {
          location = 'No Location';
        } else {
          List<Placemark> placemarks = await placemarkFromCoordinates(latLng.latitude!, latLng.longitude!);
          if (placemarks.isNotEmpty) {
            location = placemarks.first.locality ?? 'Unknown Location';
          }
        }
      }

      groupedImages.putIfAbsent(location, () => []).add(image);
    }

    setState(() {
      _groupedImages = groupedImages;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Locations'),
        centerTitle: true,
      ),
      body: _groupedImages.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _groupedImages.keys.length,
              itemBuilder: (context, index) {
                String location = _groupedImages.keys.elementAt(index);
                List<AssetEntity> locationImages = _groupedImages[location] ?? [];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.location_on, color: Colors.white, size: 30),
                    ),
                    title: Text(
                      location,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              LocationGalleryScreen(location: location, assets: locationImages),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class LocationGalleryScreen extends StatelessWidget {
  final String location;
  final List<AssetEntity> assets;

  const LocationGalleryScreen({super.key, required this.location, required this.assets});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(location),
        centerTitle: true,
      ),
      body: assets.isEmpty
          ? const Center(child: Text('No images found for this location.'))
          : GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: assets.length,
              itemBuilder: (context, index) {
                return FutureBuilder<Uint8List?>(
                  future: assets[index].thumbnailData,
                  builder: (context, snapshot) {
                    final thumbnailData = snapshot.data;
                    if (thumbnailData == null) return const Center(child: CircularProgressIndicator());

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullScreenImageView(image: assets, initialIndex: index,),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          thumbnailData,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
  }