import 'package:ecommerce/screens/Login.dart';
import 'package:ecommerce/screens/Signup.dart';
import 'package:ecommerce/screens/home_screen.dart';
import 'package:ecommerce/screens/trendingpage.dart';
import 'package:ecommerce/screens/VerifyEmail.dart'; // Import VerifyEmail
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'E-Commerce App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginPage(),
          '/signup': (context) => SignupPage(),
          '/home': (context) => MyHomePage(), // Home Screen with Bottom Navigation
          '/trending': (context) => TrendingPage(),
          '/verify-email': (context) => VerifyEmailScreen(email: ''), // Route for email verification
        },
      ),
    );
  }
}
