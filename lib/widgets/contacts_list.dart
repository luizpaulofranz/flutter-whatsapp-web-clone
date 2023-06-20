import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_web_clone/models/user_model.dart';

class ContactsList extends StatefulWidget {
  const ContactsList({Key? key}) : super(key: key);

  @override
  State<ContactsList> createState() => _ContactsListState();
}

class _ContactsListState extends State<ContactsList> {
  final _auth = FirebaseAuth.instance;

  final _firestore = FirebaseFirestore.instance;

  late String _loggedUserId;

  Future<List<UserModel>> _getContactsList() async {
    final usersCollection = _firestore.collection("users");
    QuerySnapshot querySnapshot = await usersCollection.get();
    List<UserModel> usersList = [];

    for (DocumentSnapshot item in querySnapshot.docs) {
      String userId = item["userId"];
      if (userId == _loggedUserId) continue;

      String email = item["email"];
      String name = item["name"];
      String profileImageUrl = item["profileImageUrl"];

      UserModel user = UserModel(
        userId,
        name,
        email,
        profileImageUrl: profileImageUrl,
      );
      usersList.add(user);
    }

    return usersList;
  }

  void _getCurrentUser() {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      _loggedUserId = currentUser.uid;
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserModel>>(
      future: _getContactsList(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return const Center(
              child: Column(
                children: [
                  Text("Loading Contacts"),
                  CircularProgressIndicator()
                ],
              ),
            );
          case ConnectionState.active:
          case ConnectionState.done:
            if (snapshot.hasError) {
              return const Center(child: Text("Error on loading contacts!"));
            } else {
              List<UserModel>? usersList = snapshot.data;
              if (usersList != null) {
                return ListView.separated(
                  separatorBuilder: (context, indice) {
                    return const Divider(
                      color: Colors.grey,
                      thickness: 0.2,
                    );
                  },
                  itemCount: usersList.length,
                  itemBuilder: (context, index) {
                    UserModel user = usersList[index];
                    return ListTile(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          "/messages",
                          arguments: user,
                        );
                      },
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey,
                        backgroundImage:
                            CachedNetworkImageProvider(user.profileImageUrl),
                      ),
                      title: Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(8),
                    );
                  },
                );
              }

              return const Center(child: Text("No contacts found!"));
            }
        }
      },
    );
  }
}
