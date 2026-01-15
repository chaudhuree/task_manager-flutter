import 'package:flutter/material.dart';
import 'package:task_manager/components/appBottomNav.dart';
import 'package:task_manager/components/cancelTaskList.dart';
import 'package:task_manager/components/copletedTaskList.dart';
import 'package:task_manager/components/newTaskList.dart';
import 'package:task_manager/components/progressTaskList.dart';
import 'package:task_manager/components/taskAppBar.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  int bottomTabIndex = 0;
  void onItemTapped(int index) {
    setState(() {
      bottomTabIndex = index;
    });
  }

  // List of widget options
  final widgetOptions = [
    NewTaskList(),
    ProgressTaskList(),
    CompletedTaskList(),
    CancelTaskList(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TaskAppBar(),
      body: widgetOptions.elementAt(bottomTabIndex),
      bottomNavigationBar: appBottomNav(bottomTabIndex, onItemTapped),
    );
  }
}
