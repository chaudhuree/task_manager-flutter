import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:task_manager/models/task_model.dart';

import '../models/api_response.dart';
import '../models/user_model.dart';

class ApiService {
  // Base URL - Use 10.0.2.2 for Android emulator, localhost for iOS simulator/web
  // 10.0.2.2 is the special alias to your host loopback interface (localhost) on Android emulator
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5000/api/v1';
    } else {
      return 'http://localhost:5000/api/v1';
    }
  }

  static final Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
  };

  static Map<String, String> _getAuthHeaders(String token) {
    return {'Content-Type': 'application/json', 'token': token};
  }

  // ==================== User Management ====================

  /// Login user
  /// POST /login
  /// Body: { email, password }
  static Future<ApiResponse<UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/login');
      final body = json.encode({'email': email, 'password': password});

      final response = await http.post(
        url,
        headers: _defaultHeaders,
        body: body,
      );

      final resultBody = json.decode(response.body);

      if (response.statusCode == 200 && resultBody['status'] == 'success') {
        return ApiResponse(
          success: true,
          message: resultBody['message'] ?? 'Login successful',
          data: UserModel.fromJson(resultBody['data']),
          token: resultBody['token'],
        );
      } else {
        return ApiResponse.error(resultBody['message'] ?? 'Login failed');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Register user
  /// POST /registration
  /// Body: { email, firstName, lastName, mobile, password, photo }
  static Future<ApiResponse<UserModel>> register({
    required String email,
    required String firstName,
    required String lastName,
    required String mobile,
    required String password,
    String photo = '',
  }) async {
    try {
      final url = Uri.parse('$baseUrl/registration');
      final body = json.encode({
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'mobile': mobile,
        'password': password,
        'photo': photo,
      });

      final response = await http.post(
        url,
        headers: _defaultHeaders,
        body: body,
      );

      final resultBody = json.decode(response.body);

      if ((response.statusCode == 201) && resultBody['status'] == 'success') {
        return ApiResponse(
          success: true,
          message: resultBody['message'] ?? 'Registration successful',
          data: resultBody['data'] != null
              ? UserModel.fromJson(resultBody['data'])
              : null,
        );
      } else {
        return ApiResponse.error(
          resultBody['message'] ?? 'Registration failed',
        );
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Update profile
  /// POST /profileUpdate
  /// Headers: { token }
  /// Body: { firstName, lastName, mobile, password, photo }
  static Future<ApiResponse<UserModel>> updateProfile({
    required String token,
    required String firstName,
    required String lastName,
    required String mobile,
    String? password,
    String photo = '',
  }) async {
    try {
      final url = Uri.parse('$baseUrl/profileUpdate');
      final bodyMap = {
        'firstName': firstName,
        'lastName': lastName,
        'mobile': mobile,
        'photo': photo,
      };

      if (password != null && password.isNotEmpty) {
        bodyMap['password'] = password;
      }

      final body = json.encode(bodyMap);

      final response = await http.post(
        url,
        headers: _getAuthHeaders(token),
        body: body,
      );

      final resultBody = json.decode(response.body);

      if (response.statusCode == 200 && resultBody['status'] == 'success') {
        return ApiResponse(
          success: true,
          message: resultBody['message'] ?? 'Profile updated successfully',
          data: resultBody['data'] != null
              ? UserModel.fromJson(resultBody['data'])
              : null,
        );
      } else {
        return ApiResponse.error(
          resultBody['message'] ?? 'Profile update failed',
        );
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // ==================== Password Recovery ====================

  /// Verify email for password recovery (sends OTP)
  /// GET /RecoverVerifyEmail/:email
  static Future<ApiResponse<void>> recoverVerifyEmail({
    required String email,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/RecoverVerifyEmail/$email');

      final response = await http.get(url, headers: _defaultHeaders);
      final resultBody = json.decode(response.body);

      if (response.statusCode == 200 && resultBody['status'] == 'success') {
        return ApiResponse(
          success: true,
          message: resultBody['message'] ?? 'OTP sent to your email',
        );
      } else {
        return ApiResponse.error(
          resultBody['message'] ?? 'Email verification failed',
        );
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Verify OTP
  /// GET /RecoverVerifyOTP/:email/:otp
  static Future<ApiResponse<void>> recoverVerifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/RecoverVerifyOTP/$email/$otp');

      final response = await http.get(url, headers: _defaultHeaders);
      final resultBody = json.decode(response.body);

      if (response.statusCode == 200 && resultBody['status'] == 'success') {
        return ApiResponse(
          success: true,
          message: resultBody['message'] ?? 'OTP verified successfully',
        );
      } else {
        return ApiResponse.error(
          resultBody['message'] ?? 'OTP verification failed',
        );
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  /// Reset password
  /// POST /RecoverResetPass
  /// Body: { email, OTP, password }
  static Future<ApiResponse<void>> recoverResetPassword({
    required String email,
    required String otp,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/RecoverResetPass');
      final body = json.encode({
        'email': email,
        'OTP': otp,
        'password': password,
      });

      final response = await http.post(
        url,
        headers: _defaultHeaders,
        body: body,
      );

      final resultBody = json.decode(response.body);

      if (response.statusCode == 200 && resultBody['status'] == 'success') {
        return ApiResponse(
          success: true,
          message: resultBody['message'] ?? 'Password reset successfully',
        );
      } else {
        return ApiResponse.error(
          resultBody['message'] ?? 'Password reset failed',
        );
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // ==================== Task Management ====================

  /// Create task
  /// POST /task
  /// Body: { title, description, status }
  static Future<ApiResponse<TaskModel>> createTask({
    required String title,
    required String description,
    String status = 'New',
    required String token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/createTask');
      final body = json.encode({
        'title': title,
        'description': description,
        'status': status,
      });

      final response = await http.post(
        url,
        headers: _getAuthHeaders(token),
        body: body,
      );

      final resultBody = json.decode(response.body);

      if (response.statusCode == 201 && resultBody['status'] == 'success') {
        return ApiResponse(
          success: true,
          message: resultBody['message'] ?? 'Task created successfully',
          data: TaskModel.fromJson(resultBody['data']),
        );
      } else {
        return ApiResponse.error(
          resultBody['message'] ?? 'Task creation failed',
        );
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // list of all tasks by status
  // GET /listTaskByStatus/:status
  // status could be: 'New', 'Progress', 'Completed', 'Cancelled'
  Future<ApiResponse<List<TaskModel>>> listTaskByStatus(
    String status,
    String token,
  ) async {
    // Validation
    if (status.isEmpty) {
      return ApiResponse.error('Status is required');
    }
    if (token.isEmpty) {
      return ApiResponse.error('You are not authorized to perform this action');
    }
    const statusOptions = ['New', 'Progress', 'Completed', 'Cancelled'];
    if (!statusOptions.contains(status)) {
      return ApiResponse.error('Invalid status');
    }
    // Make API call
    try {
      final url = Uri.parse('$baseUrl/listTaskByStatus/$status');
      final response = await http.get(url, headers: _getAuthHeaders(token));

      final resultBody = json.decode(response.body);

      if (response.statusCode == 200 && resultBody['status'] == 'success') {
        return ApiResponse(
          success: true,
          message: resultBody['message'] ?? 'Task list fetched successfully',
          data: resultBody['data'] != null
              ? (resultBody['data'] as List)
                    .map((taskJson) => TaskModel.fromJson(taskJson))
                    .toList()
              : [],
        );
      } else {
        return ApiResponse.error(
          resultBody['message'] ?? 'Task list fetched failed',
        );
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Delete task by id
  // GET /deleteTask/:id
  Future<ApiResponse<void>> deleteTask(String id, String token) async {
    // Validation
    if (id.isEmpty) {
      return ApiResponse.error('Task ID is required');
    }
    if (token.isEmpty) {
      return ApiResponse.error('You are not authorized to perform this action');
    }

    // Make API call
    try {
      final url = Uri.parse('$baseUrl/deleteTask/$id');
      final response = await http.delete(url, headers: _getAuthHeaders(token));
      final resultBody = json.decode(response.body);

      if (response.statusCode == 200 && resultBody['status'] == 'success') {
        return ApiResponse(
          success: true,
          message: resultBody['message'] ?? 'Task deleted successfully',
        );
      } else {
        return ApiResponse.error(
          resultBody['message'] ?? 'Task deletion failed',
        );
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Update task status
  // POST /updateTaskStatus/:id/:status
  Future<ApiResponse<TaskModel>> updateTaskStatus(
    String id,
    String status,
    String token,
  ) async {
    // Validation
    if (id.isEmpty) {
      return ApiResponse.error('Task ID is required');
    }
    if (status.isEmpty) {
      return ApiResponse.error('Status is required');
    }
    if (token.isEmpty) {
      return ApiResponse.error('You are not authorized to perform this action');
    }
    const statusOptions = ['New', 'Progress', 'Completed', 'Cancelled'];
    if (!statusOptions.contains(status)) {
      return ApiResponse.error('Invalid status');
    }
    // Make API call
    try {
      final url = Uri.parse('$baseUrl/updateTaskStatus/$id/$status');
      final response = await http.patch(url, headers: _getAuthHeaders(token));
      final resultBody = json.decode(response.body);

      if (response.statusCode == 200 && resultBody['status'] == 'success') {
        return ApiResponse(
          success: true,
          message: resultBody['message'] ?? 'Task status updated successfully',
          data: TaskModel.fromJson(resultBody['data']),
        );
      } else {
        return ApiResponse.error(
          resultBody['message'] ?? 'Task status update failed',
        );
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
}
