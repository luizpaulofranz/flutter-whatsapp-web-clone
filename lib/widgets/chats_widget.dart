import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_web_clone/models/user_model.dart';
import 'package:whatsapp_web_clone/provider/chat_provider.dart';
import 'package:whatsapp_web_clone/resources/responsive.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({Key? key}) : super(key: key);

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  late UserModel _fromUser;
  final _streamController = StreamController<QuerySnapshot>.broadcast();
  late StreamSubscription _streamChats;

  void _addChatListener() {
    final stream = _firestore
        .collection("chats")
        .doc(_fromUser.userId)
        .collection("last_messages")
        .snapshots(); // REAL TIME REFRESH!

    _streamChats = stream.listen((dados) {
      _streamController.add(dados);
    });
  }

  void _loadInitData() {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      String userId = currentUser.uid;
      String? name = currentUser.displayName ?? "";
      String? email = currentUser.email ?? "";
      String? profilePicture = currentUser.photoURL ?? "";

      _fromUser = UserModel(
        userId,
        name,
        email,
        profileImageUrl: profilePicture,
      );
    }

    _addChatListener();
  }

  @override
  void initState() {
    super.initState();
    _loadInitData();
  }

  @override
  void dispose() {
    _streamChats.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _streamController.stream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return const Center(
              child: Column(
                children: [Text("Loading chats"), CircularProgressIndicator()],
              ),
            );
          case ConnectionState.active:
          case ConnectionState.done:
            if (snapshot.hasError) {
              return const Center(child: Text("Error loading chats data!"));
            } else {
              QuerySnapshot querySnapshot = snapshot.data as QuerySnapshot;
              List<DocumentSnapshot> chatList = querySnapshot.docs.toList();

              return ListView.separated(
                separatorBuilder: (context, index) {
                  return const Divider(
                    color: Colors.grey,
                    thickness: 0.2,
                  );
                },
                itemCount: chatList.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot chat = chatList[index];
                  String toUserProfilePicture = chat["toUserProfilePicture"];
                  String toUserName = chat["toUserName"];
                  String toUserEmail = chat["toUserEmail"];
                  String lastMessage = chat["lastMessage"];
                  String toUserId = chat["toUserId"];

                  final toUser = UserModel(
                    toUserId,
                    toUserName,
                    toUserEmail,
                    profileImageUrl: toUserProfilePicture,
                  );

                  return ListTile(
                    onTap: () {
                      if (Responsive.isMobile(context)) {
                        Navigator.pushNamed(
                          context,
                          "/messages",
                          arguments: toUser,
                        );
                      } else {
                        context.read<ChatProvider>().toUser = toUser;
                      }
                    },
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.grey,
                      backgroundImage: CachedNetworkImageProvider(
                        toUser.profileImageUrl,
                      ),
                    ),
                    title: Text(
                      toUser.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      lastMessage,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    contentPadding: const EdgeInsets.all(8),
                  );
                },
              );
            }
        }
      },
    );
  }
}
