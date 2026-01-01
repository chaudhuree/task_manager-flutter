import 'package:flutter/material.dart';
import 'package:task_manager/api/api.dart';
import 'package:task_manager/style/style.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  formOnSubmit() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    // Form Validation
    if (email.isEmpty) {
      ErrorToast('Email Required !');
      return;
    }

    if (password.isEmpty) {
      ErrorToast('Password Required !');
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Form Submit(API Request)
    Map<String, String> formData = {"email": email, "password": password};
    bool res = await LoginRequest(formData);

    if (res == true) {
      SuccessToast('Login Successful !');
      setState(() {
        isLoading = false;
      });
      emailController.clear();
      passwordController.clear();
      Navigator.pushNamedAndRemoveUntil(context, "/taskList", (route) => false);
      return;
    } else {
      ErrorToast('Login Failed !');
      setState(() {
        isLoading = false;
      });
      emailController.clear();
      passwordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ScreenBackground(context),
          Container(
            alignment: Alignment.center,
            child: isLoading
                ? (Center(child: CircularProgressIndicator()))
                : (SingleChildScrollView(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Get Started With",
                          style: Head1Text(colorDarkBlue),
                        ),
                        SizedBox(height: 1),
                        Text(
                          "Task Manager App",
                          style: Head6Text(colorLightGray),
                        ),
                        SizedBox(height: 20),

                        TextFormField(
                          controller: emailController,
                          decoration: AppInputDecoration("Email Address"),
                        ),

                        SizedBox(height: 20),

                        TextFormField(
                          controller: passwordController,
                          decoration: AppInputDecoration("Password"),
                          obscureText: true,
                        ),

                        SizedBox(height: 20),

                        Container(
                          child: ElevatedButton(
                            style: AppButtonStyle(),
                            child: SuccessButtonChild('Login'),
                            onPressed: () {
                              formOnSubmit();
                            },
                          ),
                        ),

                        SizedBox(height: 20),

                        Container(
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              SizedBox(height: 20),
                              InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    "/emailVerification",
                                  );
                                },
                                child: Text(
                                  'Forget Password?',
                                  style: Head7Text(colorLightGray),
                                ),
                              ),

                              SizedBox(height: 15),

                              InkWell(
                                onTap: () {
                                  Navigator.pushNamed(context, "/registration");
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have a account? ",
                                      style: Head7Text(colorDarkBlue),
                                    ),
                                    Text(
                                      "Sign Up",
                                      style: Head7Text(colorGreen),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
          ),
        ],
      ),
    );
  }
}
