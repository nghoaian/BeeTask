import 'package:bee_task/data/repository/UserRepository.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'account_event.dart';
import 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final UserRepository userRepository;

  AccountBloc({required this.firebaseAuth, required this.firestore})
      : userRepository = FirebaseUserRepository(firestore: firestore, firebaseAuth: firebaseAuth),
        super(AccountInitial()) {
    on<UpdateUserNameRequested>(_onUpdateUserNameRequested);
    on<UpdateUserImageRequested>(_onUpdateUserImageRequested);
  }

  // Xử lý cập nhật UserName
  Future<void> _onUpdateUserNameRequested(
      UpdateUserNameRequested event, Emitter<AccountState> emit) async {
    emit(AccountLoading());

    try {
      User? user = firebaseAuth.currentUser;
      if (user == null) {
        emit(UpdateUserNameFailure(errorMessage: "Không tìm thấy user."));
        return;
      }

      await userRepository.updateUserName(user.uid, event.username);

      emit(UpdateUserNameSuccess());
    } on FirebaseAuthException catch (e) {
      emit(UpdateUserNameFailure(errorMessage: e.message ?? "Unknown error"));
    }
  }

  // Xử lý cập nhật UserName
  Future<void> _onUpdateUserImageRequested(
      UpdateUserImageRequested event, Emitter<AccountState> emit) async {
    emit(AccountLoading());

    try {
      User? user = firebaseAuth.currentUser;
      if (user == null) {
        emit(UpdateUserImageFailure(errorMessage: "Không tìm thấy user."));
        return;
      }

      await userRepository.updateUserName(user.uid, event.userImage);

      emit(UpdateUserImageSuccess());
    } on FirebaseAuthException catch (e) {
      emit(UpdateUserImageFailure(errorMessage: e.message ?? "Unknown error"));
    }
  }
}