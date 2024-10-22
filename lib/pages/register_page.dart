import 'package:flutter/material.dart';
import 'package:messenger_app/components/my_button.dart';
import 'package:messenger_app/components/my_textfield.dart';
import 'package:messenger_app/services/auth/auth_service.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key, required this.onTap});

  final void Function()? onTap;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmPwController = TextEditingController();

  void register(BuildContext context) {
    final auth = AuthService();
    if (_pwController.text == _confirmPwController.text) {
      try {
        auth.signUpWithEmailPassword(_emailController.text, _pwController.text);
      } catch (e) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text(e.toString()),
                ));
      }
    } else {
      showDialog(
        context: context,
        builder: (context) =>
            const AlertDialog(title: Text("Passwords don't match")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //logo
                Icon(
                  Icons.message,
                  size: 90,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 50),
                //welcome back message
                Text(
                  "Let's create an account for you",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary, fontSize: 16),
                ),
                const SizedBox(height: 50),

                //email textfield
                MyTextField(
                  hintText: 'Email',
                  controller: _emailController,
                ),
                const SizedBox(height: 20),
                //pw textfield
                MyTextField(
                  hintText: 'Password',
                  obscureText: true,
                  controller: _pwController,
                ),
                const SizedBox(height: 20),
                //pw textfield
                MyTextField(
                  hintText: 'Confirm Password',
                  obscureText: true,
                  controller: _confirmPwController,
                ),

                    //button
                MyButton(
                  text: 'Register',
                  onTap: () => register(context),
                ),

                //register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.primary),
                    ),
                    GestureDetector(
                      onTap: onTap,
                      child: Text(
                        "Login now",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
