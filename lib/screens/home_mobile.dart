import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_web_clone/widgets/contacts_list.dart';

class HomeMobile extends StatelessWidget {
  HomeMobile({Key? key}) : super(key: key);

  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("WhatsApp"),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
            const SizedBox(
              width: 3.0,
            ),
            IconButton(
                onPressed: () {
                  _auth.signOut().then((value) =>
                      Navigator.pushReplacementNamed(context, "/login"));
                },
                icon: const Icon(Icons.logout)),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 4,
            labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            tabs: [
              Tab(
                text: "Chats",
              ),
              Tab(
                text: "Contacts",
              ),
            ],
          ),
        ),
        body: const SafeArea(
          child: TabBarView(
            children: [
              Center(
                child: Text("Chats"),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: ContactsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
