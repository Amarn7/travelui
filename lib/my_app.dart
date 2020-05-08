import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travel/main_page.dart';

class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false ,
      theme:ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF)),
    home: MainPage(),
    );
  }
}
