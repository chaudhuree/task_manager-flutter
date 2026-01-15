import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/presenters/auth_presenter.dart';
import 'package:task_manager/utility/utility.dart';

import '../../style/style.dart';

class ProfileUpdateScreen extends StatefulWidget {
  const ProfileUpdateScreen({super.key});
  @override
  State<ProfileUpdateScreen> createState() => _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  void getUserData() async {
    String? firstName = await ReadUserData('firstName');
    String? lastName = await ReadUserData('lastName');
    // String? photo = await ReadUserData('photo');
    String? mobile = await ReadUserData('mobile');
    setState(() {
      _firstNameController.text = firstName ?? '';
      _lastNameController.text = lastName ?? '';
      _mobileController.text = mobile ?? '';
    });
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _formOnSubmit() async {
    // final presenter = Provider.of<AuthPresenter>(context, listen: false);
    // bool success = await presenter.register(
    //   email: _emailController.text.trim(),
    //   firstName: _firstNameController.text.trim(),
    //   lastName: _lastNameController.text.trim(),
    //   mobile: _mobileController.text.trim(),
    //   password: _passwordController.text,
    //   confirmPassword: _confirmPasswordController.text,
    // );

    // if (success && mounted) {
    //   Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
    // }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorBlue,
        title: Text('Update Profile', style: TextStyle(color: colorWhite)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorWhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
                                "Update Your Profile",
                                style: Head1Text(colorDarkBlue),
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
                                  child: SuccessButtonChild('Update Profile'),
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
