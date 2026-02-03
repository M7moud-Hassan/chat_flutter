part of 'login_bloc.dart';

sealed class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

final class SendLoginEvent extends LoginEvent {
  final BaseEntity username;

  const SendLoginEvent({required this.username});
}
