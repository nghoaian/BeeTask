import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'comment_event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'comment_state.dart';
import 'package:bee_task/data/repository/CommentRepository.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final CommentRepository commentRepository;

  CommentBloc(this.commentRepository) : super(CommentInitialState()) {
    on<FetchCommentsEvent>(_onFetchComment);
    on<AddCommentEvent>(_onAddComment);
    on<EditCommentEvent>(_onUpdateComment);
    on<DeleteCommentEvent>(_onDeleteComment);
    on<logTaskActivity>(_onLogTaskActivity);
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
          event.id, event.type, event.author, event.content);
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
      );
      var comments = await commentRepository.getComments(event.id, event.type);
      emit(CommentLoadedState(comments: comments));
    } catch (e) {
      emit(CommentErrorState(error: 'Error editing comment: $e'));
    }
  }

  Future<void> _onDeleteComment(
      DeleteCommentEvent event, Emitter<CommentState> emit) async {
    emit(CommentLoadingState());
    try {
      await commentRepository.deleteComment(
          event.commentId, event.id, event.type);
      var comments = await commentRepository.getComments(event.id, event.type);
      emit(CommentLoadedState(comments: comments));
    } catch (e) {
      emit(CommentErrorState(error: 'Error editing comment: $e'));
    }
  }

  Future<void> _onLogTaskActivity(
      logTaskActivity event, Emitter<CommentState> emit) async {
    try {
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      User? user = firebaseAuth.currentUser;

      final taskActivity = await commentRepository.logTaskActivity(event.projectId,event.taskId,
          event.action, event.changedFields, user?.email ?? '', event.type);
    } catch (e) {
      emit(CommentErrorState(error: 'Error editing comment: $e'));
    }
  }
}
