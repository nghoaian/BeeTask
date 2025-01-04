import 'package:equatable/equatable.dart';

abstract class AccountEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchUserNameRequested extends AccountEvent {}

class UpdateUserNameRequested extends AccountEvent {
  final String username;

  UpdateUserNameRequested({required this.username});

  @override
  List<Object> get props => [username];
}

class UpdateUserImageRequested extends AccountEvent {
  final String userImage;

  UpdateUserImageRequested({required this.userImage});

  @override
  List<Object> get props => [userImage];
}