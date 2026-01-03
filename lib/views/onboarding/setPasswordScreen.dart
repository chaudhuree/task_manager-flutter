import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/presenters/auth_presenter.dart';

import '../../style/style.dart';

class SetPasswordScreen extends StatefulWidget {
  const SetPasswordScreen({Key? key}) : super(key: key);
  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _formOnSubmit() async {
    final presenter = Provider.of<AuthPresenter>(context, listen: false);
    bool success = await presenter.resetPassword(
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
                        padding: EdgeInsets.all(30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Set Password",
                              style: Head1Text(colorDarkBlue),
                            ),
                            SizedBox(height: 1),
                            Text(
                              "Minimum length password 8 character with Letter and number combination",
                              style: Head7Text(colorLightGray),
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
                                child: SuccessButtonChild('Confirm'),
                                onPressed: () {
                                  _formOnSubmit();
                                },
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
