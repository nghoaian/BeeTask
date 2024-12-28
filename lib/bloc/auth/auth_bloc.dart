import 'package:bloc/bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthBloc({required this.firebaseAuth, required this.firestore})
      : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<SignupRequested>(_onSignupRequested);
    on<AuthStatusChanged>(_onAuthStatusChanged);

    // Kiểm tra trạng thái đăng nhập
    firebaseAuth.authStateChanges().listen((user) {
      add(AuthStatusChanged(user: user));
    });
  }

  // Xử lý sự kiện đăng nhập
  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await firebaseAuth.signInWithEmailAndPassword(
        email: event.email.trim(),
        password: event.password.trim(),
      );
      //emit(AuthSuccess());
      emit(AuthAuthenticated(user: firebaseAuth.currentUser!));
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(errorMessage: e.message ?? "Unknown error"));
    }
  }

  // Xử lý sự kiện đăng ký
  Future<void> _onSignupRequested(SignupRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // Kiểm tra tên người dùng tồn tại trước
      bool usernameExists = await _checkIfUsernameExists(event.username);
      if (usernameExists) {
        emit(AuthSignUpFailure(errorMessage: "Username already exists!"));
        return;
      }

      // Đăng ký tài khoản mới
      await firebaseAuth.createUserWithEmailAndPassword(
        email: event.email.trim(),
        password: event.password.trim(),
      );

      // Thêm người dùng vào Firestore
      await _addUserNames(event.username, event.email);

      emit(AuthSignedUp());
    } on FirebaseAuthException catch (e) {
      emit(AuthSignUpFailure(errorMessage: e.message ?? "Unknown error"));
    }
  }

  // Kiểm tra tên người dùng đã tồn tại trong Firestore
  Future<bool> _checkIfUsernameExists(String username) async {
    final CollectionReference usersCollection =
        firestore.collection('users');
    final QuerySnapshot result = await usersCollection
        .where('userName', isEqualTo: username)
        .limit(1)
        .get();

    return result.docs.isNotEmpty;
  }

  // Thêm người dùng vào Firestore
  Future<void> _addUserNames(String username, String email) async {
    final CollectionReference usersCollection =
        firestore.collection('users');
    await usersCollection.add({
      'userName': username,
      'userEmail': email,
    });
  }

  // Xử lý trạng thái đăng nhập
  void _onAuthStatusChanged(AuthStatusChanged event, Emitter<AuthState> emit) {
    final user = event.user;
    if (user != null) {
      emit(AuthAuthenticated(user: user));
    } else {
      emit(AuthUnauthenticated());
    }
  }
}
