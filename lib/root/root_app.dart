import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram_clone/views/mainLayOut/main_lay_out.dart';
import 'package:instagram_clone/cupits/login/login_cubit.dart';
import 'package:instagram_clone/cupits/signup/signup_cubit.dart';
import 'package:instagram_clone/cupits/themeCubit/theme_cubit.dart';
import 'package:instagram_clone/cupits/upload/cubit/upload_cubit.dart';
import 'package:instagram_clone/cupits/story/story_cubit.dart';
import 'package:instagram_clone/views/login/login.dart';
import 'package:instagram_clone/views/profile/profile.dart';
import 'package:instagram_clone/views/reels/reels.dart';
import 'package:instagram_clone/views/shop/shop.dart';
import 'package:instagram_clone/views/signUp/sign_up.dart';
import 'package:instagram_clone/views/favorite/favorite_screen.dart'; // Added import for FavoriteScreen

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ThemeCubit(),
        ),
        BlocProvider(
          create: (context) => LoginCubit(),
        ),
        BlocProvider(
          create: (context) => SignupCubit(),
        ),
         BlocProvider(
          create: (context) => UploadCubit(),
        ),
         BlocProvider(
          create: (context) => StoryCubit(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          ThemeData theme = ThemeData.dark();
          if (state is ThemeInitial) {
            theme = state.themeData;
          }
          return MaterialApp(
            theme: theme,
            routes: {
              'login': (context) => const Login(),
              'signup': (context) => signUp(),
              'shop': (context) => const Shop(),
              'reels': (context) => const Reels(),
              'profile': (context) => const Profile(),
              'favorite': (context) => const FavoriteScreen(),
            },
            debugShowCheckedModeBanner: false,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: FirebaseAuth.instance.currentUser != null
                ? MainLayOut()
                : const Login(),
          );
        },
      ),
    );
  }
}
