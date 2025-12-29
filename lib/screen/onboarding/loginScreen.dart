import 'package:flutter/material.dart';
import 'package:task_manager/api/api.dart';
import 'package:task_manager/style/style.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Map<String, String> formData = {"email": "", "password": ""};
  bool isLoading = false;

  inputOnChange(field, value) {
    setState(() {
      formData[field] = value;
    });
  }

  formOnSubmit() async {
    // Form Validation
    if (formData['email']!.isEmpty) {
      ErrorToast('Email Required !');
    } else if (formData['password']!.isEmpty) {
      ErrorToast('Password Required !');
    } else {
      setState(() {
        isLoading = true;
      });
      // Form Submit(API Request)
      bool res = await LoginRequest(formData);
      if (res == true) {
        SuccessToast('Login Successful !');
        setState(() {
          isLoading = false;
        });
        // Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
      } else {
        ErrorToast('Login Failed !');
        setState(() {
          isLoading = false;
        });
      }
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
                          decoration: AppInputDecoration("Email Address"),
                          onChanged: (value) => inputOnChange("email", value),
                        ),

                        SizedBox(height: 20),

                        TextFormField(
                          decoration: AppInputDecoration("Password"),
                          onChanged: (value) =>
                              inputOnChange("password", value),
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
