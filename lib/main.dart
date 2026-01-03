import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/presenters/auth_presenter.dart';
import 'package:task_manager/utility/utility.dart';
import 'package:task_manager/views/onboarding/emailVerificationScreen.dart';
import 'package:task_manager/views/onboarding/loginScreen.dart';
import 'package:task_manager/views/onboarding/pinVerificationScreen.dart';
import 'package:task_manager/views/onboarding/registrationScreen.dart';
import 'package:task_manager/views/onboarding/setPasswordScreen.dart';
import 'package:task_manager/views/task/homeScreen.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RemoveToken();
  String? token = await ReadUserData("token");
  // print("User Token : $token");
  if (token == null) {
    runApp(const MyApp(initialRoute: "/login"));
  } else {
    runApp(const MyApp(initialRoute: "/"));
  }
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthPresenter()),
        // Add more providers here as you create them
        // ChangeNotifierProvider(create: (_) => TaskPresenter()),
      ],
      child: MaterialApp(
        title: 'Task Manager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        initialRoute: initialRoute,
        routes: {
          '/': (context) => const Homescreen(),
          // '/': (context) => const Splashscreen(),
          '/login': (context) => const LoginScreen(),
          '/registration': (context) => const RegistrationScreen(),
          '/emailVerification': (context) => const EmailVerificationScreen(),
          '/pinVerification': (context) => const PinVerificationScreen(),
          '/setPassword': (context) => const SetPasswordScreen(),
        },
      ),
    );
  }
}
