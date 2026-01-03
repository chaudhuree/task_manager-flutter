import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../style/style.dart';
import '../utility/utility.dart';

class TaskPresenter extends ChangeNotifier {
  // State
  bool _isLoading = false;
  String? _errorMessage;
  // List<TaskModel>? _tasks;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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

  // ==================== Task Management ====================

  /// Create task
  Future<bool> createTask({
    required String title,
    required String description,
    String status = 'New',
  }) async {
    // Validation
    if (title.isEmpty) {
      _setError('Title Required!');
      return false;
    }
    if (description.isEmpty) {
      _setError('Description Required!');
      return false;
    }

    _setLoading(true);
    clearError();
    String? token = await ReadUserData('token');
    try {
      final response = await ApiService.createTask(
        title: title,
        description: description,
        status: status,
        token: token!,
      );
      if (response.success) {
        _showSuccess('Task created successfully!');
        _setLoading(false);
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Task creation failed! Error: $e');
      _setLoading(false);
      return false;
    }
  }
}
