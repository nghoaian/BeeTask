import 'package:bee_task/data/repository/UserRepository.dart';
import 'package:bloc/bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final UserRepository userRepository;

  AuthBloc({required this.firebaseAuth, required this.firestore})
      : userRepository = FirebaseUserRepository(firestore: firestore, firebaseAuth: firebaseAuth),
        super(AuthInitial()) {
    on<AuthStatusChanged>(_onAuthStatusChanged);
    on<LoginRequested>(_onLoginRequested);
    on<SignupRequested>(_onSignupRequested);
    on<ChangePasswordRequested>(_onChangePasswordRequested);

    // Kiểm tra trạng thái đăng nhập
    firebaseAuth.authStateChanges().listen((user) {
      add(AuthStatusChanged(user: user));
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

  // Xử lý đăng nhập
  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await firebaseAuth.signInWithEmailAndPassword(
        email: event.email.trim(),
        password: event.password.trim(),
      );
      emit(AuthAuthenticated(user: firebaseAuth.currentUser!));
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(errorMessage: e.message ?? "Unknown error"));
    }
  }

  // Xử lý đăng ký
  Future<void> _onSignupRequested(
      SignupRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // Kiểm tra username đã tồn tại chưa
      bool usernameExists = await userRepository.checkIfUsernameExist(event.username);
      if (usernameExists) {
        emit(AuthSignUpFailure(errorMessage: "Username đã tồn tại!"));
        return;
      }

      // Tạo tài khoản mới
      await firebaseAuth.createUserWithEmailAndPassword(
        email: event.email.trim(),
        password: event.password.trim(),
      );

      // Thêm thông tin user vào Firestore
      await userRepository.addUserName(event.username, event.email);

      emit(AuthSignedUp());
    } on FirebaseAuthException catch (e) {
      emit(AuthSignUpFailure(errorMessage: e.message ?? "Unknown error"));
    }
  }

  // Xử lý đổi mật khẩu
  Future<void> _onChangePasswordRequested(
      ChangePasswordRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      User? user = firebaseAuth.currentUser;
      if (user == null) {
        emit(ChangePasswordFailure(errorMessage: "Không tìm thấy user."));
        return;
      }

      // Xác thực lại user
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: event.currentPassword,
      );

      // Xác thực lại mật khẩu cũ của user
      try {
        await user.reauthenticateWithCredential(credential);
      } on FirebaseAuthException catch (_) {
        emit(ChangePasswordFailure(
            errorMessage: "Mật khẩu hiện tại không đúng. Vui lòng thử lại."));
        return;
      }

      if (event.newPassword != event.confirmPassword) {
        emit(ChangePasswordFailure(
            errorMessage: "New password and confirm password do not match!"));
        return;
      }
      await user.updatePassword(event.newPassword);

      emit(ChangePasswordSuccess());
    } on FirebaseAuthException catch (e) {
      emit(ChangePasswordFailure(
          errorMessage:
              e.message ?? "Password change failed. Please try again."));
    }
  }
}