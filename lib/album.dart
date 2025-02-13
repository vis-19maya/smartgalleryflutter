import 'package:flutter/material.dart';
import 'package:gallery/detect_page.dart';
import 'package:gallery/eye_blink.dart';
import 'package:gallery/face.dart';
import 'package:gallery/location_page.dart';
import 'package:photo_manager/photo_manager.dart';

class AlbumPage extends StatelessWidget {
  final List<AssetEntity> images;

  const AlbumPage({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          CategoryTile(
            icon: Icons.location_on,
            label: 'Location',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LocationScreen(images: images),
                ),
              );
            },
          ),
          CategoryTile(
            icon: Icons.face,
            label: 'Face',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FaceListView(images: images),
                ),
              );
            },
          ),
          CategoryTile(
            icon: Icons.remove_red_eye,
            label: 'Eye Blinks',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EyeDetectionExample(images: images),
                ),
              );
            },
          ),
          CategoryTile(
            icon: Icons.search,
            label: 'Search',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetectPage(images: images),
                ),
              );
            },
          ),
          
        ],
      ),
    );
  }
}

class CategoryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const CategoryTile({super.key, 
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 40.0,
              color: Colors.blue,
            ),
            const SizedBox(width: 20.0),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 20.0,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
