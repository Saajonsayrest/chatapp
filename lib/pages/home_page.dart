import 'package:flutter/material.dart';
import 'package:messenger_app/components/my_drawer.dart';
import 'package:messenger_app/components/user_tile.dart';
import 'package:messenger_app/pages/chat_page.dart';
import 'package:messenger_app/services/auth/auth_service.dart';
import 'package:messenger_app/services/chat/chat_service.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final _chatservice = ChatService();
  final _authservice = AuthService();

  void logout() {
    final auth = AuthService();
    auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('H O M E'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: logout, icon: const Icon(Icons.logout))
        ],
      ),
      drawer: const MyDrawer(),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
        stream: _chatservice.getUserStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("L O A D I N G...");
          } else if (snapshot.hasData) {
            return ListView(
              children: snapshot.data!
                  .map<Widget>(
                      (userData) => _buildUserListItem(userData, context))
                  .toList(),
            );
          } else {
            return const Text("E R R O R");
          }
        });
  }

  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    if (userData['email'] != _authservice.getCurrentUser()!.email) {
      return UserTile(
        text: userData['email'],
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatPage(
                        receiverEmail: userData["email"],
                        receiverID: userData['uid'],
                      )));
        },
      );
    } else {
      return Container();
    }
  }
}
