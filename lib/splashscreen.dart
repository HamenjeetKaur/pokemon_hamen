import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shopimg_cart/Dashboard.dart'; // Import the intro_page.dart file

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
// Delay navigation to IntroPage after splash screen by 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
// Background image or color
          Container(
            decoration: BoxDecoration(
// You can use an image here or just a solid color
              color: Colors.white, // Change it to your desired color
            ),
          ),
// Logo
          Positioned(
            top: MediaQuery
                .of(context)
                .size
                .height * 0.3,
            left: MediaQuery
                .of(context)
                .size
                .width * 0.3,
            child: Image.asset(
              'assets/ss.jpg', // Replace with your image path
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.4,
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.4,
// You may need to adjust width and height accordingly
            ),
          ),
// Text
          Positioned(
            bottom: 50.0,
            left: 0,
            right: 0,
            child: Text(
              'Pokemon',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black, // Change it to your desired color
                fontSize: 24.0, // Adjust font size as needed
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}