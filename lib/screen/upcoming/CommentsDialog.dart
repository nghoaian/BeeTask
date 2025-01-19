import 'package:flutter/material.dart';
import 'package:bee_task/screen/TaskData.dart';

class CommentsDialog extends StatefulWidget {
  final String idTask;
  final String type;

  const CommentsDialog({
    Key? key,
    required this.idTask,
    required this.type,
  }) : super(key: key);

  @override
  _CommentsDialogState createState() => _CommentsDialogState();
}

class _CommentsDialogState extends State<CommentsDialog> {
  late Stream<List<Map<String, dynamic>>> commentStream;
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    commentStream = TaskData().getComment(widget.idTask, widget.type);
  }

  // Function to show a dialog for entering a comment
  Future<void> _showCommentInputDialog() async {
    String commentText = '';
    TextEditingController inputController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Comment'),
          content: TextField(
            controller: inputController,
            decoration: const InputDecoration(
              hintText: 'Type your comment...',
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                commentText = inputController.text.trim();
                if (commentText.isNotEmpty) {
                  setState(() {
                    // Add the new comment to the list manually
                    // You might need to update the stream as well in your data source
                    // (TaskData) to reflect the new comment if needed.
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDeleteOptions(Map<String, dynamic> comment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose an option'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Comment'),
                onTap: () {
                  Navigator.of(context).pop();
                  _editComment(comment);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Comment'),
                onTap: () {
                  setState(() {
                    // Remove the comment
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _editComment(Map<String, dynamic> comment) {
    TextEditingController editController =
        TextEditingController(text: comment['text']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Comment'),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(hintText: 'Edit your comment'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  comment['text'] = editController.text.trim();
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          const Text('Comments', style: TextStyle(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Use StreamBuilder to listen to the commentStream and rebuild UI
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: commentStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Error fetching comments'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('No comments yet.');
              }

              return Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...snapshot.data!.map(
                        (comment) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            contentPadding:
                                EdgeInsets.zero, // No padding for ListTile
                            leading: _buildAvatar(comment['author']),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (TaskData()
                                              .getUserNameFromList(
                                                  comment['author'])
                                              ?.isEmpty ??
                                          true)
                                      ? comment['author']
                                      : TaskData().getUserNameFromList(
                                          comment['author']),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  comment['text'],
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              '${comment['date']}',
                              style: const TextStyle(fontSize: 10),
                            ),
                            trailing: PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _editComment(comment);
                                } else if (value == 'delete') {
                                  setState(() {
                                    // Remove the comment
                                  });
                                }
                              },
                              itemBuilder: (BuildContext context) {
                                return [
                                  const PopupMenuItem<String>(
                                    value: 'edit',
                                    child: ListTile(
                                      leading: Icon(Icons.edit),
                                      title: Text('Edit Comment'),
                                    ),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'delete',
                                    child: ListTile(
                                      leading:
                                          Icon(Icons.delete, color: Colors.red),
                                      title: Text('Delete Comment'),
                                    ),
                                  ),
                                ];
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Comment input section

          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _showCommentInputDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue.shade300),
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.comment, color: Colors.blue),
                        SizedBox(width: 8.0),
                        Text('Comment', style: TextStyle(color: Colors.blue)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              IconButton(
                icon: const Icon(Icons.upload_rounded, color: Colors.blue),
                onPressed: _showCommentInputDialog,
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildAvatar(String author) {
    String avatarPath = TaskData().getUserAvatarFromList(author);

    if (avatarPath != '') {
      return CircleAvatar(
        radius: 15,
        backgroundImage: AssetImage('assets/$avatarPath'),
      );
    } else if (author != '') {
      return CircleAvatar(
        radius: 15,
        backgroundColor: Colors.white,
        child: Text(
          author[0].toUpperCase(),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      return const SizedBox(width: 16);
    }
  }
}
