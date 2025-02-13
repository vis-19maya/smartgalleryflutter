import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gallery/auth/loginApi.dart';
import 'package:gallery/ipaddress_page.dart';
import 'package:gallery/viewGroupImageDetails.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImageGroupScreen extends StatefulWidget {
  const ImageGroupScreen({super.key});

  @override
  _ImageGroupScreenState createState() => _ImageGroupScreenState();
}

class _ImageGroupScreenState extends State<ImageGroupScreen> {
  List<File> _images = [];
  String _heading = "";

  final ImagePicker _picker = ImagePicker();

  // Function to pick multiple images
  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _images = pickedFiles.map((file) => File(file.path!)).toList();
      });
    }
  }


  // get api
  //
  





  // Function to simulate sending images and title to server
  Future<void> _sendToServer() async {
  print("Sending data to server...");
  print("Heading: $_heading");
  print("Images: ${_images.length}");

  Dio dio = Dio();
  
  // Prepare the request URL and endpoint (update with your actual endpoint)
  String url = "$baseurl/groupupload?lid=$lid";

  // Create FormData to hold the title and images
  FormData formData = FormData();

  // Add the title to the FormData
  formData.fields.add(MapEntry('title', _heading));

  // Add each image to the FormData
  for (var image in _images) {
    // Assuming `image` is a File object, you can send the image as a file.
    // You could also read the file as a byte array if needed for base64 encoding.
    String fileName = 'image_${image.path.split("/").last}.jpg'; // Dynamically set the filename

    formData.files.add(MapEntry(
      'images', // This should match the parameter name expected by the server
      await MultipartFile.fromFile(image.path, filename: fileName),
    ));
  }

  // Send the request
  try {
    Response response = await dio.post(url, data: formData);

    // Check the response status
    if (response.statusCode == 200) {
      print(response.data);
      print("Data sent successfully!");
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data sent successfully!")),
      );
    } else {
      print("Failed to send data. Status code: ${response.statusCode}");
    }
  } catch (e) {
    print("Error: $e");
  }
}




  // Function to fetch image groups from server
  Future<List<Map<String,dynamic>>> _fetchImageGroups() async {
    try {
    // Define the URL with the groupid
    String url = "$baseurl/view_images_group?lid=$lid";
    Dio dio = Dio();
    
    // Make the GET request
    Response response = await dio.get(url);
    
    // Check the status code and handle the response
    if (response.statusCode == 200) {
      print(response.data);
      return List<Map<String,dynamic>>.from(response.data);  // Return the data received from the API
    } else {
      // Handle unsuccessful response
      throw Exception('Failed to get images: ${response.statusCode}');
    }
  } catch (e) {
    // Handle errors
    print('Error: $e');
    return [];  // Return null if there is an error
  }
  }

  // Function to fetch images of a group


  // Function to open the Add Image dialog with a StatefulWidget
  void _openAddImageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Add Images and Heading"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          _heading = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: "Enter a Heading",
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _pickImages,
                      child: const Text("Choose Images"),
                    ),
                    const SizedBox(height: 10),
                    // _images.isNotEmpty
                    //     ? GridView.builder(
                    //         shrinkWrap: true,
                    //         gridDelegate:
                    //             const SliverGridDelegateWithFixedCrossAxisCount(
                    //           crossAxisCount: 3,
                    //           crossAxisSpacing: 10,
                    //           mainAxisSpacing: 10,
                    //         ),
                    //         itemCount: _images.length,
                    //         itemBuilder: (context, index) {
                    //           return Image.file(
                    //             _images[index],
                    //             height: 50,
                    //             width: 50,
                    //             fit: BoxFit.cover,
                    //           );
                    //         },
                    //       )
                    //     : const Center(child: Text("No images selected")),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    _sendToServer();
                   // Close the dialog after submission
                  },
                  child: const Text("Submit"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Group Screen"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _openAddImageDialog, // Show the dialog when clicked
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String,dynamic>>>(
          future: _fetchImageGroups(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text("Error fetching image groups"));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No image groups available"));
            }

            final groups = snapshot.data!;

            return ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final groupName = groups[index];

               return ListTile(leading: Icon(Icons.folder,color: Colors.amber,),
  title: Text(groupName['title']),
  onTap: () async {
    // Safely cast the images to List<String>
    List<String> images = List<String>.from(groupName['images']);

    Navigator.push(context, 
    MaterialPageRoute(
      builder: (context) => ImageGroupPage(images: images,title:groupName['title'] ,),
    ),
   );
  },
);

              },
            );
          },
        ),
      ),
    );
  }
}
