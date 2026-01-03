import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/presenters/auth_presenter.dart';
import 'package:task_manager/style/style.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _formOnSubmit() async {
    final presenter = Provider.of<AuthPresenter>(context, listen: false);
    bool success = await presenter.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (success) {
      _emailController.clear();
      _passwordController.clear();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          mainBackground(context),
          Container(
            alignment: Alignment.center,
            child: Consumer<AuthPresenter>(
              builder: (context, presenter, child) {
                return presenter.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
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
                              controller: _emailController,
                              decoration: AppInputDecoration("Email Address"),
                            ),
                            SizedBox(height: 20),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: AppInputDecoration("Password"),
                            ),
                            SizedBox(height: 20),
                            Container(
                              child: ElevatedButton(
                                style: AppButtonStyle(),
                                onPressed: () {
                                  _formOnSubmit();
                                },
                                child: SuccessButtonChild("Login"),
                              ),
                            ),
                            SizedBox(height: 45),
                            Container(
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        "/emailVerification",
                                      );
                                    },
                                    child: Text(
                                      "Forget Password?",
                                      style: Head7Text(colorLightGray),
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        "/registration",
                                      );
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Don't have an account? ",
                                          style: Head7Text(colorDarkBlue),
                                        ),
                                        Text(
                                          "Sign up",
                                          style: Head7Text(colorBlue),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}
