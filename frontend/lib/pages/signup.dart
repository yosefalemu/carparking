import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _companyNameController = TextEditingController();

  Future<void> signup() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final companyName = _companyNameController.text;

    final String serverUrl = 'https://carparking-rfuc.vercel.app/user/register';

    final Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> requestBody = {
      'email': email,
      'password': password,
      'companyName': companyName,
    };

    try {
      final response = await http.post(
        Uri.parse(serverUrl),
        headers: requestHeaders,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201) {
        print('User created successfully');
        Navigator.pushNamed(context, "/login");
      } else if (response.statusCode == 400) {
        print('User already exists');
      } else {
        print('Failed to create user: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color.fromARGB(255, 7, 216, 14),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
              SizedBox(height: 16.0),
              TextField(
                controller: _emailController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
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
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _passwordController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                obscureText: true,
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _companyNameController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Parking Name",
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
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: signup,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding:
                      EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  textStyle:
                      TextStyle(fontSize: 18.0, fontWeight: FontWeight.w900),
                  backgroundColor: Color.fromARGB(255, 218, 8, 61),
                ),
                child: Text("Sign Up"),
              ),
              SizedBox(height: 16.0),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, "/login"),
                child: Text("Already have an account?"),
                style: TextButton.styleFrom(
                  foregroundColor: Color.fromARGB(255, 8, 64, 218),
                  textStyle: TextStyle(fontSize: 16.0),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
