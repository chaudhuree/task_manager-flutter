import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/presenters/auth_presenter.dart';

import '../../style/style.dart';

class PinVerificationScreen extends StatefulWidget {
  const PinVerificationScreen({Key? key}) : super(key: key);
  @override
  State<PinVerificationScreen> createState() => _PinVerificationScreenState();
}

class _PinVerificationScreenState extends State<PinVerificationScreen> {
  String _otpValue = '';

  Future<void> _formOnSubmit() async {
    final presenter = Provider.of<AuthPresenter>(context, listen: false);
    bool success = await presenter.verifyOtp(otp: _otpValue);

    if (success && mounted) {
      Navigator.pushNamed(context, "/setPassword");
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
                              "PIN Verification",
                              style: Head1Text(colorDarkBlue),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "A 6 digit pin has been sent to your email",
                              style: Head6Text(colorLightGray),
                            ),
                            SizedBox(height: 20),
                            PinCodeTextField(
                              appContext: context,
                              length: 6,
                              pinTheme: AppOTPStyle(),
                              animationType: AnimationType.fade,
                              animationDuration: Duration(milliseconds: 300),
                              enableActiveFill: true,
                              onCompleted: (v) {},
                              onChanged: (value) {
                                _otpValue = value;
                              },
                            ),
                            Container(
                              child: ElevatedButton(
                                style: AppButtonStyle(),
                                child: SuccessButtonChild('Verify'),
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
