import 'dart:io';
import 'package:dio/dio.dart';
import 'package:gallery/ipaddress_page.dart';
import 'package:photo_manager/photo_manager.dart';

// final baseurl = 'http://192.168.36.95:5000';

Future<Map<String, List<String>>> sendAllImagesToApi(List<AssetEntity> images) async {
  final Dio dio = Dio();
  Map<String, List<String>> responseMap = {};

  try {
    FormData formData = FormData();

    for (AssetEntity image in images) {
      File? file = await image.file;
      if (file == null) {
        print("Failed to retrieve image file for ${image.title}");
        continue;
      }

      formData.files.add(MapEntry(
        "files",
        await MultipartFile.fromFile(file.path, filename: image.title),
      ));
    }

    if (formData.files.isEmpty) {
      print("No valid files to upload.");
      return {};
    }

    Response response = await dio.post(
      '$baseurl/uploadimg', 
      data: formData,
      options: Options(
        headers: {
          "Content-Type": "multipart/form-data",
        },
      ),
    );

    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;

      responseMap = data.map((key, value) {
        return MapEntry(key, List<String>.from(value));
      });

      print("All images uploaded successfully: $responseMap");
    } else {
      print("Failed to upload images: ${response.statusCode}");
    }
  } catch (e) {
    print("Error uploading images: $e");
  }

  return responseMap;
}

