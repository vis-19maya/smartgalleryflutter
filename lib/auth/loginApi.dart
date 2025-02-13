
import 'package:flutter/material.dart';

import 'package:gallery/auth/registrationApi.dart';
import 'package:gallery/gallery.dart';
import 'package:gallery/ipaddress_page.dart';



int? lid;
String? userType;
String? loginstatus;

Future<void> loginapi(Username, Password, context) async {
  print("login ");
 try {
    final response =
   await dio.post('$baseurl/logincheck?email=$Username&Password=$Password');
  print(response.data);
  int? res = response.statusCode;
  loginstatus = response.data['status'] ?? 'failed';
  if (res == 200 && response.data['status'] == 'success') {
    lid = response.data['lid'];
   Navigator.pushReplacement(
       context, MaterialPageRoute(builder: (ctx) => GalleryScreen()));
  } else {
    print('Unknown userType');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('invalid credentials'),
      ),    
    );
  }
 } catch (e) {
     ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('connection error'),
      ),    
    );
 }
}
