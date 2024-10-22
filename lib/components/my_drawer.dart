import 'package:flutter/material.dart';
import 'package:messenger_app/pages/setting_page.dart';
import 'package:messenger_app/services/auth/auth_service.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  void logout() {
    final auth = AuthService();
    auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: Center(
              child: Icon(
                Icons.message,
                color: Theme.of(context).colorScheme.primary,
                size: 50,
              ),
            ),
          ),
          DrawerItems(
            text: 'H O M E',
            icon: Icons.home,
            onTap: () => Navigator.pop(context),
          ),
          DrawerItems(
            text: 'S E T T I N G S',
            icon: Icons.settings,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const SettingPage()));
            },
          ),
          DrawerItems(text: 'L O G O U T', icon: Icons.logout, onTap: logout),
        ],
      ),
    );
  }
}

class DrawerItems extends StatelessWidget {
  const DrawerItems(
      {super.key, required this.text, required this.icon, this.onTap});

  final String text;
  final IconData icon;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: onTap,
        child: ListTile(
          title: Text(text),
          leading: Icon(icon),
        ),
      ),
    );
  }
}
