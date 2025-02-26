import 'dart:convert';
import 'package:ecommerce/screens/Login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../api.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;

  const VerifyEmailScreen({super.key, required this.email});

  @override
  _VerifyEmailScreenState createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isVerified = false;
  bool _isLoading = false;
  String _message = "Please check your email for the verification link.";

  @override
  void initState() {
    super.initState();
    checkVerificationStatus();
  }

  Future<void> checkVerificationStatus() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/check-verification?email=${widget.email}'),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData["isVerified"] == true) {
          setState(() {
            _isVerified = true;
            _message = "Your email has been verified successfully!";
          });

          // Delay and navigate to login
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          }
        }
      } else {
        setState(() {
          _message = "Unable to verify email. Try again later.";
        });
      }
    } catch (e) {
      setState(() {
        _message = "Error checking verification status. Please try again.";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> resendVerificationEmail() async {
    if (_isLoading) return; // Prevent multiple API calls

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/resend-verification'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": widget.email}),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          _message = "Verification email sent again. Check your inbox.";
        });
      } else {
        setState(() {
          _message = responseData["message"] ?? "Failed to resend email.";
        });
      }
    } catch (e) {
      setState(() {
        _message = "Error: Unable to connect to server.";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Email")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _isVerified
                ? const Icon(Icons.check_circle, color: Colors.green, size: 100)
                : const Icon(Icons.email, color: Colors.deepPurple, size: 100),
            const SizedBox(height: 20),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (!_isVerified)
              ElevatedButton(
                onPressed: _isLoading ? null : resendVerificationEmail,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Resend Verification Email"),
              ),
          ],
        ),
      ),
    );
  }
}
