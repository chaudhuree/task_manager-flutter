import 'package:flutter/material.dart';
import 'package:task_manager/components/maskedEmailText.dart';
import 'package:task_manager/style/style.dart';
import 'package:task_manager/utility/utility.dart';

class TaskAppBar extends StatefulWidget implements PreferredSizeWidget {
  const TaskAppBar({super.key});

  @override
  State<TaskAppBar> createState() => _TaskAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(100); // Increased height to accommodate content
}

class _TaskAppBarState extends State<TaskAppBar> {
  late Future<Map<String, String?>> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _fetchUserData();
  }

  Future<Map<String, String?>> _fetchUserData() async {
    return {
      'firstName': await ReadUserData("firstName"),
      'lastName': await ReadUserData("lastName"),
      'email': await ReadUserData("email"),
      'photo': await ReadUserData("photo"),
    };
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: colorBlue,
      flexibleSpace: Container(
        margin: EdgeInsets.fromLTRB(10, 40, 10, 0),
        child: FutureBuilder<Map<String, String?>>(
          future: _userDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show a loading indicator while fetching data
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // Handle error (e.g., show default text)
              return const Row(children: [Text('Error loading user data')]);
            } else {
              final data = snapshot.data ?? {};
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 24,
                    child: ClipOval(
                      child:
                          (data['photo'] != null &&
                              ShowBase64Image(data['photo']!) != null)
                          ? Image.memory(ShowBase64Image(data['photo']!))
                          : Image.memory(
                              ShowBase64Image(DefaultProfilePic),
                            ), // Fallback to default
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}',
                        style: Head7Text(colorWhite),
                      ),
                      MaskedEmailText(email: data['email'] ?? ''),
                    ],
                  ),
                  Expanded(child: const SizedBox(width: 10)),
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/createTask");
                    },
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: colorWhite,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await RemoveToken();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        "/login",
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.output, color: colorWhite),
                  ),
                ],
              );
            }
          },
        ),
      ),
      // actions: [
      //   IconButton(
      //     onPressed: () {
      //       Navigator.pushNamed(context, "/createTask");
      //     },
      //     icon: const Icon(Icons.add_circle_outline, color: colorWhite),
      //   ),
      //   IconButton(
      //     onPressed: () async {
      //       await RemoveToken();
      //       Navigator.pushNamedAndRemoveUntil(
      //         context,
      //         "/login",
      //         (route) => false,
      //       );
      //     },
      //     icon: const Icon(Icons.output, color: colorWhite),
      //   ),
      // ],
    );
  }
}
