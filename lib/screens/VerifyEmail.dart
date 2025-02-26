import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  VerifyEmailScreen({required this.email});

  @override
  _VerifyEmailScreenState createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isVerifying = false;
  String _message = '';

  Future<void> _verifyEmail() async {
    setState(() {
      _isVerifying = true;
      _message = '';
    });

    final response = await http.post(
      Uri.parse('http://your-backend-url.com/api/verify-email'),
      body: {'email': widget.email},
    );

    setState(() {
      _isVerifying = false;
      if (response.statusCode == 200) {
        _message = 'Email verified successfully!';
      } else {
        _message = 'Failed to verify email. Please try again.';
      }
    });
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
            Text('A verification email has been sent to ${widget.email}.'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isVerifying ? null : _verifyEmail,
              child: _isVerifying ? CircularProgressIndicator() : Text('Verify Email'),
            ),
            SizedBox(height: 20),
            Text(
              _message,
              style: TextStyle(color: _message.contains('successfully') ? Colors.green : Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
