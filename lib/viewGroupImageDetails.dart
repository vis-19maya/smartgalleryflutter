import 'package:flutter/material.dart';
import 'package:gallery/ipaddress_page.dart';

class ImageGroupPage extends StatelessWidget {
  const ImageGroupPage({super.key,required this.images,required this.title});

  final List<String> images;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(8.0), // Padding around the grid
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // Number of columns in the grid
          crossAxisSpacing: 8.0, // Horizontal spacing between grid items
          mainAxisSpacing: 8.0, // Vertical spacing between grid items
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(body: 
                  Center(
                    child: Container(height: 400,width: double.infinity,color: Colors.black12,
                    child: Image.network( '$baseurl/static/images/${images[index]}',fit: BoxFit.fill,)
                    ,),
                  )
                  ,)
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.black12, // Background color for each image item
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  '$baseurl/static/images/${images[index]}',
                  fit: BoxFit.cover, // Ensures images cover the container area
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
