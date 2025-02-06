import 'package:bee_task/bloc/task/task_event.dart';
import 'package:bee_task/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bee_task/screen/TaskData.dart';
import 'package:bee_task/screen/upcoming/taskdetail_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bee_task/bloc/task/task_bloc.dart';
import 'package:bee_task/screen/upcoming/CommentsDialog.dart';
import 'package:bee_task/data/model/task.dart';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() => _ActivitylogscreenState();
}

class _ActivitylogscreenState extends State<ActivityLogScreen> {
  List<String> selectedEventTypes = ['All events']; // Default to 'All events'
  String selectedCollaborator = '';
  String selectedProject = 'All Projects';

  var activityLog = TaskData().activity_log;
  var projects = TaskData().projects;
  Set<String> uniqueMembers = {};
  List<String> collaborators = [];
  var users = TaskData().users;

  @override
  void initState() {
    super.initState();
    Set<String> projectIds =
        projects.map<String>((project) => project['id'].toString()).toSet();

    // Lọc activityLog để chỉ lấy các activity thuộc project trong danh sách projects
    activityLog = activityLog
        .where((activity) => projectIds.contains(activity['projectId']))
        .toList();
    for (var project in projects) {
      List<dynamic> members = project['members'];
      for (var member in members) {
        uniqueMembers
            .add(member); // Adding members to the Set will ensure uniqueness
      }
    }
    collaborators = uniqueMembers.toList();
  }

  List<Map<String, dynamic>> get filteredLogs {
    return activityLog.where((log) {
      bool matchesEventType = selectedEventTypes.contains('All events') ||
          selectedEventTypes.contains(log['action']) ||
          (selectedEventTypes.contains('comments') &&
              log['action'].contains('comment'));

      bool matchesCollaborator = selectedCollaborator.isEmpty ||
          log['userEmail'] == selectedCollaborator;

      bool matchesProject = selectedProject == 'All Projects' ||
          log['projectId'] == selectedProject;

      return matchesEventType && matchesCollaborator && matchesProject;
    }).toList();
  }

  // Helper method to format timestamp
  String formatTimestamp(String timestamp) {
    try {
      // Parse the timestamp
      DateTime dateTime = DateFormat('HH:mm, dd-MM-yyyy').parse(timestamp);
      // Format to show only the time
      return DateFormat('HH:mm').format(dateTime); // Show only the time
    } catch (e) {
      return "Invalid time"; // Return a default value in case of invalid timestamp
    }
  }

  Map<String, List<Map<String, dynamic>>> groupLogsByDate() {
    Map<String, List<Map<String, dynamic>>> groupedLogs = {};

    for (var log in filteredLogs) {
      String timestamp = log['timestamp']; // "11:39, 29-01-2025"
      List<String> parts = timestamp.split(", ");

      if (parts.length < 2) continue; // Bỏ qua nếu format sai

      String timePart = parts[0]; // "11:39"
      String datePart = parts[1]; // "29-01-2025"

      if (!groupedLogs.containsKey(datePart)) {
        groupedLogs[datePart] = [];
      }

      groupedLogs[datePart]?.add(log);
    }

    // Sắp xếp ngày theo thứ tự giảm dần
    List<String> sortedDates = groupedLogs.keys.toList()
      ..sort((a, b) {
        DateTime dateA = DateFormat("dd-MM-yyyy").parse(a);
        DateTime dateB = DateFormat("dd-MM-yyyy").parse(b);
        return dateB.compareTo(dateA); // Ngày mới hơn lên trước
      });

    // Sắp xếp log trong mỗi ngày theo giờ giảm dần
    Map<String, List<Map<String, dynamic>>> sortedGroupedLogs = {};
    for (var date in sortedDates) {
      List<Map<String, dynamic>> logs = groupedLogs[date]!;
      logs.sort((a, b) {
        String timeA = a['timestamp'].split(", ")[0]; // "11:39"
        String timeB = b['timestamp'].split(", ")[0]; // "12:05"
        return DateFormat("HH:mm")
            .parse(timeB)
            .compareTo(DateFormat("HH:mm").parse(timeA));
      });
      sortedGroupedLogs[date] = logs;
    }

    return sortedGroupedLogs;
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Map<String, dynamic>>> groupedLogs = groupLogsByDate();

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[200],
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text('Activity Log',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.sort,
                color: AppColors.primary,
              ),
              onPressed: () async {
                // Pass the updated `selectedProject` to the dialog
                String? selectedProjectResult = await showDialog<String>(
                  context: context,
                  builder: (context) => SelectProjectDialog(
                    projects: projects,
                    selectedProject: selectedProject,
                  ),
                );
                if (selectedProjectResult != null) {
                  setState(() {
                    selectedProject = selectedProjectResult;
                  });
                }
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.filter_list,
                color: AppColors.primary,
              ),
              onPressed: () {
                showMenu(
                  context: context,
                  position: const RelativeRect.fromLTRB(70, 70, 0, 0),
                  items: [
                    PopupMenuItem<String>(
                      value: 'By event task',
                      child: Text('By event task'),
                    ),
                    PopupMenuItem<String>(
                      value: 'By collaborator',
                      child: Text('By collaborator'),
                    ),
                  ],
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ).then((selectedOption) {
                  if (selectedOption == 'By event task') {
                    // Show the dialog for event task filter
                    showDialog(
                      context: context,
                      builder: (context) => FilterDialog(
                        selectedEventTypes: selectedEventTypes,
                        onEventTypesChanged: (value) {
                          setState(() {
                            selectedEventTypes =
                                value; // Update selectedEventTypes
                          });
                        },
                      ),
                    );
                  } else if (selectedOption == 'By collaborator') {
                    // Show the dialog for collaborator filter
                    showDialog(
                      context: context,
                      builder: (context) => CollaboratorDialog(
                        selectedCollaborator: selectedCollaborator,
                        onCollaboratorChanged: (value) {
                          setState(() {
                            selectedCollaborator = value;
                          });
                        },
                      ),
                    );
                  }
                });
              },
            ),
          ],
        ),
        body: groupedLogs.isEmpty
            ? Center(
                child:
                    Text('No activities found', style: TextStyle(fontSize: 18)),
              )
            : ListView.builder(
                itemCount: groupedLogs.length,
                itemBuilder: (context, index) {
                  String date = groupedLogs.keys.elementAt(index);
                  List<Map<String, dynamic>> logsForDate = groupedLogs[date]!;

                  return Container(
                    color: Colors.grey[200],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display the date header
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            date,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        // Display each activity log for the given date
                        ...logsForDate.map((log) {
                          var user = users.firstWhere(
                              (user) => user['userEmail'] == log['userEmail']);

                          var task;
                          if (log['type'] == 'task') {
                            task = TaskData().tasks.firstWhere(
                                  (taskF) => taskF['id'] == log['taskId'],
                                  orElse: () => {"id": "noTask"},
                                );
                          } else if (log['type'] == 'subtask') {
                            task = TaskData().subtasks.firstWhere(
                                  (taskF) => taskF['id'] == log['taskId'],
                                  orElse: () => {"id": "noTask"},
                                );
                          } else {
                            task = TaskData().subsubtasks.firstWhere(
                                  (taskF) => taskF['id'] == log['taskId'],
                                  orElse: () => {"id": "noTask"},
                                );
                          }

                          var project = TaskData().projects.firstWhere(
                              (project) => project['id'] == task['projectId'],
                              orElse: () =>
                                  {} // Nếu không tìm thấy, trả về một Map trống
                              );
                          String action = log['action'] ?? "Unknown Action";
                          String projectId =
                              log['projectId'] ?? "Unknown Project";
                          String taskId = log['taskId'] ?? "Unknown Task";
                          String taskName = task['title'] ?? "Unknown Task";
                          String userEmail = log['userEmail'] ?? "Unknown User";
                          String timestamp = log['timestamp'] ?? "No Timestamp";
                          String type = log['type'] ?? "task";
                          Map<String, dynamic> changedFields =
                              log['changedFields'] ?? {};
                          String logText = '';
                          if (action.contains('comment')) {
                            if (action == "add_comment") {
                              logText =
                                  "$userEmail add a comment in the $type $taskName";
                            } else if (action == "edit_comment") {
                              logText =
                                  "$userEmail edit a comment in the $type $taskName";
                            } else if (action == "delete_comment") {
                              logText =
                                  "$userEmail delete a comment in the $type $taskName";
                            }
                          } else {
                            if (action == 'delete') {
                              taskName = log['changedFields']['title'];
                            }
                            logText = "$userEmail $action a $type $taskName";
                          }

                          if ((action.toLowerCase() == "update" &&
                                  changedFields.isNotEmpty) ||
                              (action.toLowerCase() == "edit_comment" &&
                                  changedFields.isNotEmpty)) {
                            List<String> changeDetails =
                                changedFields.entries.map((entry) {
                              var key = entry.key;
                              var fieldData = entry.value;
                              if (fieldData is Map<String, dynamic>) {
                                var oldValue = fieldData['oldValue'] ?? "N/A";
                                var newValue = fieldData['newValue'] ?? "N/A";
                                return "The $key changed from \"$oldValue\" to \"$newValue\"";
                              }
                              return "$key: $fieldData";
                            }).toList();

                            logText += "\n${changeDetails.join(", ")}";
                          }

                          return InkWell(
                            onTap: () async {
                              bool permissions = await TaskData()
                                  .isUserInProjectPermissions(
                                      type, log['taskId']);

                              if (log['action'].contains('comment')) {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) => CommentsDialog(
                                    idTask:
                                        log['taskId'], // Pass idTask to dialog
                                    type: log['type'], // Pass type to dialog
                                  ),
                                );
                              } else if (log['action'] == 'delete') {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Restore $type"),
                                      content:
                                          Text("This $type has been deleted."),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text("OK"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else {
                                try {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    isDismissible: false,
                                    builder: (context) {
                                      return SingleChildScrollView(
                                        child: TaskDetailsDialog(
                                          taskId: taskId,
                                          permissions: permissions,
                                          type: type,
                                          isCompleted: task['completed'],
                                          openFirst: true,
                                          selectDay: DateTime.now(),
                                          projectName: project['name'],
                                          showCompletedTasks: true,
                                          taskBloc: BlocProvider.of<TaskBloc>(
                                              context),
                                          resetDialog: () => {},
                                          resetScreen: () => {},
                                        ),
                                      );
                                    },
                                  );
                                } catch (e) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Task Already Deleted"),
                                        content: Text(
                                            "This task has already been deleted."),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("OK"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              }
                            },
                            child: Card(
                              color: Colors.white,
                              margin: EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 16),
                              elevation: 2,
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Row(
                                  children: [
                                    // Stack to overlay the icon at the bottom-right of the avatar
                                    Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: TaskData()
                                              .getColorFromString(
                                                  user['userColor']),
                                          child: Text(
                                            user['userName'][0].toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ), // Replace with actual user avatar
                                        ),
                                        Positioned(
                                          bottom: -4,
                                          right: -4,
                                          child: Icon(
                                            getActivityIcon(action),
                                            color: Colors.blue,
                                            size: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            logText,
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                formatTimestamp(timestamp),
                                                style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12),
                                              ),
                                              Text(
                                                "$projectId",
                                                style: TextStyle(
                                                    color: Colors.blueGrey,
                                                    fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  );
                },
              ));
  }

  IconData getActivityIcon(String action) {
    switch (action) {
      case 'add' || 'add_comment':
        return Icons.add_circle;
      case 'delete' || 'delete_comment':
        return Icons.remove_circle;
      case 'update' || 'edit_comment':
        return Icons.edit;
      case 'complete':
        return Icons.check_circle;
      case 'uncomplete':
        return Icons.cancel;
      default:
        return Icons.info; // Default icon for unknown actions
    }
  }
}

class SelectProjectDialog extends StatefulWidget {
  List<Map<String, dynamic>> projects;
  final String selectedProject;

  SelectProjectDialog({required this.projects, required this.selectedProject});

  @override
  _SelectProjectDialogState createState() => _SelectProjectDialogState();
}

class _SelectProjectDialogState extends State<SelectProjectDialog> {
  late String selectedProject;

  @override
  void initState() {
    super.initState();
    selectedProject = widget.selectedProject;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text('Select Project'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('All Projects'),
              tileColor:
                  selectedProject == 'All Projects' ? Colors.blue[100] : null,
              onTap: () {
                setState(() {
                  selectedProject = 'All Projects';
                });
                Navigator.pop(context, 'All Projects');
              },
            ),
            Divider(),
            ...widget.projects.map((project) {
              return ListTile(
                title: Text(project['name']),
                tileColor:
                    selectedProject == project['id'] ? Colors.blue[100] : null,
                onTap: () {
                  setState(() {
                    selectedProject = project['id'];
                  });
                  Navigator.pop(context, project['id']);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class FilterDialog extends StatefulWidget {
  final Function(List<String>) onEventTypesChanged;
  final List<String> selectedEventTypes;

  FilterDialog(
      {required this.onEventTypesChanged, required this.selectedEventTypes});

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late List<String> selectedEventTypes;

  // Map of original event names to custom display text
  final Map<String, String> eventDisplayNames = {
    'All events': 'All Activities',
    'add': 'Add Task',
    'update': 'Update Task',
    'complete': 'Complete Task',
    'uncomplete': 'Uncomplete Task',
    'comments': 'Comments',
  };

  @override
  void initState() {
    super.initState();
    selectedEventTypes = widget.selectedEventTypes; // Default to 'All events'
  }

  // List of events with corresponding icons
  final List<Map<String, dynamic>> events = [
    {'name': 'All events', 'icon': Icons.event_available},
    {'name': 'add', 'icon': Icons.add_circle},
    {'name': 'update', 'icon': Icons.edit},
    {'name': 'complete', 'icon': Icons.check_circle},
    {'name': 'uncomplete', 'icon': Icons.cancel},
    {'name': 'comments', 'icon': Icons.comment},
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      title: Text(
        'Filter Activity Log',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: events.map((event) {
            bool isSelected = selectedEventTypes.contains(event['name']);
            return ListTile(
              leading: Icon(event['icon']),
              title: Text(eventDisplayNames[event['name']] ??
                  event['name']), // Show custom display name
              tileColor: isSelected
                  ? Colors.blue[100]
                  : null, // Highlight selected event
              onTap: () {
                setState(() {
                  if (event['name'] == 'All events') {
                    selectedEventTypes = ['All events'];
                  } else {
                    if (isSelected) {
                      // If already selected, deselect it
                      selectedEventTypes.remove(event['name']);
                    } else {
                      // If not selected, add it to the list
                      selectedEventTypes.add(event['name']);
                    }

                    // Remove 'All events' if another event is selected
                    if (selectedEventTypes.contains(event['name'])) {
                      selectedEventTypes.remove('All events');
                    }

                    // If no events are selected, select 'All events' by default
                    if (selectedEventTypes.isEmpty) {
                      selectedEventTypes.add('All events');
                    }
                  }
                });
                widget.onEventTypesChanged(selectedEventTypes);
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          child: Text('Close'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop(); // Close dialog
          },
        ),
      ],
    );
  }
}

class CollaboratorDialog extends StatefulWidget {
  final String selectedCollaborator;
  final Function(String) onCollaboratorChanged;

  CollaboratorDialog({
    required this.selectedCollaborator,
    required this.onCollaboratorChanged,
  });

  @override
  _CollaboratorDialogState createState() => _CollaboratorDialogState();
}

class _CollaboratorDialogState extends State<CollaboratorDialog> {
  late String selectedCollaborator;
  var projects = TaskData().projects;
  Set<String> uniqueMembers = {};
  List<String> collaborators = [];

  @override
  void initState() {
    super.initState();
    selectedCollaborator = widget.selectedCollaborator;

    for (var project in projects) {
      List<dynamic> members = project['members'];
      for (var member in members) {
        uniqueMembers.add(member);
      }
    }
    collaborators = uniqueMembers.toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text('Select Collaborator'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('All Collaborators'),
              tileColor: selectedCollaborator.isEmpty ? Colors.blue[100] : null,
              onTap: () {
                setState(() {
                  selectedCollaborator = ''; // Clear the selection
                });
                widget.onCollaboratorChanged('');
                Navigator.pop(context);
              },
            ),
            Divider(),
            ...collaborators.map((collaborator) {
              return ListTile(
                title: Text(collaborator),
                tileColor: selectedCollaborator == collaborator
                    ? Colors.blue[100]
                    : null,
                onTap: () {
                  setState(() {
                    selectedCollaborator = collaborator;
                  });
                  widget.onCollaboratorChanged(collaborator);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
