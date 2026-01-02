import 'package:flutter/material.dart';
import 'package:task_manager/style/style.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          screenBackground(context),
          Center(child: Image(image: AssetImage('assets/images/logo.png'))),
        ],
      ),
    );
  }
}
