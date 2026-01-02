import 'package:flutter/material.dart';
import 'package:task_manager/utility/utility.dart';

class NewTaskListScreen extends StatefulWidget {
  const NewTaskListScreen({super.key});

  @override
  State<NewTaskListScreen> createState() => _NewTaskListScreenState();
}

class _NewTaskListScreenState extends State<NewTaskListScreen> {
  String email = "";

  void initState() {
    CallUserData();
    super.initState();
  }

  CallUserData() async {
    email = await ReadUserData('email') ?? "";
    setState(() {
      email = email;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(email)));
  }
}
