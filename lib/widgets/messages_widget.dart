import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_web_clone/models/chat.dart';
import 'package:whatsapp_web_clone/models/message.dart';
import 'package:whatsapp_web_clone/models/user_model.dart';
import 'package:whatsapp_web_clone/provider/chat_provider.dart';
import 'package:whatsapp_web_clone/resources/local_colors.dart';

class MessagesWidget extends StatefulWidget {
  final UserModel fromUser;
  final UserModel toUser;

  const MessagesWidget({
    Key? key,
    required this.fromUser,
    required this.toUser,
  }) : super(key: key);

  @override
  State<MessagesWidget> createState() => _MessagesWidgetState();
}

class _MessagesWidgetState extends State<MessagesWidget> {
  final _firestore = FirebaseFirestore.instance;
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  final _streamController = StreamController<QuerySnapshot>.broadcast();
  late StreamSubscription _streamMessages;
  final _messageTextFieldFocus = FocusNode();

  void _sendMessage() {
    String messageText = _messageController.text;
    if (messageText.isNotEmpty) {
      String fromUserId = widget.fromUser.userId;
      final message = Message(
        fromUserId,
        messageText,
        Timestamp.now().toString(),
      );

      String toUserId = widget.toUser.userId;

      //Save the message and last chat on firebase SENDER
      _saveMessageOnFirebase(fromUserId, toUserId, message);
      final chatFrom = Chat(
        fromUserId,
        toUserId,
        message.text,
        widget.toUser.name,
        widget.toUser.email,
        widget.toUser.profileImageUrl,
      );
      _saveChatOnFirebase(chatFrom);

      //Save the message on firebase RECEIVER
      _saveMessageOnFirebase(toUserId, fromUserId, message);
      final chatTo = Chat(
        toUserId,
        fromUserId,
        message.text,
        widget.fromUser.name,
        widget.fromUser.email,
        widget.fromUser.profileImageUrl,
      );
      _saveChatOnFirebase(chatTo);
    }
    _messageTextFieldFocus.requestFocus();
  }

  // This only saves the last message, used to list users chats
  void _saveChatOnFirebase(Chat chat) {
    _firestore
        .collection("chats")
        .doc(chat.fromUserId)
        .collection("last_messages")
        .doc(chat.toUserId)
        // Set here is a update, so it will have only one entry
        .set(chat.toMap());
  }

  // This saves all messages history, used on chat window
  void _saveMessageOnFirebase(
    String fromUserUd,
    String toUserId,
    Message message,
  ) {
    _firestore
        .collection("messages")
        .doc(fromUserUd)
        .collection(toUserId)
        .add(message.toMap());

    _messageController.clear();
  }

  void _addMessageListener({UserModel? toUser}) {
    // with this we can live refresh our messages page directly from firebase
    final stream = _firestore
        .collection("messages")
        .doc(widget.fromUser.userId)
        .collection(toUser?.userId ?? widget.toUser.userId)
        .orderBy("date", descending: false)
        .snapshots();

    _streamMessages = stream.listen((data) {
      _streamController.add(data);
      // to scroll at the end of messages list
      Timer(const Duration(seconds: 1), () {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    });
  }

  void _updateMessageListener() {
    UserModel? toUser = context.watch<ChatProvider>().toUser;
    if (toUser != null) {
      _addMessageListener(toUser: toUser);
    }
  }

  @override
  void dispose() {
    _streamMessages.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _addMessageListener();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // we use this to update the message listeners through provider
    _updateMessageListener();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/bg.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          //Listing messages
          StreamBuilder(
            stream: _streamController.stream,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return const Expanded(
                    child: Center(
                      child: Column(
                        children: [
                          Text("Loading data..."),
                          CircularProgressIndicator()
                        ],
                      ),
                    ),
                  );
                case ConnectionState.active:
                case ConnectionState.done:
                  if (snapshot.hasError) {
                    return const Center(child: Text("Error on loading data!"));
                  } else {
                    final querySnapshot = snapshot.data as QuerySnapshot;
                    List<DocumentSnapshot> messages =
                        querySnapshot.docs.toList();

                    return Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: querySnapshot.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot message = messages[index];

                          // Control to align message balloons from sender and receiver
                          Alignment alignment = Alignment.bottomLeft;
                          Color color = Colors.white;
                          if (widget.fromUser.userId == message["userId"]) {
                            alignment = Alignment.bottomRight;
                            color = const Color(0xffd2ffa5);
                          }

                          Size width = MediaQuery.of(context).size * 0.8;

                          return Align(
                            alignment: alignment,
                            child: Container(
                              // with this, we set a max width to this container
                              constraints: BoxConstraints.loose(width),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.all(6),
                              child: Text(message["text"]),
                            ),
                          );
                        },
                      ),
                    );
                  }
              }
            },
          ),

          //Text Field
          Container(
            padding: const EdgeInsets.all(8),
            color: LocalColors.barBackground,
            child: Row(
              children: [
                //Rounded Text Field
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.insert_emoticon),
                        const SizedBox(
                          width: 4,
                        ),
                        Expanded(
                          child: TextField(
                            focusNode: _messageTextFieldFocus,
                            controller: _messageController,
                            onSubmitted: (_) => _sendMessage(),
                            decoration: const InputDecoration(
                              hintText: "Type a message",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const Icon(Icons.attach_file),
                        const Icon(Icons.camera_alt),
                      ],
                    ),
                  ),
                ),

                //Send Button
                FloatingActionButton(
                  backgroundColor: LocalColors.primary,
                  mini: true,
                  onPressed: _sendMessage,
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
