import 'package:flutter/material.dart';
import 'package:shopimg_cart/splashscreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokemon',
      theme: ThemeData(
        backgroundColor: Colors.pink[50], // Set light pink as background color
      ),
      home: SplashScreen(), // Set SplashScreen as the initial route
    );
  }
}
