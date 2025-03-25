import 'package:ecommerce/api.dart';  // Ensure baseUrl is correctly set here
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  const VerifyEmailScreen({super.key, required this.email});

  @override
  _VerifyEmailScreenState createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isVerifying = false;
  bool _isResending = false;
  String _message = '';
  final TextEditingController _otpController = TextEditingController();

  // 🔹 Function to verify OTP
  Future<void> _verifyOTP() async {
    setState(() {
      _isVerifying = true;
      _message = '';
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'), // Ensure this matches your backend
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": widget.email,
          "otp": _otpController.text.trim(),
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _message = '✅ Email verified successfully!';
        });
        // Navigate to login page or dashboard after success
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pushReplacementNamed(context, '/login');
        });
      } else {
        setState(() {
          _message = '❌ ${responseData['message'] ?? 'Invalid OTP. Please try again.'}';
        });
      }
    } catch (e) {
      setState(() {
        _message = '❌ Error: Unable to connect to server';
      });
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  // 🔹 Function to resend OTP
  Future<void> _resendOTP() async {
    setState(() {
      _isResending = true;
      _message = '';
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/resend-otp'),  // Ensure this is correct
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": widget.email}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _message = '✅ OTP resent successfully!';
        });
      } else {
        setState(() {
          _message = '❌ ${responseData['message'] ?? 'Failed to resend OTP.'}';
        });
      }
    } catch (e) {
      setState(() {
        _message = '❌ Error: Unable to connect to server';
      });
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Verify Email')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enter the OTP sent to ${widget.email}.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: 'Enter OTP',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isVerifying ? null : _verifyOTP,
              child: _isVerifying
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text('Verify OTP'),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: _isResending ? null : _resendOTP,
              child: _isResending
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('Resend OTP'),
            ),
            SizedBox(height: 20),
            if (_message.isNotEmpty)
              Text(
                _message,
                style: TextStyle(
                  color: _message.startsWith('✅') ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
