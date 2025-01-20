import 'package:flutter/material.dart';
import 'dart:async';
import 'package:bee_task/screen/TaskData.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
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
  late Stream<List<Map<String, dynamic>>> commentStream;
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchComments();
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
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
    if (snapshot.connectionState == ConnectionState.waiting || snapshot.data is CommentLoadingState) {
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
)
,

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
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: EdgeInsets.zero, // Không padding cho ListTile
        leading: _buildAvatar(comment['author']),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              comment['author'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            Text(comment['text'], style: const TextStyle(fontSize: 14)),
          ],
        ),
        subtitle: Text(
          comment['date'],
          style: const TextStyle(fontSize: 10),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'edit') {
              _editComment(comment);
            } else if (value == 'delete') {
              // Gọi hàm delete comment
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
        ),
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
        IconButton(
          icon: const Icon(Icons.upload_rounded, color: Colors.blue),
          onPressed: _showUploadOptions, // Show upload options dialog
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

  void _showUploadOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose upload option',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.image, color: Colors.blue),
                title: const Text('Upload Image'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _uploadImage(); // Gọi hàm upload ảnh
                },
              ),
              ListTile(
                leading: const Icon(Icons.file_present, color: Colors.green),
                title: const Text('Upload File'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _uploadFile();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      // String? fileUrl =
      //     await uploadFileToFirebase(pickedImage.path, pickedImage.name);

      // if (fileUrl != null) {
      //   // Lưu bình luận với URL file (ảnh)
      // }
    }
  }

  Future<void> _uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      // PlatformFile file = result.files.first;

      // String? fileUrl = await uploadFileToFirebase(file.path!, file.name);

      // if (fileUrl != null) {
      //   // Lưu bình luận với URL file
      // }
    }
  }
}
