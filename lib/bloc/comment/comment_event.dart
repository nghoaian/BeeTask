abstract class CommentEvent {}

class AddCommentEvent extends CommentEvent {
  final String id;
  final String type;
  final String content;
  final String author;

  AddCommentEvent({
    required this.id,
    required this.type,
    required this.content,
    required this.author,
  });
}

class EditCommentEvent extends CommentEvent {
  final String commentId;
  final String id;
  final String type;
  final String content;

  EditCommentEvent({
    required this.commentId,
    required this.id,
    required this.type,
    required this.content,
  });
}

class FetchCommentsEvent extends CommentEvent {
  final String id;
  final String type;

  FetchCommentsEvent({
    required this.id,
    required this.type,
  });
}

class DeleteCommentEvent extends CommentEvent {
  final String commentId;
  final String id;
  final String type;

  DeleteCommentEvent({
    required this.commentId,
    required this.id,
    required this.type,
  });
}

class logTaskActivity extends CommentEvent {
  final String projectId;
  final String taskId;
  final String action;
  final Map<String, dynamic> changedFields;

  final String type;
  logTaskActivity(
      {required this.projectId,
      required this.taskId,
      required this.action,
      required this.changedFields,
      required this.type});
}
