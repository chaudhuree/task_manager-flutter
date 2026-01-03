import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/presenters/auth_presenter.dart';

import '../../style/style.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);
  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _formOnSubmit() async {
    final presenter = Provider.of<AuthPresenter>(context, listen: false);
    bool success = await presenter.verifyEmail(
      email: _emailController.text.trim(),
    );

    if (success && mounted) {
      Navigator.pushNamed(context, "/pinVerification");
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
                              "Your Email Address",
                              style: Head1Text(colorDarkBlue),
                            ),
                            SizedBox(height: 1),
                            Text(
                              "A 6 digit verification pin will send to your email address",
                              style: Head6Text(colorLightGray),
                            ),
                            SizedBox(height: 20),
                            TextFormField(
                              controller: _emailController,
                              decoration: AppInputDecoration("Email Address"),
                            ),
                            SizedBox(height: 20),
                            Container(
                              child: ElevatedButton(
                                style: AppButtonStyle(),
                                child: SuccessButtonChild('Next'),
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
