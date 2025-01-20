abstract class CommentState {}

class CommentInitialState extends CommentState {
  final bool isLoading;

  CommentInitialState({this.isLoading = true});
}

class CommentLoadingState extends CommentState {}

class CommentLoadedState extends CommentState {
  final List<Map<String, dynamic>> comments;

  CommentLoadedState({required this.comments});
}

class CommentErrorState extends CommentState {
  final String error;

  CommentErrorState({required this.error});
}
