import 'package:flutter/material.dart';
import 'package:task_manager/style/style.dart';

class ProfileUpdateScreen extends StatefulWidget {
  const ProfileUpdateScreen({super.key});

  @override
  State<ProfileUpdateScreen> createState() => _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorBlue,
        title: Text(
          'Update Profile',
          style: TextStyle(color: colorWhite, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorWhite),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: const Center(child: Text('Profile Update Screen')),
    );
  }
}
