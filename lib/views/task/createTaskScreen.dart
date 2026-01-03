import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/presenters/task_presenter.dart';

import '../../style/style.dart';

class CreateTaskScreen extends StatefulWidget {
  final VoidCallback? onTaskCreated;
  const CreateTaskScreen({super.key, this.onTaskCreated});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedStatus = 'New';

  final List<String> _statusOptions = [
    'New',
    'Progress',
    'Completed',
    'Cancelled',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitTask() async {
    if (_titleController.text.trim().isEmpty) {
      ErrorToast('Task title is required');
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ErrorToast('Task description is required');
      return;
    }

    // Use AuthPresenter to create task
    final taskPresenter = context.read<TaskPresenter>();
    bool success = await taskPresenter.createTask(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      status: _selectedStatus,
    );
    if (success && mounted) {
      Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskPresenter>(
      builder: (context, taskPresenter, child) => Scaffold(
        appBar: AppBar(
          backgroundColor: colorBlue,
          title: Text(
            'Create New Task',
            style: TextStyle(color: colorWhite, fontWeight: FontWeight.w600),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorWhite),
            onPressed: () => Navigator.pop(context),
          ),
          elevation: 0,
        ),
        body: Stack(
          children: [
            // Background
            mainBackground(context),

            // Content
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),

                    // Header
                    Text('Task Details', style: Head1Text(colorDarkBlue)),
                    SizedBox(height: 8),
                    Text(
                      'Fill in the information below to create a new task',
                      style: Head7Text(colorLightGray),
                    ),

                    SizedBox(height: 30),

                    // Title Field
                    Text(
                      'Task Title',
                      style: Head7Text(
                        colorDarkBlue,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      decoration: AppInputDecoration('Enter task title'),
                      maxLength: 100,
                    ),

                    SizedBox(height: 20),

                    // Description Field
                    Text(
                      'Description',
                      style: Head7Text(
                        colorDarkBlue,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: AppInputDecoration('Enter task description'),
                      maxLines: 5,
                      maxLength: 500,
                    ),

                    SizedBox(height: 20),

                    // Status Dropdown
                    Text(
                      'Task Status',
                      style: Head7Text(
                        colorDarkBlue,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: colorLightBlue, width: 1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedStatus,
                          isExpanded: true,
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: colorDarkBlue,
                          ),
                          items: _statusOptions.map((String status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Row(
                                children: [
                                  _getStatusIcon(status),
                                  SizedBox(width: 12),
                                  Text(status, style: Head7Text(colorDarkBlue)),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedStatus = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: 40),

                    // Action Buttons
                    Row(
                      children: [
                        // Cancel Button
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/'),
                              style: AppButtonStyle(),
                              child: DangerButtonChild('Cancel'),
                            ),
                          ),
                        ),

                        SizedBox(width: 16),

                        // Create Button
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              style: AppButtonStyle(),
                              onPressed: taskPresenter.isLoading
                                  ? null
                                  : _submitTask,
                              child: taskPresenter.isLoading
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: colorWhite,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : SuccessButtonChild('Create Task'),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get status icon
  Widget _getStatusIcon(String status) {
    IconData iconData;
    Color iconColor;

    switch (status) {
      case 'New':
        iconData = Icons.fiber_new;
        iconColor = colorBlue;
        break;
      case 'Progress':
        iconData = Icons.refresh;
        iconColor = colorOrange;
        break;
      case 'Completed':
        iconData = Icons.check_circle;
        iconColor = colorGreen;
        break;
      case 'Cancelled':
        iconData = Icons.cancel;
        iconColor = colorRed;
        break;
      default:
        iconData = Icons.circle;
        iconColor = colorLightGray;
    }

    return Icon(iconData, color: iconColor, size: 20);
  }
}
