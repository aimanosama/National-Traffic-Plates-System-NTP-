import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String fullName;
  final String phone;

  const User({required this.id, required this.fullName, required this.phone});

  @override
  List<Object> get props => [id, fullName, phone];
}
