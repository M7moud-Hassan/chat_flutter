import 'package:bloc/bloc.dart';
import 'package:chat_app/chat/domain/usercases/login_use_case.dart';
import 'package:chat_app/core/bloc/base_bloc.dart';
import 'package:chat_app/core/entities/entity.dart';
import 'package:equatable/equatable.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends BaseBloc<LoginEvent, LoginState> {
  final LoginUSeCase loginUSeCase;
  LoginBloc({required this.loginUSeCase}) : super(LoginInitial()) {
    on<LoginEvent>((event, emit) async {
      if (event is SendLoginEvent) {
        result = await loginUSeCase(event.username);
        emitDone((p0) => {emit(DoneLoginState())});
      }
    });
  }
}
