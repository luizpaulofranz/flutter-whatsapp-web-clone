import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_web_clone/models/message.dart';
import 'package:whatsapp_web_clone/models/user_model.dart';
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

  void _sendMessage() {
    String messageText = _messageController.text;
    if (messageText.isNotEmpty) {
      String fromUserId = widget.fromUser.userId;
      final message = Message(
        fromUserId,
        messageText,
        Timestamp.now().toString(),
      );

      //Save the message on firebase
      String toUserId = widget.toUser.userId;
      _saveMessageOnFirebase(fromUserId, toUserId, message);
    }
  }

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
          Expanded(
            child: Container(
              width: screenWidth,
              color: Colors.transparent,
              child: const Text("Messages"),
            ),
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
                            controller: _messageController,
                            decoration: const InputDecoration(
                                hintText: "Type a message",
                                border: InputBorder.none),
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
