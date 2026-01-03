import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/api_service.dart';
import '../style/style.dart';
import '../utility/utility.dart';

/// Auth Presenter - handles all authentication business logic
/// Simple MVP: Presenter manages state and business logic, View handles UI
class AuthPresenter extends ChangeNotifier {
  // State
  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _currentUser;
  String? _recoveryEmail;
  String? _recoveryOtp;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;
  String? get recoveryEmail => _recoveryEmail;
  String? get recoveryOtp => _recoveryOtp;

  /// Set loading state and notify listeners
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Set error message and show toast
  void _setError(String message) {
    _errorMessage = message;
    ErrorToast(message);
  }

  /// Show success message
  void _showSuccess(String message) {
    SuccessToast(message);
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
  }

  // ==================== Login ====================

  /// Login with email and password
  Future<bool> login({required String email, required String password}) async {
    // Validation
    if (email.isEmpty) {
      _setError('Email Required!');
      return false;
    }
    if (password.isEmpty) {
      _setError('Password Required!');
      return false;
    }

    _setLoading(true);
    clearError();

    try {
      final response = await ApiService.login(email: email, password: password);

      if (response.success && response.data != null) {
        _currentUser = response.data!;

        // Save user data to local storage
        await WriteUserData({
          'token': response.token,
          'data': response.data!.toJson(),
        });

        _showSuccess('Login Successful!');
        _setLoading(false);
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Login Failed! Error: $e');
      _setLoading(false);
      return false;
    }
  }

  // ==================== Registration ====================

  /// Register new user
  Future<bool> register({
    required String email,
    required String firstName,
    required String lastName,
    required String mobile,
    required String password,
    required String confirmPassword,
    String photo = '',
  }) async {
    // Validation
    if (email.isEmpty) {
      _setError('Email Required!');
      return false;
    }
    if (firstName.isEmpty) {
      _setError('First Name Required!');
      return false;
    }
    if (lastName.isEmpty) {
      _setError('Last Name Required!');
      return false;
    }
    if (mobile.isEmpty) {
      _setError('Mobile No Required!');
      return false;
    }
    if (password.isEmpty) {
      _setError('Password Required!');
      return false;
    }
    if (password != confirmPassword) {
      _setError('Confirm password should be same!');
      return false;
    }

    _setLoading(true);
    clearError();

    try {
      final response = await ApiService.register(
        email: email,
        firstName: firstName,
        lastName: lastName,
        mobile: mobile,
        password: password,
        photo: photo,
      );

      if (response.success) {
        _showSuccess('Registration Successful!');
        _setLoading(false);
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Registration Failed! Error: $e');
      _setLoading(false);
      return false;
    }
  }

  // ==================== Email Verification ====================

  /// Verify email for password recovery
  Future<bool> verifyEmail({required String email}) async {
    // Validation
    if (email.isEmpty) {
      _setError('Email Required!');
      return false;
    }

    _setLoading(true);
    clearError();

    try {
      final response = await ApiService.recoverVerifyEmail(email: email);

      if (response.success) {
        _recoveryEmail = email;
        await WriteEmailVerification(email);
        _showSuccess('OTP sent to your email!');
        _setLoading(false);
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Email verification failed! Error: $e');
      _setLoading(false);
      return false;
    }
  }

  // ==================== OTP Verification ====================

  /// Verify OTP
  Future<bool> verifyOtp({required String otp}) async {
    // Validation
    if (otp.length != 6) {
      _setError('PIN Required!');
      return false;
    }

    _setLoading(true);
    clearError();

    try {
      // Get email from local storage if not set
      String? email = _recoveryEmail ?? await ReadUserData('EmailVerification');

      if (email == null || email.isEmpty) {
        _setError('Email not found. Please start over.');
        _setLoading(false);
        return false;
      }

      final response = await ApiService.recoverVerifyOtp(
        email: email,
        otp: otp,
      );

      if (response.success) {
        _recoveryOtp = otp;
        await WriteOTPVerification(otp);
        _showSuccess('OTP verified successfully!');
        _setLoading(false);
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('OTP verification failed!');
      _setLoading(false);
      return false;
    }
  }

  // ==================== Reset Password ====================

  /// Reset password
  Future<bool> resetPassword({
    required String password,
    required String confirmPassword,
  }) async {
    // Validation
    if (password.isEmpty) {
      _setError('Password Required!');
      return false;
    }
    if (password != confirmPassword) {
      _setError('Confirm password should be same!');
      return false;
    }

    _setLoading(true);
    clearError();

    try {
      // Get email and OTP from local storage if not set
      String? email = _recoveryEmail ?? await ReadUserData('EmailVerification');
      String? otp = _recoveryOtp ?? await ReadUserData('OTPVerification');

      if (email == null || email.isEmpty) {
        _setError('Email not found. Please start over.');
        _setLoading(false);
        return false;
      }

      if (otp == null || otp.isEmpty) {
        _setError('OTP not found. Please verify OTP first.');
        _setLoading(false);
        return false;
      }

      final response = await ApiService.recoverResetPassword(
        email: email,
        otp: otp,
        password: password,
      );

      if (response.success) {
        // Clear recovery data
        _recoveryEmail = null;
        _recoveryOtp = null;
        _showSuccess('Password reset successfully!');
        _setLoading(false);
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Password reset failed!');
      _setLoading(false);
      return false;
    }
  }

  // ==================== Session Management ====================

  /// Logout user
  Future<bool> logout() async {
    try {
      await RemoveToken();
      _currentUser = null;
      _recoveryEmail = null;
      _recoveryOtp = null;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    String? token = await ReadUserData('token');
    return token != null && token.isNotEmpty;
  }

  /// Load current user from local storage
  Future<void> loadCurrentUser() async {
    try {
      String? email = await ReadUserData('email');
      String? firstName = await ReadUserData('firstName');
      String? lastName = await ReadUserData('lastName');
      String? mobile = await ReadUserData('mobile');
      String? photo = await ReadUserData('photo');

      if (email != null) {
        _currentUser = UserModel(
          email: email,
          firstName: firstName ?? '',
          lastName: lastName ?? '',
          mobile: mobile ?? '',
          photo: photo ?? '',
        );
        notifyListeners();
      }
    } catch (e) {
      // Handle error silently
    }
  }
}
