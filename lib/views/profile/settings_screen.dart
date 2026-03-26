import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram_clone/cupits/themeCubit/theme_cubit.dart';
import 'package:instagram_clone/views/login/login.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool defaultDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: defaultDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: defaultDark ? Colors.black : Colors.white,
        iconTheme: IconThemeData(color: defaultDark ? Colors.white : Colors.black),
        title: Text(
          'profile_settings'.tr(),
          style: TextStyle(color: defaultDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: [
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) {
              bool isDark = false;
              if (state is ThemeInitial) {
                isDark = state.themeData.brightness == Brightness.dark;
              }

              return SwitchListTile(
                title: Text('settings_dark_mode'.tr(), style: TextStyle(color: defaultDark ? Colors.white : Colors.black)),
                secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: defaultDark ? Colors.white : Colors.black),
                activeColor: Colors.blue,
                value: isDark,
                onChanged: (val) {
                  context.read<ThemeCubit>().toggleTheme();
                },
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text('settings_logout'.tr(), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const Login()), 
                  (route) => false,
                );
              }
            },
          )
        ],
      )
    );
  }
}
