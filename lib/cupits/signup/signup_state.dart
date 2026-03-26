part of 'signup_cubit.dart';

@immutable
sealed class SignupState {}

final class SignupInitial extends SignupState {}
class SignupSuccess extends SignupState {}  
class SignupError extends SignupState {
  final String message;
  SignupError(this.message);
}
class SignupLoading extends SignupState {}
