## Flutter MVC Authentication Module

This project follows a clean MVC (Model–View–Controller) architecture for implementing authentication flows in Flutter. The structure ensures scalability, maintainability, and clear separation of concerns.

### 🏗 Project Architecture

The application is organized into three main layers:

```
lib/
├── models/
├── services/
├── controllers/
└── views/
```

### 📦 Models (models/)

Data models handle typed data structures and serialization.

### Included Models

> `user_model.dart`

- Represents user data
- Includes fromJson() and toJson() methods

> `api_response.dart`

- Generic API response wrapper

- Handles success, message, and data payload

> `login_response.dart`

- Login-specific response model

- Contains authentication token and user object

### 🔌 Services (services/)

Services are responsible for all API communication.

`api_service.dart`

A centralized API service that manages HTTP requests.

Base URL

```
http://localhost:5000/api/v1
```

_(Configured according to Postman documentation)_

### Available Methods

- login()

- register()

- updateProfile()

- recoverVerifyEmail()

- recoverVerifyOtp()

- recoverResetPassword()

### 🧠 Controllers (`controllers/`)

Controllers contain business logic, validation, and state management.

`auth_controller.dart`

Handles all authentication-related operations:

#### Features

- login()

- register()

- logout()

- verifyEmail()

- verifyOtp()

- resetPassword()

- Loading state management

- Input validation logic

### 🎨 Views (views/)

UI screens follow the controller-driven pattern (no direct API calls).

Authentication Screens

- loginScreen.dart

- registrationScreen.dart

- emailVerificationScreen.dart

- pinVerificationScreen.dart

- setPasswordScreen.dart

## Each screen communicates only with its controller, ensuring a clean UI layer.

### 🚀 Key Improvements

> ✅ Separation of Concerns

- Models → Data

- Services → API calls

- Controllers → Business logic

- Views → UI

> ✅ Typed Models

Replaced Map<String, dynamic> with strongly typed models

> ✅ Improved Form Handling

Used TextEditingController instead of onChanged

> ✅ Proper Lifecycle Management

Controllers correctly add and remove listeners
