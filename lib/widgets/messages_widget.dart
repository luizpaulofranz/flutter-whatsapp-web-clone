import 'package:flutter/material.dart';
import 'package:whatsapp_web_clone/resources/local_colors.dart';

class MessagesWidget extends StatefulWidget {
  const MessagesWidget({Key? key}) : super(key: key);

  @override
  State<MessagesWidget> createState() => _MessagesWidgetState();
}

class _MessagesWidgetState extends State<MessagesWidget> {
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
            color: Colors.orange,
            child: const Text("Messages"),
          )),

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
                    child: const Row(
                      children: [
                        Icon(Icons.insert_emoticon),
                        SizedBox(
                          width: 4,
                        ),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                                hintText: "Type a message",
                                border: InputBorder.none),
                          ),
                        ),
                        Icon(Icons.attach_file),
                        Icon(Icons.camera_alt),
                      ],
                    ),
                  ),
                ),

                //Send Button
                FloatingActionButton(
                  backgroundColor: LocalColors.primary,
                  mini: true,
                  onPressed: () {},
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
