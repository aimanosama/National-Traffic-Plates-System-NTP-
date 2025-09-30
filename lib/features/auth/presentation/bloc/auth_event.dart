import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String phone;
  final String password;

  const LoginRequested({required this.phone, required this.password});

  @override
  List<Object> get props => [phone, password];
}

class SignUpRequested extends AuthEvent {
  final String fullName;
  final String phone;
  final String password;

  const SignUpRequested({
    required this.fullName,
    required this.phone,
    required this.password,
  });

  @override
  List<Object> get props => [fullName, phone, password];
}
