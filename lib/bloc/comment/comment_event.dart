abstract class CommentEvent {}

class AddCommentEvent extends CommentEvent {
  final String id;
  final String type;
  final String content;
  final String author;
  final String? filePath;
  final String? imageUrl;

  AddCommentEvent({
    required this.id,
    required this.type,
    required this.content,
    required this.author,
    this.filePath,
    this.imageUrl,
  });
}

class EditCommentEvent extends CommentEvent {
  final String commentId;
  final String id;
  final String type;
  final String content;
  final String author;
  final String? filePath;
  final String? imageUrl;

  EditCommentEvent({
    required this.commentId,
    required this.id,
    required this.type,
    required this.content,
    required this.author,
    this.filePath,
    this.imageUrl,
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
