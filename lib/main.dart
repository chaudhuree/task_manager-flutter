import 'package:flutter/material.dart';
import 'package:task_manager/screen/onboarding/emailVerificationScreen.dart';
import 'package:task_manager/screen/onboarding/loginScreen.dart';
import 'package:task_manager/screen/onboarding/pinVerificationScreen.dart';
import 'package:task_manager/screen/onboarding/registrationScreen.dart';
import 'package:task_manager/screen/onboarding/setPasswordScreen.dart';
import 'package:task_manager/screen/onboarding/splashScreen.dart';
import 'package:task_manager/screen/task/newTaskListScreen.dart';
import 'package:task_manager/utility/utility.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? token = await ReadUserData("token");
  // print("User Token : $token");
  if (token == null) {
    runApp(const MyApp(initialRoute: "/login"));
  } else {
    runApp(const MyApp(initialRoute: "/taskList"));
  }
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: initialRoute,
      routes: {
        '/': (context) => const Splashscreen(),
        '/login': (context) => const LoginScreen(),
        '/registration': (context) => const RegistrationScreen(),
        '/emailVerification': (context) => const EmailVerificationScreen(),
        '/pinVerification': (context) => const PinVerificationScreen(),
        '/setPassword': (context) => const SetPasswordScreen(),
        '/taskList': (context) => const NewTaskListScreen(),
      },
    );
  }
}
