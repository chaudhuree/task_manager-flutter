import 'package:flutter/material.dart';
import 'package:task_manager/api/api.dart';
import 'package:task_manager/style/style.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Map<String, String> FormValues = {"email": "", "password": ""};
  bool Loading = false;

  InputOnChange(MapKey, Textvalue) {
    setState(() {
      FormValues.update(MapKey, (value) => Textvalue);
    });
  }

  formOnSubmit() async {
    String email = FormValues["email"]!.trim();
    String password = FormValues["password"]!.trim();

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
      Loading = true;
    });

    // Form Submit(API Request)
    Map<String, String> formData = {"email": email, "password": password};
    bool res = await LoginRequest(formData);

    if (res == true) {
      SuccessToast('Login Successful !');
      setState(() {
        Loading = false;
      });
      setState(() {
        FormValues = {"email": "", "password": ""};
      });
      Navigator.pushNamedAndRemoveUntil(context, "/taskList", (route) => false);
    } else {
      ErrorToast('Login Failed !');
      setState(() {
        Loading = false;
      });
      setState(() {
        FormValues = {"email": "", "password": ""};
      });
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
            child: Loading
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
                          onChanged: (value) {
                            InputOnChange("email", value);
                          },
                          decoration: AppInputDecoration("Email Address"),
                        ),

                        SizedBox(height: 20),

                        TextFormField(
                          onChanged: (value) {
                            InputOnChange("password", value);
                          },
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
