import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      await Future.delayed(const Duration(seconds: 2)); // Simulate network call
      if (event.phone == '01012345678' && event.password == 'password') {
        emit(AuthSuccess());
      } else {
        emit(const AuthFailure(error: 'Invalid credentials'));
      }
    });

    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      await Future.delayed(const Duration(seconds: 2)); // Simulate network call
      // In a real app, you would register the user here
      emit(AuthSuccess());
    });
  }
}
