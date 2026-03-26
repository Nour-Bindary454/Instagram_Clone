import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram_clone/core/b_button.dart';
import 'package:instagram_clone/core/txt_field.dart';
import 'package:instagram_clone/cupits/signup/signup_cubit.dart';
import 'package:instagram_clone/views/mainLayOut/main_lay_out.dart';


class signUp extends StatefulWidget {
  signUp({super.key});

  @override
  State<signUp> createState() => _signUpState();
}

class _signUpState extends State<signUp> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDark ? Colors.white : Colors.black;
    Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    Color fieldColor = isDark ? const Color(0xff262626) : Colors.grey[200]!;
    Color hintColor = isDark ? const Color(0xffDFDFDF) : Colors.grey[600]!;

    return BlocProvider(
      create: (context) => SignupCubit(),
      child: Scaffold(
        backgroundColor: bgColor,
        body: BlocConsumer<SignupCubit, SignupState>(
          listener: (context, state) {
            if (state is SignupSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Signup Successful!',
                        style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.green),
              );
              Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (context) => MainLayOut()), (route) => false);
            } else if (state is SignupError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.message,
                        style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            return Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/images/insta_logo_w.png', color: textColor),
                  SizedBox(height: 20),
                  TxtField(
                    controller: emailController,
                    obscureText: false,
                    color: fieldColor,
                    hint: 'signup_email_hint'.tr(),
                    hintColor: hintColor,
                  ),
                  SizedBox(height: 20),
                  TxtField(
                    controller: passwordController,
                    obscureText: true,
                    color: fieldColor,
                    hint: 'signup_password_hint'.tr(),
                    hintColor: hintColor,
                  ),
                  SizedBox(height: 20),
                  TxtField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    color: fieldColor,
                    hint: 'signup_confirm_password_hint'.tr(),
                    hintColor: hintColor,
                  ),
                  SizedBox(height: 20),
                  state is SignupLoading
                      ? CircularProgressIndicator(color: textColor)
                      : BButton(
                        height: 50,
                          text: 'signup_button'.tr(),
                          onPressed: () {
                            BlocProvider.of<SignupCubit>(context).signup(
                              emailController.text.trim(),
                              passwordController.text.trim(),
                              confirmPasswordController.text.trim(),
                            );
                          },
                        ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'signup_have_account'.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontFamily: 'inter',
                          color: textColor,
                        ),
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, 'login');
                          },
                          child: Text('signup_login_button'.tr(),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontFamily: 'inter',
                                color: textColor,
                              )))
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
