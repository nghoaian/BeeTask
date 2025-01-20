import 'package:flutter_bloc/flutter_bloc.dart';
import 'comment_event.dart';
import 'comment_state.dart';
import 'package:bee_task/data/repository/CommentRepository.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final CommentRepository commentRepository;

  CommentBloc(this.commentRepository) : super(CommentInitialState()) {
    on<FetchCommentsEvent>(_onFetchComment);
    on<AddCommentEvent>(_onAddComment);
    on<EditCommentEvent>(_onUpdateComment);
  }

  // Handle FetchCommentsEvent
  Future<void> _onFetchComment(
      FetchCommentsEvent event, Emitter<CommentState> emit) async {
    emit(CommentLoadingState());
    try {
      var comments = await commentRepository.getComments(event.id, event.type);
      emit(CommentLoadedState(comments: comments));
    } catch (e) {
      emit(CommentErrorState(error: 'Error fetching comments: $e'));
    }
  }

  // Handle AddCommentEvent
  Future<void> _onAddComment(
      AddCommentEvent event, Emitter<CommentState> emit) async {
    emit(CommentLoadingState());
    try {
      await commentRepository.addComment(
        event.id,
        event.type,
        event.content,
        event.author,
        filePath: event.filePath,
        imageUrl: event.imageUrl,
      );
      var comments = await commentRepository.getComments(event.id, event.type);
      emit(CommentLoadedState(comments: comments));
    } catch (e) {
      emit(CommentErrorState(error: 'Error adding comment: $e'));
    }
  }

  // Handle EditCommentEvent
  Future<void> _onUpdateComment(
      EditCommentEvent event, Emitter<CommentState> emit) async {
    emit(CommentLoadingState());
    try {
      await commentRepository.editComment(
        event.commentId,
        event.id,
        event.type,
        event.content,
        event.author,
        filePath: event.filePath,
        imageUrl: event.imageUrl,
      );
      var comments = await commentRepository.getComments(event.id, event.type);
      emit(CommentLoadedState(comments: comments));
    } catch (e) {
      emit(CommentErrorState(error: 'Error editing comment: $e'));
    }
  }
}
