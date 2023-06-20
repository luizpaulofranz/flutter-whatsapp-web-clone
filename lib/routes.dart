import 'package:flutter/material.dart';
import 'package:whatsapp_web_clone/models/user_model.dart';
import 'package:whatsapp_web_clone/screens/home.dart';
import 'package:whatsapp_web_clone/screens/login_register.dart';
import 'package:whatsapp_web_clone/screens/messages.dart';

class Routes {
  static Route<dynamic> generateRoutes(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case "/":
        return MaterialPageRoute(builder: (_) => const LoginRegister());
      case "/login":
        return MaterialPageRoute(builder: (_) => const LoginRegister());
      case "/home":
        return MaterialPageRoute(builder: (_) => const Home());
      case "/messages":
        return MaterialPageRoute(builder: (_) => Messages(args as UserModel));
    }

    return _errorRoute();
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Screen not found!"),
        ),
        body: const Center(
          child: Text("Screen not found!"),
        ),
      );
    });
  }
}
