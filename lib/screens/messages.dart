import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_web_clone/models/user_model.dart';
import 'package:whatsapp_web_clone/widgets/messages_widget.dart';

class Messages extends StatefulWidget {
  final UserModel toUser;

  const Messages(this.toUser, {Key? key}) : super(key: key);

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  late UserModel _toUser;
  late UserModel _fromUser;
  final _auth = FirebaseAuth.instance;

  void _getInitialData() {
    _toUser = widget.toUser;
    User? loggedUser = _auth.currentUser;

    if (loggedUser != null) {
      // All these data comes from firebase auth, we need to registar all of this on new user registration
      _fromUser = UserModel(
        loggedUser.uid,
        loggedUser.displayName ?? "",
        loggedUser.email ?? "",
        profileImageUrl: loggedUser.photoURL ?? "",
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _getInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey,
              backgroundImage:
                  CachedNetworkImageProvider(_toUser.profileImageUrl),
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              _toUser.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: SafeArea(
        child: MessagesWidget(
          fromUser: _fromUser,
          toUser: _toUser,
        ),
      ),
    );
  }
}
