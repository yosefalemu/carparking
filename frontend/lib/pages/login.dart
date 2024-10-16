import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> login() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Validate form
      final email = _emailController.text;
      final password = _passwordController.text;

      const String serverUrl = 'https://carparking-rfuc.vercel.app/user/login';

      final Map<String, String> requestHeaders = {
        'Content-Type': 'application/json',
      };

      final Map<String, dynamic> requestBody = {
        'email': email,
        'password': password,
      };

      try {
        final response = await http.post(
          Uri.parse(serverUrl),
          headers: requestHeaders,
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200) {
          // Changed to 200 for successful login
          print('Login successful');
          Navigator.pushNamed(context, "/addcar");
        } else if (response.statusCode == 401) {
          // Unauthorized status code
          print('Invalid credentials');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid email or password')),
          );
        } else {
          print('Failed to login: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login failed')),
          );
        }
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 18, 228, 25),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey, // Added form widget
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipOval(
                  child: Image.asset(
                    "assets/images/landing.png",
                    width: 100,
                    height: 100,
                    fit: BoxFit.fill,
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: login,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    textStyle: const TextStyle(
                        fontSize: 18.0, fontWeight: FontWeight.w900),
                    backgroundColor: const Color.fromARGB(255, 218, 8, 61),
                  ),
                  child: const Text("Login"),
                ),
                const SizedBox(height: 16.0),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, "/signup"),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 8, 64, 218),
                    textStyle: const TextStyle(fontSize: 16.0),
                  ),
                  child: const Text("Don't have an account?"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
