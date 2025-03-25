 // Import for platform check
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'package:http/http.dart' as http;
import 'package:ecommerce/screens/Login.dart';
import 'package:ecommerce/screens/Signup.dart';
import 'package:ecommerce/screens/home_screen.dart';
import 'package:ecommerce/screens/trendingpage.dart';
import 'package:ecommerce/screens/VerifyEmail.dart';
import 'package:ecommerce/api.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      // Only handle deep links for mobile platforms
      handleDeepLinks();
    } else {
      // Handle web deep linking
      handleWebDeepLinks();
    }
  }

  void handleDeepLinks() async {
    uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.pathSegments.contains('activate')) {
        String token = uri.pathSegments.last;
        activateAccount(token);
      }
    });
  }

  void handleWebDeepLinks() {
    final uri = Uri.base; // Gets the current URL in Flutter Web
    if (uri.pathSegments.contains('activate')) {
      String token = uri.pathSegments.last;
      activateAccount(token);
    }
  }

  Future<void> activateAccount(String token) async {
    final response = await http.get(Uri.parse("$baseUrl/api/auth/activate/$token"));

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Account activated successfully! Please log in.")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to activate account. Try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Commerce App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/home': (context) => MyHomePage(),
        '/trending': (context) => TrendingPage(),
        '/verify-email': (context) => VerifyEmailScreen(email: ''),
      },
    );
  }
}
