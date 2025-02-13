import 'package:flutter/material.dart';
import 'package:gallery/ipaddress_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: ' Smart Gallery ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const IpAddressInputPage(),
    );
  }
}




