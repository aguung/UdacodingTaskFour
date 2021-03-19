import 'package:app_task/repository/auth_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository repository;

  LoginCubit({this.repository}) : super(LoginInitial());

  void login() async {
    emit(LoadingLoginState());
    var result = await repository.signInWithGoogle();
    result.fold(
          (errorMessage) => emit(FailureLoginState(errorMessage)),
          (user) => emit(SuccessLoginState(user)),
    );
  }

}
