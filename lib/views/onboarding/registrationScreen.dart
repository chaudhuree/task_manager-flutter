import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/presenters/auth_presenter.dart';

import '../../style/style.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});
  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _formOnSubmit() async {
    final presenter = Provider.of<AuthPresenter>(context, listen: false);
    bool success = await presenter.register(
      email: _emailController.text.trim(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      mobile: _mobileController.text.trim(),
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (success && mounted) {
      Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
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
                        child: Container(
                          padding: EdgeInsets.all(30),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Join With Us",
                                style: Head1Text(colorDarkBlue),
                              ),
                              SizedBox(height: 1),
                              Text(
                                "Create your account",
                                style: Head6Text(colorLightGray),
                              ),

                              SizedBox(height: 20),
                              TextFormField(
                                controller: _emailController,
                                decoration: AppInputDecoration("Email Address"),
                              ),

                              SizedBox(height: 20),
                              TextFormField(
                                controller: _firstNameController,
                                decoration: AppInputDecoration("First Name"),
                              ),

                              SizedBox(height: 20),
                              TextFormField(
                                controller: _lastNameController,
                                decoration: AppInputDecoration("Last Name"),
                              ),

                              SizedBox(height: 20),
                              TextFormField(
                                controller: _mobileController,
                                decoration: AppInputDecoration("Mobile"),
                              ),

                              SizedBox(height: 20),
                              TextFormField(
                                controller: _passwordController,
                                decoration: AppInputDecoration("Password"),
                                obscureText: true,
                              ),

                              SizedBox(height: 20),
                              TextFormField(
                                controller: _confirmPasswordController,
                                decoration: AppInputDecoration(
                                  "Confirm Password",
                                ),
                                obscureText: true,
                              ),

                              SizedBox(height: 20),
                              Container(
                                child: ElevatedButton(
                                  style: AppButtonStyle(),
                                  child: SuccessButtonChild('Registration'),
                                  onPressed: () {
                                    _formOnSubmit();
                                  },
                                ),
                              ),
                            ],
                          ),
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
