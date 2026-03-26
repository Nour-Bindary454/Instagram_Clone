import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> login(String email, String password) async {
    emit(LoginLoading());

    try {
      if (email.isEmpty || password.isEmpty) {
        emit(LoginError('Please enter your email and password.'));
        return;
      }

      await auth.signInWithEmailAndPassword(email: email, password: password);
      emit(LoginSuccess());
    } on FirebaseAuthException catch (e) {
      emit(LoginError(_getFirebaseErrorMessage(e.code)));
    } catch (e) {
      emit(LoginError('An unexpected error occurred. Please try again.'));
    }
  }

  String _getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please wait and try again later.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}
