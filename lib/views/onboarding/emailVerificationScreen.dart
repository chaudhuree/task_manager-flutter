import 'package:flutter/material.dart';
import 'package:task_manager/presenters/auth_presenter.dart';

import '../../style/style.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);
  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final AuthPresenter _presenter = AuthPresenter();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _presenter.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _presenter.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _formOnSubmit() async {
    bool success = await _presenter.verifyEmail(
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
            child: _presenter.isLoading
                ? (Center(child: CircularProgressIndicator()))
                : (SingleChildScrollView(
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
                  )),
          ),
        ],
      ),
    );
  }
}
