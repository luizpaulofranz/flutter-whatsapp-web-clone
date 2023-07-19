import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_web_clone/models/user_model.dart';
import 'package:whatsapp_web_clone/provider/chat_provider.dart';
import 'package:whatsapp_web_clone/resources/local_colors.dart';
import 'package:whatsapp_web_clone/resources/responsive.dart';
import 'package:whatsapp_web_clone/widgets/chats_widget.dart';
import 'package:whatsapp_web_clone/widgets/messages_widget.dart';

class HomeWeb extends StatefulWidget {
  const HomeWeb({Key? key}) : super(key: key);

  @override
  State<HomeWeb> createState() => _HomeWebState();
}

class _HomeWebState extends State<HomeWeb> {
  final _auth = FirebaseAuth.instance;
  late UserModel _currentUser;

  void _retrieveCurrentUser() {
    User? firebaseuser = _auth.currentUser;
    if (firebaseuser != null) {
      String userId = firebaseuser.uid;
      String? name = firebaseuser.displayName ?? "";
      String? email = firebaseuser.email ?? "";
      String? profilePicture = firebaseuser.photoURL ?? "";

      _currentUser = UserModel(
        userId,
        name,
        email,
        profileImageUrl: profilePicture,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _retrieveCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final isWeb = Responsive.isWeb(context);

    return Scaffold(
      body: Container(
        color: LocalColors.lightBarBackgroud,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              child: Container(
                color: LocalColors.primary,
                width: width,
                height: height * 0.2,
              ),
            ),
            Positioned(
              top: isWeb ? height * 0.05 : 0,
              bottom: isWeb ? height * 0.05 : 0,
              left: isWeb ? height * 0.05 : 0,
              right: isWeb ? height * 0.05 : 0,
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: ChatSideArea(
                      currentUser: _currentUser,
                    ),
                  ),
                  Expanded(
                    flex: 10,
                    child: MessagesSideArea(
                      currentUser: _currentUser,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ChatSideArea extends StatelessWidget {
  final UserModel currentUser;

  const ChatSideArea({
    Key? key,
    required this.currentUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: LocalColors.lightBarBackgroud,
        border: Border(
          right: BorderSide(color: LocalColors.background, width: 1),
        ),
      ),
      child: Column(
        children: [
          Container(
            color: LocalColors.barBackground,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey,
                  backgroundImage: CachedNetworkImageProvider(
                    currentUser.profileImageUrl,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.message),
                ),
                IconButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut().then(
                          (_) =>
                              Navigator.pushReplacementNamed(context, "/login"),
                        );
                  },
                  icon: const Icon(Icons.logout),
                )
              ],
            ),
          ),

          //Search bar
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration.collapsed(
                      hintText: "Search for a chat",
                    ),
                  ),
                ),
              ],
            ),
          ),

          //Chats list
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: const ChatWidget(),
            ),
          )
        ],
      ),
    );
  }
}

class MessagesSideArea extends StatelessWidget {
  final UserModel currentUser;

  const MessagesSideArea({
    Key? key,
    required this.currentUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    UserModel? toUser = context.watch<ChatProvider>().toUser;

    return toUser != null
        ? Column(
            children: [
              //Top bar
              Container(
                color: LocalColors.barBackground,
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey,
                      backgroundImage: CachedNetworkImageProvider(
                        toUser.profileImageUrl,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      toUser.name,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              //Messages List
              Expanded(
                child: MessagesWidget(
                  fromUser: currentUser,
                  toUser: toUser,
                ),
              )
            ],
          )
        : Container(
            width: width,
            height: height,
            color: LocalColors.lightBarBackgroud,
            child: const Center(
              child: Text("Please, select a chat to see the messages."),
            ),
          );
  }
}
