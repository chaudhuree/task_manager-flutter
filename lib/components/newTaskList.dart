import 'package:flutter/material.dart';
import 'package:task_manager/utility/utility.dart';

class NewTaskList extends StatefulWidget {
  const NewTaskList({super.key});

  @override
  State<NewTaskList> createState() => _NewTaskListState();
}

class _NewTaskListState extends State<NewTaskList> {
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
