import 'package:flutter/material.dart';
import 'package:frontend/pages/addcar.dart';
import 'package:frontend/pages/landing.dart';
import 'package:frontend/pages/login.dart';
import 'package:frontend/pages/punish.dart';
import 'package:frontend/pages/rate.dart';
import 'package:frontend/pages/signup.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: "/",
    routes: {
      "/": (context) => LandingPage(),
      "/login": (context) => LoginPage(),
      "/signup": (context) => SignupPage(),
      "/addcar": (context) => AddCar(),
      "/rate": (context) => Rate(),
      "/punish": (context) => PunishPage()
    },
  ));
}
