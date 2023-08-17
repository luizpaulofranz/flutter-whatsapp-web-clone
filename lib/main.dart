import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_web_clone/provider/chat_provider.dart';
import 'package:whatsapp_web_clone/services/firebase.dart';

import 'resources/local_colors.dart';
import 'routes.dart';

String initialRoute = "/";
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FirebaseServiceImpl().initializeFirebase();

  User? loggedUser = FirebaseAuth.instance.currentUser;
  if (loggedUser != null) {
    initialRoute = "/home";
  }
  runApp(ChangeNotifierProvider(
    create: (context) => ChatProvider(),
    child: const MainApp(),
  ));
}

final ThemeData defaultTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: LocalColors.primary),
);

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: defaultTheme,
      initialRoute: initialRoute,
      onGenerateRoute: Routes.generateRoutes,
    );
  }
}
