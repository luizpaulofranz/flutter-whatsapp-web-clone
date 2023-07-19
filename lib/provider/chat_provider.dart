import 'package:flutter/widgets.dart';
import 'package:whatsapp_web_clone/models/user_model.dart';

class ChatProvider with ChangeNotifier {
  UserModel? _toUser;

  UserModel? get toUser => _toUser;

  set toUser(UserModel? user) {
    _toUser = user;
    notifyListeners();
  }
}
