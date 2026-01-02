# MVP Architecture Documentation (Simplified)

## Overview

This document explains the **simplified MVP (Model-View-Presenter)** architecture used in the Task Manager Flutter application. This is a straightforward implementation that uses only three layers: **Model**, **View**, and **Presenter** - without abstract contracts or interfaces.

## What is MVP?

MVP is an architectural pattern that separates concerns into three layers:

1. **Model**: Data structures and business entities
2. **View**: UI layer that displays data and captures user input
3. **Presenter**: Business logic layer that mediates between Model and View

## Key Principles

- **Separation of Concerns**: Each layer has a specific responsibility
- **Direct Communication**: View and Presenter communicate directly using ChangeNotifier
- **Simple State Management**: Presenter extends ChangeNotifier to notify Views of state changes
- **No Abstractions**: No contracts or interfaces - just concrete classes

---

## Architecture Layers

### 1. Model Layer (`lib/models/`)

**Purpose**: Define data structures and entities

**Responsibilities**:

- Define data classes (e.g., `UserModel`, `TaskModel`)
- Handle JSON serialization/deserialization
- Provide typed data structures

**Example**:

```dart
class UserModel {
  final String email;
  final String firstName;
  final String lastName;
  final String mobile;
  final String? photo;

  UserModel({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.mobile,
    this.photo,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      mobile: json['mobile'],
      photo: json['photo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'mobile': mobile,
      'photo': photo,
    };
  }
}
```

---

### 2. Service Layer (`lib/services/`)

**Purpose**: Handle external communication (API calls, database, etc.)

**Responsibilities**:

- Make HTTP requests to backend APIs
- Handle API responses and errors
- Return data or throw exceptions

**Example**:

```dart
class ApiService {
  final String baseUrl = 'http://10.0.2.2:5000/api/v1';

  Future<ApiResponse> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      return ApiResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
```

---

### 3. Presenter Layer (`lib/presenters/`)

**Purpose**: Handle business logic and state management

**Responsibilities**:

- Validate user input
- Call service methods
- Manage UI state (loading, errors, data)
- Notify Views of state changes via `notifyListeners()`
- Show toast messages for errors/success

**Key Features**:

- Extends `ChangeNotifier` for state management
- Returns `bool` from methods to indicate success/failure
- Handles all validation and business logic
- Shows ErrorToast/SuccessToast directly

**Example**:

```dart
class AuthPresenter extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;

  Future<bool> login({required String email, required String password}) async {
    // Validate input
    if (email.isEmpty) {
      ErrorToast('Email is required');
      return false;
    }

    // Set loading state
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Call service
      final response = await _apiService.login(email, password);

      if (response.status == 'success') {
        _currentUser = response.data;
        await _saveToken(response.token);
        SuccessToast('Login successful!');
        return true;
      } else {
        ErrorToast(response.message ?? 'Login failed');
        return false;
      }
    } catch (e) {
      ErrorToast('An error occurred: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

---

### 4. View Layer (`lib/views/`)

**Purpose**: Display UI and handle user interactions

**Responsibilities**:

- Render UI components
- Capture user input
- Listen to Presenter state changes
- Navigate on success
- React to state changes (loading, errors, data)

**Key Features**:

- Creates Presenter instance
- Adds listener in `initState()`
- Calls `presenter.dispose()` in `dispose()`
- Checks return value for navigation
- Uses `presenter.isLoading` for loading state

**Example**:

```dart
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthPresenter _presenter = AuthPresenter();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Listen to presenter state changes
    _presenter.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _presenter.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _formOnSubmit() async {
    bool success = await _presenter.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (success && mounted) {
      Navigator.pushNamedAndRemoveUntil(context, "/taskList", (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _presenter.isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TextField(controller: _emailController),
                TextField(controller: _passwordController),
                ElevatedButton(
                  onPressed: _formOnSubmit,
                  child: Text('Login'),
                ),
              ],
            ),
    );
  }
}
```

---

## Communication Flow

### Login Example Flow:

```
1. User Action: User taps "Login" button in View
2. View → Presenter: View calls _presenter.login(email, password)
3. Presenter Validates: Checks if inputs are valid
4. Presenter → Service: Calls _apiService.login(email, password)
5. Service → API: Makes HTTP request to backend
6. API → Service: Returns response
7. Service → Presenter: Returns parsed data
8. Presenter Updates State: Updates _isLoading, _currentUser, etc.
9. Presenter Notifies: Calls notifyListeners()
10. View Rebuilds: setState() is triggered by listener
11. View Navigation: If success, navigates to next screen
```

---

## State Management Pattern

The simplified MVP uses **ChangeNotifier** for state management:

```dart
// Presenter extends ChangeNotifier
class AuthPresenter extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners(); // Notifies all listeners
  }
}

// View listens to changes
class _LoginScreenState extends State<LoginScreen> {
  final AuthPresenter _presenter = AuthPresenter();

  @override
  void initState() {
    super.initState();
    _presenter.addListener(() {
      if (mounted) setState(() {}); // Rebuild when notified
    });
  }
}
```

---

## Benefits of This Architecture

1. ✅ **Simple to Understand**: No abstract interfaces, just concrete classes
2. ✅ **Clear Separation**: Business logic in Presenter, UI in View
3. ✅ **Easy Testing**: Presenters can be tested without UI
4. ✅ **Maintainable**: Each layer has a clear responsibility
5. ✅ **Scalable**: Easy to add new features
6. ✅ **Type Safe**: All data is strongly typed via Models

---

## File Organization

```
lib/
├── models/              # Data models
│   ├── user_model.dart
│   ├── task_model.dart
│   ├── login_response.dart
│   └── api_response.dart
├── services/            # API services
│   └── api_service.dart
├── presenters/          # Business logic
│   ├── auth_presenter.dart
│   └── task_presenter.dart
├── views/               # Views/UI
│   ├── onboarding/
│   │   ├── splashScreen.dart
│   │   ├── loginScreen.dart
│   │   ├── registrationScreen.dart
│   │   ├── emailVerificationScreen.dart
│   │   ├── pinVerificationScreen.dart
│   │   └── setPasswordScreen.dart
│   ├── profile/
│   │   └── profileUpdateScreen.dart
│   └── task/
│       ├── newTaskListScreen.dart
│       ├── taskCreateScreen.dart
│       ├── progressTaskListScreen.dart
│       ├── copletedTaskListScreen.dart
│       └── cancelTaskListScreen.dart
├── style/               # Styling utilities
├── utility/             # Utility functions
├── api/                 # API utilities
└── main.dart            # App entry point
```

---

## Common Patterns

### Error Handling

```dart
try {
  final response = await _apiService.login(email, password);
  if (response.status == 'success') {
    SuccessToast('Login successful!');
    return true;
  } else {
    ErrorToast(response.message ?? 'Login failed');
    return false;
  }
} catch (e) {
  ErrorToast('An error occurred: $e');
  return false;
}
```

### Loading State

```dart
_isLoading = true;
notifyListeners();

try {
  // Do work
} finally {
  _isLoading = false;
  notifyListeners();
}
```

### Input Validation

```dart
if (email.isEmpty) {
  ErrorToast('Email is required');
  return false;
}

if (password.length < 6) {
  ErrorToast('Password must be at least 6 characters');
  return false;
}
```

---

## Best Practices

1. ✅ **Always use try-catch** in Presenter methods
2. ✅ **Always set loading state** before async operations
3. ✅ **Always call notifyListeners()** after state changes
4. ✅ **Check mounted** before navigation in Views
5. ✅ **Dispose presenters** in View's dispose method
6. ✅ **Return bool** from Presenter methods to indicate success/failure
7. ✅ **Show toast messages** in Presenter for user feedback
8. ✅ **Validate all input** in Presenter before calling services

---

## Comparison: Before vs After

### Before (Without MVP)

```dart
// All logic mixed in View
class _LoginScreenState extends State<LoginScreen> {
  Future<void> login() async {
    // Validation in View
    if (email.isEmpty) return;

    // API call in View
    var response = await http.post(...);

    // Parsing in View
    var data = jsonDecode(response.body);

    // Navigation in View
    Navigator.push(...);
  }
}
```

### After (With Simplified MVP)

```dart
// Presenter handles all logic
class AuthPresenter extends ChangeNotifier {
  Future<bool> login({required String email, required String password}) async {
    if (email.isEmpty) {
      ErrorToast('Email required');
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.login(email, password);
      return response.status == 'success';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// View only handles UI
class _LoginScreenState extends State<LoginScreen> {
  Future<void> _formOnSubmit() async {
    bool success = await _presenter.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (success && mounted) {
      Navigator.pushNamed(context, '/home');
    }
  }
}
```

---

## Example: Complete Auth Flow

See the files in `lib/views/onboarding/` for complete examples:

- **loginScreen.dart** - Login with email/password
- **registrationScreen.dart** - User registration
- **emailVerificationScreen.dart** - Email verification for password reset
- **pinVerificationScreen.dart** - OTP verification
- **setPasswordScreen.dart** - Set new password

Each screen demonstrates the simplified MVP pattern in action.

---

## Summary

The **simplified MVP architecture** provides:

- **Model**: Data structures with JSON serialization
- **Service**: API communication layer
- **Presenter**: Business logic + state management (extends ChangeNotifier)
- **View**: UI components that listen to Presenter changes

This approach is:

- ✅ Easy to understand
- ✅ Simple to implement
- ✅ Maintainable and scalable
- ✅ Perfect for learning MVP concepts
- ✅ No unnecessary abstractions

Start with the auth flow examples in `lib/views/onboarding/` and use the same pattern for other features!
