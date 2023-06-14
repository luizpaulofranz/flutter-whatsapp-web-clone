import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'resources/local_colors.dart';
import 'routes.dart';

Future<void> main() async {
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyBbfoasdgKz5wvcKk21NgQbXGf9GebzNA8',
      appId: '1:484346022413:web:eb729bd0f5b5e3987a2344',
      messagingSenderId: '484346022413',
      projectId: 'flutter-whatsapp-1d294',
      authDomain: 'flutter-whatsapp-1d294.firebaseapp.com',
      storageBucket: 'flutter-whatsapp-1d294.appspot.com',
    ),
  );
  runApp(const MainApp());
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
      initialRoute: "/",
      onGenerateRoute: Routes.generateRoutes,
    );
  }
}
