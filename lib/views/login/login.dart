import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram_clone/core/b_button.dart';
import 'package:instagram_clone/core/txt_field.dart';
import 'package:instagram_clone/cupits/login/login_cubit.dart';
import 'package:instagram_clone/views/mainLayOut/main_lay_out.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDark ? Colors.white : Colors.black;
    Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    Color fieldColor = isDark ? const Color(0xff262626) : Colors.grey[200]!;
    Color hintColor = isDark ? const Color(0xffDFDFDF) : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: bgColor,
      body: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Login Successful!',
                      style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.green),
            );
            Navigator.pushAndRemoveUntil(
                context, MaterialPageRoute(builder: (context) => MainLayOut()), (route) => false);
          } else if (state is LoginError) {
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
                  hint: 'login_email_hint'.tr(),
                  hintColor: hintColor,
                ),
                SizedBox(height: 20),
                TxtField(
                  controller: passwordController,
                  obscureText: true,
                  color: fieldColor,
                  hint: 'login_password_hint'.tr(),
                  hintColor: hintColor,
                ),
                SizedBox(height: 20),
                state is LoginLoading
                    ? CircularProgressIndicator(color: textColor)
                    : BButton(
                      height: 50,
                        text: 'login_button'.tr(),
                        onPressed: () {
                          context.read<LoginCubit>().login(
                                emailController.text.trim(),
                                passwordController.text.trim(),
                              );
                        },
                      ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'login_no_account'.tr(),
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontFamily: 'inter',
                        color: textColor,
                      ),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, 'signup');
                        },
                        child: Text('login_register_button'.tr(),
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
    );
  }
}
