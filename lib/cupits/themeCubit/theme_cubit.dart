import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:shared_preferences/shared_preferences.dart';
part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeInitial(ThemeData.light())) {
    _loadTheme();
  }

  void toggleTheme() async {
    final isDarkMode = state is ThemeInitial &&
        (state as ThemeInitial).themeData.brightness == Brightness.dark;

    final newTheme = isDarkMode 
      ? ThemeData.light().copyWith(
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(backgroundColor: Colors.white, elevation: 0, iconTheme: IconThemeData(color: Colors.black), titleTextStyle: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(backgroundColor: Colors.white, selectedItemColor: Colors.black, unselectedItemColor: Colors.grey),
          iconTheme: const IconThemeData(color: Colors.black),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.black),
            bodyMedium: TextStyle(color: Colors.black),
            titleMedium: TextStyle(color: Colors.black),
          ),
        )
      : ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.black,
          appBarTheme: const AppBarTheme(backgroundColor: Colors.black, elevation: 0, iconTheme: IconThemeData(color: Colors.white), titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(backgroundColor: Colors.black, selectedItemColor: Colors.white, unselectedItemColor: Colors.grey),
          iconTheme: const IconThemeData(color: Colors.white),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white),
            titleMedium: TextStyle(color: Colors.white),
          ),
        );
    emit(ThemeInitial(newTheme));

    // حفظ الثيم في Shared Preferences
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', !isDarkMode);
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? true;
    final newTheme = !isDarkMode 
      ? ThemeData.light().copyWith(
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(backgroundColor: Colors.white, elevation: 0, iconTheme: IconThemeData(color: Colors.black), titleTextStyle: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(backgroundColor: Colors.white, selectedItemColor: Colors.black, unselectedItemColor: Colors.grey),
          iconTheme: const IconThemeData(color: Colors.black),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.black),
            bodyMedium: TextStyle(color: Colors.black),
            titleMedium: TextStyle(color: Colors.black),
          ),
        )
      : ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.black,
          appBarTheme: const AppBarTheme(backgroundColor: Colors.black, elevation: 0, iconTheme: IconThemeData(color: Colors.white), titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(backgroundColor: Colors.black, selectedItemColor: Colors.white, unselectedItemColor: Colors.grey),
          iconTheme: const IconThemeData(color: Colors.white),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white),
            titleMedium: TextStyle(color: Colors.white),
          ),
        );
    emit(ThemeInitial(newTheme));
  }
}
