import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:whatsapp_web_clone/services/firebase_service.dart';

class FirebaseServiceImpl extends FirebaseService {
  @override
  Future<void> initializeFirebase() async {
    // Hide these 
    const options = FirebaseOptions(
      apiKey: 'mock', 
      appId: 'mock-mock',
      messagingSenderId: 'number',
      projectId: 'project-id',
      authDomain: 'mock.firebaseapp.com',
      storageBucket: 'mock.appspot.com',
    );
    if (Platform.isAndroid) {
      await Firebase.initializeApp(options: options);
    } else {
      await Firebase.initializeApp(name: "WhatsappClone", options: options);
    }
  }
}
