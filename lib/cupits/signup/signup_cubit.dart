import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

part 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  SignupCubit() : super(SignupInitial());

  FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> signup(
      String email, String password, String confirmPassword) async {
    emit(SignupLoading());

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      emit(SignupError('All fields are required!'));
      return;
    }

    if (password != confirmPassword) {
      emit(SignupError('Password and confirm password do not match!'));
      return;
    }

    try {
      await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      emit(SignupSuccess());
      
    } on FirebaseAuthException catch (e) {
      emit(SignupError(_getFirebaseErrorMessage(e)));
    } catch (e) {
      emit(SignupError('An unexpected error occurred.'));
    }
  }

  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already in use.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'invalid-email':
        return 'The email address is invalid.';
      default:
        return 'Signup failed. Please try again.';
    }
  }
}
