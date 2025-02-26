import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ecommerce/screens/Login.dart';
import 'package:ecommerce/screens/VerifyEmail.dart'; // New verification screen
import 'package:flutter/material.dart';
import '../api.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: SignupPage());
  }
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _isLoading = false;

  Future<void> signupUser() async {
    String name = nameController.text.trim();
    String phone = phoneController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty || phone.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      showSnackBar("Please fill all fields");
      return;
    }

    if (password != confirmPassword) {
      showSnackBar("Passwords do not match");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "phone": phone,
          "email": email,
          "password": password,
        }),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 201) {
        showSnackBar("Signup successful! Please verify your email.");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => VerifyEmailScreen(email: email)),
        );
      } else {
        showSnackBar(responseData["message"] ?? "Signup failed");
      }
    } catch (e) {
      showSnackBar("Error: Unable to connect to server");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_add, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "Sign up to get started",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              buildTextField("Full Name", Icons.person, nameController),
              const SizedBox(height: 10),
              buildTextField("Phone Number", Icons.phone, phoneController, keyboardType: TextInputType.phone),
              const SizedBox(height: 10),
              buildTextField("Email", Icons.email, emailController),
              const SizedBox(height: 10),
              buildPasswordField("Password", passwordController, true),
              const SizedBox(height: 10),
              buildPasswordField("Confirm Password", confirmPasswordController, false),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _isLoading ? null : signupUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Sign Up", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: navigateToLogin,
                child: const Text(
                  "Already have an account? Login",
                  style: TextStyle(color: Colors.deepPurple),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, IconData icon, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget buildPasswordField(String label, TextEditingController controller, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? !_passwordVisible : !_confirmPasswordVisible,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock, color: Colors.deepPurple),
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}