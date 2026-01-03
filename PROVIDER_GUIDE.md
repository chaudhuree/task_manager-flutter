# Provider State Management - Comprehensive Guide

## Table of Contents

1. [What is Provider?](#what-is-provider)
2. [How Provider Works](#how-provider-works)
3. [Core Concepts](#core-concepts)
4. [Provider Usage Patterns](#provider-usage-patterns)
5. [Provider in This Project](#provider-in-this-project)
6. [Adding New Providers](#adding-new-providers)
7. [Best Practices](#best-practices)
8. [Common Patterns](#common-patterns)

---

## What is Provider?

**Provider** is a wrapper around `InheritedWidget` to make state management in Flutter easier and more efficient. It's the officially recommended state management solution by the Flutter team.

### Key Benefits:

✅ **Simple** - Easy to learn and implement  
✅ **Efficient** - Only rebuilds widgets that need updates  
✅ **Scalable** - Works for small to large apps  
✅ **Testable** - Easy to test business logic separately  
✅ **Type-safe** - Compile-time errors instead of runtime  
✅ **No boilerplate** - Less code than other solutions

---

## How Provider Works

### The Problem Provider Solves

**Without Provider:**

```dart
// Parent widget
class ParentWidget extends StatefulWidget {
  @override
  _ParentWidgetState createState() => _ParentWidgetState();
}

class _ParentWidgetState extends State<ParentWidget> {
  int counter = 0;

  void increment() {
    setState(() => counter++);
  }

  @override
  Widget build(BuildContext context) {
    return ChildWidget(
      counter: counter,
      onIncrement: increment,
    );
  }
}

// Child widget (needs to pass data down)
class ChildWidget extends StatelessWidget {
  final int counter;
  final VoidCallback onIncrement;

  ChildWidget({required this.counter, required this.onIncrement});

  @override
  Widget build(BuildContext context) {
    return GrandchildWidget(
      counter: counter,
      onIncrement: onIncrement,
    );
  }
}

// Grandchild widget (prop drilling problem!)
class GrandchildWidget extends StatelessWidget {
  final int counter;
  final VoidCallback onIncrement;

  GrandchildWidget({required this.counter, required this.onIncrement});

  @override
  Widget build(BuildContext context) {
    return Text('Count: $counter');
  }
}
```

**With Provider:**

```dart
// State class
class Counter extends ChangeNotifier {
  int _value = 0;

  int get value => _value;

  void increment() {
    _value++;
    notifyListeners(); // Tells listeners to rebuild
  }
}

// Provide at top level
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => Counter(),
      child: MyApp(),
    ),
  );
}

// Access anywhere in the tree
class GrandchildWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // No prop drilling needed!
    final counter = context.watch<Counter>();
    return Text('Count: ${counter.value}');
  }
}
```

### How It Works Internally

```
┌─────────────────────────────────────┐
│  ChangeNotifierProvider<Counter>    │ ← Provides Counter instance
│  (at top of widget tree)            │
└────────────┬────────────────────────┘
             │
             │ Counter instance lives here
             │
    ┌────────┴────────┐
    │                 │
┌───▼────┐      ┌────▼─────┐
│ Widget │      │  Widget  │
│   A    │      │    B     │
└───┬────┘      └────┬─────┘
    │                │
    │                │
┌───▼────┐      ┌────▼─────┐
│Consumer│      │Consumer  │ ← Both listen to same Counter
│(listens)│     │(listens) │
└────────┘      └──────────┘

When Counter calls notifyListeners():
→ Only Consumers rebuild
→ Widget A and B don't rebuild
```

---

## Core Concepts

### 1. ChangeNotifier

A class that provides change notification to listeners.

```dart
class UserProfile extends ChangeNotifier {
  String _name = 'John Doe';
  int _age = 25;

  // Getters
  String get name => _name;
  int get age => _age;

  // Methods that change state
  void updateName(String newName) {
    _name = newName;
    notifyListeners(); // ← Critical! Notifies all listeners
  }

  void updateAge(int newAge) {
    _age = newAge;
    notifyListeners();
  }

  // Async operations
  Future<void> loadProfile() async {
    // Show loading state
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch data
      final data = await api.getProfile();
      _name = data.name;
      _age = data.age;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

### 2. ChangeNotifierProvider

Provides a ChangeNotifier to the widget tree.

```dart
// Single provider
ChangeNotifierProvider(
  create: (context) => UserProfile(),
  child: MyApp(),
)

// Multiple providers
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => UserProfile()),
    ChangeNotifierProvider(create: (_) => ShoppingCart()),
    ChangeNotifierProvider(create: (_) => AuthService()),
  ],
  child: MyApp(),
)
```

### 3. Consumer

Rebuilds when the provider notifies listeners.

```dart
Consumer<UserProfile>(
  builder: (context, userProfile, child) {
    // This rebuilds when userProfile.notifyListeners() is called
    return Text('Name: ${userProfile.name}');
  },
)

// Multiple consumers
Consumer2<UserProfile, ShoppingCart>(
  builder: (context, userProfile, cart, child) {
    return Text('${userProfile.name} has ${cart.itemCount} items');
  },
)
```

### 4. Provider.of

Access provider without rebuilding.

```dart
// listen: true (default) - Rebuilds when notified
final userProfile = Provider.of<UserProfile>(context);

// listen: false - Doesn't rebuild (use for callbacks)
final userProfile = Provider.of<UserProfile>(context, listen: false);
```

### 5. context.watch / context.read

Shorter syntax for Provider.of.

```dart
// context.watch (listen: true) - Rebuilds
final userProfile = context.watch<UserProfile>();

// context.read (listen: false) - Doesn't rebuild
final userProfile = context.read<UserProfile>();

// Usage in button
ElevatedButton(
  onPressed: () {
    // Use read in callbacks to avoid unnecessary rebuilds
    context.read<UserProfile>().updateName('Jane Doe');
  },
  child: Text('Update'),
)
```

---

## Provider Usage Patterns

### Pattern 1: Simple State

```dart
// State class
class CounterState extends ChangeNotifier {
  int _count = 0;

  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }
}

// Provide
ChangeNotifierProvider(
  create: (_) => CounterState(),
  child: MyApp(),
)

// Consume
Widget build(BuildContext context) {
  return Column(
    children: [
      // Watch for changes
      Text('Count: ${context.watch<CounterState>().count}'),

      // Don't watch in callbacks
      ElevatedButton(
        onPressed: () => context.read<CounterState>().increment(),
        child: Text('Increment'),
      ),
    ],
  );
}
```

### Pattern 2: Loading State

```dart
class DataState extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<Item> _items = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Item> get items => _items;

  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await api.fetchItems();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// UI
Consumer<DataState>(
  builder: (context, state, child) {
    if (state.isLoading) {
      return CircularProgressIndicator();
    }

    if (state.error != null) {
      return Text('Error: ${state.error}');
    }

    return ListView.builder(
      itemCount: state.items.length,
      itemBuilder: (context, index) => Text(state.items[index].name),
    );
  },
)
```

### Pattern 3: Form Handling

```dart
class LoginState extends ChangeNotifier {
  String _email = '';
  String _password = '';
  bool _isLoading = false;

  String get email => _email;
  String get password => _password;
  bool get isLoading => _isLoading;
  bool get canSubmit => _email.isNotEmpty && _password.length >= 6;

  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  Future<bool> login() async {
    _isLoading = true;
    notifyListeners();

    try {
      await authService.login(_email, _password);
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// UI
Consumer<LoginState>(
  builder: (context, state, child) {
    return Column(
      children: [
        TextField(
          onChanged: state.setEmail,
          decoration: InputDecoration(labelText: 'Email'),
        ),
        TextField(
          onChanged: state.setPassword,
          decoration: InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
        ElevatedButton(
          onPressed: state.canSubmit && !state.isLoading
              ? () async {
                  final success = await state.login();
                  if (success) Navigator.pushNamed(context, '/home');
                }
              : null,
          child: state.isLoading
              ? CircularProgressIndicator()
              : Text('Login'),
        ),
      ],
    );
  },
)
```

### Pattern 4: Selective Rebuilds

```dart
// Only rebuild specific parts
Widget build(BuildContext context) {
  return Column(
    children: [
      // This rebuilds when counter changes
      Consumer<CounterState>(
        builder: (context, counter, child) {
          return Text('Count: ${counter.count}');
        },
      ),

      // This never rebuilds (static content)
      child: ExpensiveWidget(), // Passed as child to Consumer

      // This rebuilds when user changes
      Consumer<UserState>(
        builder: (context, user, child) {
          return Text('User: ${user.name}');
        },
      ),
    ],
  );
}
```

---

## Provider in This Project

### Current Setup

#### 1. **Dependencies** (`pubspec.yaml`)

```yaml
dependencies:
  provider: ^6.1.1
```

#### 2. **Main.dart Setup**

```dart
import 'package:provider/provider.dart';
import 'package:task_manager/presenters/auth_presenter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? token = await ReadUserData("token");

  runApp(MyApp(
    initialRoute: token == null ? "/login" : "/taskList",
  ));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth provider (available globally)
        ChangeNotifierProvider(create: (_) => AuthPresenter()),

        // Add more providers here
        // ChangeNotifierProvider(create: (_) => TaskPresenter()),
        // ChangeNotifierProvider(create: (_) => ProfilePresenter()),
      ],
      child: MaterialApp(
        title: 'Task Manager',
        initialRoute: initialRoute,
        routes: {
          '/login': (context) => const LoginScreen(),
          '/registration': (context) => const RegistrationScreen(),
          // ... other routes
        },
      ),
    );
  }
}
```

#### 3. **AuthPresenter** (The Provider)

```dart
class AuthPresenter extends ChangeNotifier {
  final ApiService _apiService = ApiService();

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

  // Methods
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty) {
      ErrorToast('Email is required');
      return false;
    }

    if (password.isEmpty) {
      ErrorToast('Password is required');
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // ← Notify UI to show loading

    try {
      final response = await _apiService.login(email, password);

      if (response.status == 'success' && response.data != null) {
        await WriteUserData(response.data!);
        _currentUser = UserModel.fromJson(response.data!['data']);
        SuccessToast('Login successful!');
        return true;
      } else {
        ErrorToast(response.message ?? 'Login failed');
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      ErrorToast('An error occurred: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners(); // ← Notify UI to hide loading
    }
  }

  // Other methods: register, verifyEmail, verifyOtp, resetPassword, logout
}
```

#### 4. **View Usage** (LoginScreen)

```dart
import 'package:provider/provider.dart';
import 'package:task_manager/presenters/auth_presenter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _formOnSubmit() async {
    // Access presenter without listening (for actions)
    final presenter = Provider.of<AuthPresenter>(context, listen: false);

    bool success = await presenter.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (success && mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        "/taskList",
        (route) => false,
      );
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
            // Consumer rebuilds only when AuthPresenter notifies
            child: Consumer<AuthPresenter>(
              builder: (context, presenter, child) {
                return presenter.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: EdgeInsets.all(30),
                        child: Column(
                          children: [
                            Text("Get Started With", style: Head1Text(colorDarkBlue)),
                            SizedBox(height: 20),
                            TextFormField(
                              controller: _emailController,
                              decoration: AppInputDecoration("Email Address"),
                            ),
                            SizedBox(height: 20),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: AppInputDecoration("Password"),
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              style: AppButtonStyle(),
                              onPressed: _formOnSubmit,
                              child: SuccessButtonChild("Login"),
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
```

### Key Points in Current Implementation:

1. **Global Provider**: `AuthPresenter` is provided at the app level in `main.dart`
2. **Single Instance**: All screens share the same `AuthPresenter` instance
3. **Consumer for UI**: Uses `Consumer<AuthPresenter>` to rebuild UI when loading state changes
4. **Provider.of for Actions**: Uses `Provider.of<AuthPresenter>(context, listen: false)` in callbacks
5. **No Manual Disposal**: Provider handles disposal automatically
6. **Efficient Rebuilds**: Only the `Consumer` widget rebuilds, not the entire screen

---

## Adding New Providers

### Step 1: Create the Presenter/Provider Class

```dart
// lib/presenters/task_presenter.dart
import 'package:flutter/foundation.dart';
import 'package:task_manager/models/task_model.dart';
import 'package:task_manager/services/api_service.dart';

class TaskPresenter extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // State
  bool _isLoading = false;
  List<TaskModel> _tasks = [];
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  List<TaskModel> get tasks => _tasks;
  String? get errorMessage => _errorMessage;
  int get taskCount => _tasks.length;

  // Filter tasks by status
  List<TaskModel> getTasksByStatus(String status) {
    return _tasks.where((task) => task.status == status).toList();
  }

  // Load tasks
  Future<void> loadTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.getTasks();
      if (response.status == 'success') {
        _tasks = (response.data as List)
            .map((json) => TaskModel.fromJson(json))
            .toList();
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create task
  Future<bool> createTask({
    required String title,
    required String description,
    String status = 'New',
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.createTask(
        title: title,
        description: description,
        status: status,
      );

      if (response.status == 'success') {
        await loadTasks(); // Reload tasks
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update task
  Future<bool> updateTask(String taskId, Map<String, dynamic> updates) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.updateTask(taskId, updates);
      if (response.status == 'success') {
        await loadTasks();
        return true;
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete task
  Future<bool> deleteTask(String taskId) async {
    try {
      final response = await _apiService.deleteTask(taskId);
      if (response.status == 'success') {
        _tasks.removeWhere((task) => task.id == taskId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
```

### Step 2: Register Provider in main.dart

```dart
import 'package:task_manager/presenters/task_presenter.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthPresenter()),
        ChangeNotifierProvider(create: (_) => TaskPresenter()), // ← Add here
      ],
      child: MaterialApp(
        // ... rest of app
      ),
    );
  }
}
```

### Step 3: Use in Views

```dart
// lib/views/task/task_list_screen.dart
import 'package:provider/provider.dart';
import 'package:task_manager/presenters/task_presenter.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  @override
  void initState() {
    super.initState();
    // Load tasks when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskPresenter>().loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tasks')),
      body: Consumer<TaskPresenter>(
        builder: (context, taskPresenter, child) {
          if (taskPresenter.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (taskPresenter.errorMessage != null) {
            return Center(child: Text('Error: ${taskPresenter.errorMessage}'));
          }

          if (taskPresenter.tasks.isEmpty) {
            return Center(child: Text('No tasks found'));
          }

          return ListView.builder(
            itemCount: taskPresenter.tasks.length,
            itemBuilder: (context, index) {
              final task = taskPresenter.tasks[index];
              return ListTile(
                title: Text(task.title),
                subtitle: Text(task.description),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    context.read<TaskPresenter>().deleteTask(task.id);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/createTask');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
```

### Step 4: Create Task Screen

```dart
class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final presenter = context.read<TaskPresenter>();

    final success = await presenter.createTask(
      title: _titleController.text,
      description: _descriptionController.text,
    );

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Task')),
      body: Consumer<TaskPresenter>(
        builder: (context, presenter, child) {
          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: presenter.isLoading ? null : _submit,
                  child: presenter.isLoading
                      ? CircularProgressIndicator()
                      : Text('Create Task'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

---

## Best Practices

### 1. ✅ Use `listen: false` in Callbacks

```dart
// ❌ BAD - Creates unnecessary rebuilds
ElevatedButton(
  onPressed: () {
    final presenter = Provider.of<AuthPresenter>(context); // listen: true by default
    presenter.login(email, password);
  },
  child: Text('Login'),
)

// ✅ GOOD - No rebuild on button press
ElevatedButton(
  onPressed: () {
    final presenter = Provider.of<AuthPresenter>(context, listen: false);
    presenter.login(email, password);
  },
  child: Text('Login'),
)

// ✅ BETTER - Using context.read
ElevatedButton(
  onPressed: () => context.read<AuthPresenter>().login(email, password),
  child: Text('Login'),
)
```

### 2. ✅ Use Consumer for Selective Rebuilds

```dart
// ❌ BAD - Entire screen rebuilds
Widget build(BuildContext context) {
  final presenter = context.watch<AuthPresenter>();

  return Scaffold(
    appBar: AppBar(title: Text('Login')), // Rebuilds unnecessarily
    body: presenter.isLoading
      ? CircularProgressIndicator()
      : LoginForm(),
  );
}

// ✅ GOOD - Only Consumer rebuilds
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('Login')), // Never rebuilds
    body: Consumer<AuthPresenter>(
      builder: (context, presenter, child) {
        return presenter.isLoading
          ? CircularProgressIndicator()
          : LoginForm();
      },
    ),
  );
}
```

### 3. ✅ Initialize Data in initState or didChangeDependencies

```dart
class _TaskListScreenState extends State<TaskListScreen> {
  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to access Provider after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskPresenter>().loadTasks();
    });
  }

  // Or use didChangeDependencies
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<TaskPresenter>().loadTasks();
  }
}
```

### 4. ✅ Handle Dispose Properly

```dart
// Provider handles disposal automatically
// No need to dispose presenters manually!

@override
void dispose() {
  // ❌ DON'T DO THIS - Provider handles it
  // _presenter.dispose();

  // ✅ Only dispose your own controllers
  _emailController.dispose();
  _passwordController.dispose();
  super.dispose();
}
```

### 5. ✅ Use Multiple Providers for Different Features

```dart
// ✅ GOOD - Separate concerns
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthPresenter()),
    ChangeNotifierProvider(create: (_) => TaskPresenter()),
    ChangeNotifierProvider(create: (_) => ProfilePresenter()),
  ],
  child: MyApp(),
)

// ❌ BAD - One giant presenter
ChangeNotifierProvider(
  create: (_) => AppPresenter(), // Handles auth, tasks, profile, etc.
  child: MyApp(),
)
```

### 6. ✅ Keep State Immutable When Possible

```dart
class TaskPresenter extends ChangeNotifier {
  List<TaskModel> _tasks = [];

  // ❌ BAD - Mutates list directly
  void addTask(TaskModel task) {
    _tasks.add(task);
    notifyListeners();
  }

  // ✅ GOOD - Creates new list
  void addTask(TaskModel task) {
    _tasks = [..._tasks, task];
    notifyListeners();
  }
}
```

---

## Common Patterns

### Pattern 1: Lazy Loading Provider

```dart
// Only create provider when first accessed
ChangeNotifierProvider(
  create: (_) => ExpensivePresenter(),
  lazy: true, // Default is true
  child: MyApp(),
)
```

### Pattern 2: Provider with Dependencies

```dart
// Provide API service to presenter
MultiProvider(
  providers: [
    Provider(create: (_) => ApiService()),
    ChangeNotifierProxyProvider<ApiService, TaskPresenter>(
      create: (_) => TaskPresenter(ApiService()),
      update: (_, apiService, previous) =>
        TaskPresenter(apiService),
    ),
  ],
  child: MyApp(),
)
```

### Pattern 3: Scoped Provider

```dart
// Provide only to specific subtree
Widget build(BuildContext context) {
  return ChangeNotifierProvider(
    create: (_) => FormPresenter(),
    child: FormScreen(), // Only this subtree has access
  );
}
```

### Pattern 4: Multiple Consumers

```dart
Consumer2<AuthPresenter, TaskPresenter>(
  builder: (context, auth, task, child) {
    return Text('${auth.user.name} has ${task.taskCount} tasks');
  },
)

// Up to Consumer6 is available
```

### Pattern 5: Selector for Optimized Rebuilds

```dart
// Only rebuild when specific property changes
Selector<TaskPresenter, int>(
  selector: (context, presenter) => presenter.taskCount,
  builder: (context, taskCount, child) {
    return Text('Tasks: $taskCount');
  },
)

// This won't rebuild even if other properties change!
```

---

## Summary

### When to Use Provider:

✅ Sharing state between multiple widgets  
✅ Avoiding prop drilling  
✅ Separating business logic from UI  
✅ Managing app-wide state (auth, theme, etc.)  
✅ When you need efficient rebuilds

### Quick Reference:

| Method                                   | Use Case                                 |
| ---------------------------------------- | ---------------------------------------- |
| `context.watch<T>()`                     | Listen and rebuild when provider changes |
| `context.read<T>()`                      | Access without listening (callbacks)     |
| `Consumer<T>`                            | Selective rebuild of widget subtree      |
| `Provider.of<T>(context)`                | Old syntax for watch                     |
| `Provider.of<T>(context, listen: false)` | Old syntax for read                      |
| `Selector<T, R>`                         | Rebuild only when specific value changes |

### Provider in This Project:

- ✅ **AuthPresenter** - Handles all authentication logic
- 🔜 **TaskPresenter** - Add for task management
- 🔜 **ProfilePresenter** - Add for profile management

All providers are globally accessible and efficiently managed! 🎉
