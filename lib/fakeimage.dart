import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gallery/ipaddress_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

class ImageUploadScreen extends StatefulWidget {
  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  File? _image;
  int? _description;

  // Pick image from gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Upload image to the server using Dio
  Future<void> _uploadImage() async {
    print('object');
    if (_image == null) return;

    Dio dio = Dio();
    String uploadUrl = '$baseurl/detectimg';

    try {
      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(_image!.path),
      });

      Response response = await dio.post(uploadUrl, data: formData);

      if (response.statusCode == 200) {
        // Get the description from the server response
        setState(() {
          print(response.data);
          _description = response.data['is_fake'];
          
        });
      } else {
        print('Error uploading image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Fake Image Detection")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image display
            _image != null
                ? Container(height: 200,width: double.infinity,color: Colors.black12,
                  child: Image.file(_image!, height: 200, width: 200,fit: BoxFit.fill,))
                :Container(height: 200,width: double.infinity,color: Colors.black12,
                  child: Center(child: Text("No image selected"),)) ,
            SizedBox(height: 16),
            // Pick Image button
            Container(
              height: 35,width: double.infinity,
              child: ElevatedButton(
                 style: ElevatedButton.styleFrom(backgroundColor: Colors.blue,foregroundColor: Colors.white),
                onPressed: _pickImage,
                child: Text("Pick Image"),
              ),
            ),
            SizedBox(height: 16),
            // Upload Image button
            Container(
               height: 35,width: double.infinity,
              child: ElevatedButton(
                 style: ElevatedButton.styleFrom(backgroundColor: Colors.blue,foregroundColor: Colors.white),
                onPressed: _uploadImage,
                child: Text("Detect Image"),
              ),
            ),
            SizedBox(height: 16),
            // Display description from server response
            if (_description != null) ...[
             
              Text(_description==1?'fake image detected':'real image detected'),
            ],
          ],
        ),
      ),
    );
  }
}
