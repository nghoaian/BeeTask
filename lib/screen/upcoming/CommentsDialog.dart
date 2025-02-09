import 'package:flutter/material.dart';
import 'dart:async';
import 'package:bee_task/screen/TaskData.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'package:bee_task/bloc/comment/comment_bloc.dart'; // Add this line
import 'package:bee_task/bloc/comment/comment_state.dart'; // Add this line
import 'package:bee_task/bloc/comment/comment_event.dart'; // Add this line
import 'package:flutter_bloc/flutter_bloc.dart'; // Add this line

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
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  User? user;
  var tasks = TaskData().tasks;
  var subtasks = TaskData().subtasks;
  var subsubtasks = TaskData().subsubtasks;
  var users = TaskData().users;
  var projects = TaskData().projects;
  bool owner = false;

  @override
  void initState() {
    super.initState();
    user = firebaseAuth.currentUser;
    _fetchComments();
    var taskF;
    if (widget.type == 'task') {
      taskF = tasks.firstWhere((task) => task['id'] == widget.idTask,
          orElse: () => {} // Nếu không tìm thấy, trả về một Map trống
          );
    } else if (widget.type == 'subtask') {
      taskF = subtasks.firstWhere((task) => task['id'] == widget.idTask,
          orElse: () => {} // Nếu không tìm thấy, trả về một Map trống
          );
    } else {
      taskF = tasks.firstWhere((task) => task['id'] == widget.idTask,
          orElse: () => {} // Nếu không tìm thấy, trả về một Map trống
          );
    }

    var project = projects.firstWhere((pro) => pro['id'] == taskF['projectId'],
        orElse: () => {} // Nếu không tìm thấy, trả về một Map trống
        );
    if (project['owner'] == user?.email) {
      owner = true;
    }
  }

  Future<void> _fetchComments() async {
    final completer = Completer<void>();
    final subscription =
        BlocProvider.of<CommentBloc>(context).stream.listen((state) {
      if (state is CommentLoadedState || state is CommentErrorState) {
        completer.complete();
      }
    });

    BlocProvider.of<CommentBloc>(context).add(
      FetchCommentsEvent(id: widget.idTask, type: widget.type),
    );

    await completer.future;
    subscription.cancel(); // Hủy đăng ký sau khi hoàn tất
  }

  Future<void> _addComments(String commentText) async {
    final completer = Completer<void>();
    final subscription =
        BlocProvider.of<CommentBloc>(context).stream.listen((state) {
      if (state is CommentLoadedState || state is CommentErrorState) {
        completer.complete();
      }
    });

    BlocProvider.of<CommentBloc>(context).add(AddCommentEvent(
        id: widget.idTask,
        type: widget.type,
        content: commentText,
        author: user?.email ?? ''));
    var taskData;
    if (widget.type == 'task') {
      taskData = TaskData()
          .tasks
          .firstWhere((task) => task['id'] == widget.idTask, orElse: () => {});
    } else if (widget.type == 'subtask') {
      taskData = TaskData()
          .subtasks
          .firstWhere((task) => task['id'] == widget.idTask, orElse: () => {});
    } else {
      taskData = TaskData()
          .subsubtasks
          .firstWhere((task) => task['id'] == widget.idTask, orElse: () => {});
    }
    BlocProvider.of<CommentBloc>(context).add(logTaskActivity(
      projectId: taskData['projectId'],
      taskId: widget.idTask,
      action: 'add_comment',
      changedFields: {'content': commentText},
      type: widget.type,
    ));

    await completer.future;
    subscription.cancel(); // Hủy đăng ký sau khi hoàn tất
  }

  Future<void> _editComments(String commentId, String commentText) async {
    final completer = Completer<void>();
    final subscription =
        BlocProvider.of<CommentBloc>(context).stream.listen((state) {
      if (state is CommentLoadedState || state is CommentErrorState) {
        completer.complete();
      }
    });

    BlocProvider.of<CommentBloc>(context).add(EditCommentEvent(
      commentId: commentId,
      id: widget.idTask,
      type: widget.type,
      content: commentText,
    ));

    await completer.future;
    subscription.cancel(); // Hủy đăng ký sau khi hoàn tất
  }

  Future<void> _deleteComments(String commentId) async {
    final completer = Completer<void>();
    final subscription =
        BlocProvider.of<CommentBloc>(context).stream.listen((state) {
      if (state is CommentLoadedState || state is CommentErrorState) {
        completer.complete();
      }
    });

    BlocProvider.of<CommentBloc>(context).add(DeleteCommentEvent(
      commentId: commentId,
      id: widget.idTask,
      type: widget.type,
    ));
    var taskData;
    if (widget.type == 'task') {
      taskData = TaskData()
          .tasks
          .firstWhere((task) => task['id'] == widget.idTask, orElse: () => {});
    } else if (widget.type == 'subtask') {
      taskData = TaskData()
          .subtasks
          .firstWhere((task) => task['id'] == widget.idTask, orElse: () => {});
    } else {
      taskData = TaskData()
          .subsubtasks
          .firstWhere((task) => task['id'] == widget.idTask, orElse: () => {});
    }
    BlocProvider.of<CommentBloc>(context).add(logTaskActivity(
      projectId: taskData['projectId'],
      taskId: widget.idTask,
      action: 'delete_comment',
      changedFields: {},
      type: widget.type,
    ));

    await completer.future;
    subscription.cancel(); // Hủy đăng ký sau khi hoàn tất
  }

  Future<void> _showCommentInputDialog() async {
    TextEditingController inputController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
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
                Navigator.of(context).pop(); // Đóng dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Lấy giá trị từ TextField
                final commentText = inputController.text.trim();

                if (commentText.isNotEmpty) {
                  Navigator.of(context).pop(); // Đóng dialog

                  // Gọi hàm thêm comment
                  await _addComments(commentText);

                  // Cập nhật giao diện hoặc fetch lại comments nếu cần
                  await _fetchComments();
                }
              },
              child: const Text('Submit'),
            ),
          ],
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
                var taskData;
                if (widget.type == 'task') {
                  taskData = TaskData().tasks.firstWhere(
                      (task) => task['id'] == widget.idTask,
                      orElse: () => {});
                } else if (widget.type == 'subtask') {
                  taskData = TaskData().subtasks.firstWhere(
                      (task) => task['id'] == widget.idTask,
                      orElse: () => {});
                } else {
                  taskData = TaskData().subsubtasks.firstWhere(
                      (task) => task['id'] == widget.idTask,
                      orElse: () => {});
                }
                BlocProvider.of<CommentBloc>(context).add(logTaskActivity(
                  projectId: taskData['projectId'],
                  taskId: widget.idTask,
                  action: 'edit_comment',
                  changedFields: {
                    'comment': {
                      'oldValue': comment['text'],
                      'newValue': editController.text.trim(),
                    },
                  },
                  type: widget.type,
                ));
                setState(() {
                  comment['text'] = editController.text.trim();
                  _editComments(comment['id'], comment['text']);
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
      backgroundColor: Colors.white,
      title:
          const Text('Comments', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: double.maxFinite, // Đảm bảo nội dung có thể cuộn ngang nếu cần
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // StreamBuilder để lắng nghe và cập nhật dữ liệu
            StreamBuilder<CommentState>(
              stream: BlocProvider.of<CommentBloc>(context).stream,
              builder: (context, snapshot) {
                // Kiểm tra xem có đang trong trạng thái loading không
                if (snapshot.connectionState == ConnectionState.waiting ||
                    snapshot.data is CommentLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Kiểm tra nếu có lỗi
                if (snapshot.hasError) {
                  return const Center(child: Text('Error fetching comments'));
                }

                // Kiểm tra nếu có dữ liệu và trạng thái là CommentLoadedState
                if (snapshot.hasData) {
                  var state = snapshot.data;
                  if (state is CommentLoadedState) {
                    var comments = state.comments;

                    // Nếu không có bình luận
                    if (comments.isEmpty) {
                      return const Center(child: Text('No comments yet.'));
                    }

                    // Hiển thị danh sách bình luận
                    return Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          return _buildCommentItem(comments[index]);
                        },
                      ),
                    );
                  } else if (state is CommentErrorState) {
                    return Center(child: Text('Error: ${state.error}'));
                  }
                }

                return const Center(child: Text('No data available'));
              },
            ),

            const SizedBox(height: 12.0),

            // Phần nhập comment
            _buildCommentInputSection(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Đóng dialog
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

// Hàm xây dựng một item bình luận
  Widget _buildCommentItem(Map<String, dynamic> comment) {
    String formattedDate = DateFormat('dd/MM/yyyy, HH:mm')
        .format(DateFormat('HH:mm:ss.SSS, dd-MM-yyyy').parse(comment['date']));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: _buildAvatar(comment['author']),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              TaskData().getUserNameFromList(comment['author']).isNotEmpty
                  ? TaskData().getUserNameFromList(comment['author'])
                  : comment['author'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            Text(comment['text'], style: const TextStyle(fontSize: 14)),
          ],
        ),
        subtitle: Text(
          formattedDate,
          style: const TextStyle(fontSize: 10),
        ),
        trailing: (comment['author'] == user?.email || owner == true)
            ? PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'edit') {
                    _editComment(comment);
                  } else if (value == 'delete') {
                    var taskData;
                    if (widget.type == 'task') {
                      taskData = TaskData().tasks.firstWhere(
                          (task) => task['id'] == widget.idTask,
                          orElse: () => {});
                    } else if (widget.type == 'subtask') {
                      taskData = TaskData().subtasks.firstWhere(
                          (task) => task['id'] == widget.idTask,
                          orElse: () => {});
                    } else {
                      taskData = TaskData().subsubtasks.firstWhere(
                          (task) => task['id'] == widget.idTask,
                          orElse: () => {});
                    }
                    BlocProvider.of<CommentBloc>(context).add(logTaskActivity(
                      projectId: taskData['projectId'],
                      taskId: widget.idTask,
                      action: 'add_comment',
                      changedFields: comment,
                      type: widget.type,
                    ));
                    _deleteComments(comment['id']);

                    _fetchComments();
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
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('Delete Comment'),
                      ),
                    ),
                  ];
                },
              )
            : null, // No trailing widget if author does not match
      ),
    );
  }

// Hàm xây dựng phần nhập bình luận
  Widget _buildCommentInputSection() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _showCommentInputDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      ],
    );
  }

  Widget _buildAvatar(String author) {
    var user = users.firstWhere((user) => user['userEmail'] == author);
    if (author != '') {
      return CircleAvatar(
        radius: 16,
        backgroundColor: TaskData().getColorFromString(user['userColor']),
        child: Text(
          user['userName'][0].toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      return const SizedBox(width: 16);
    }
  }
}
