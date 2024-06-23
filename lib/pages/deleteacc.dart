import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_app/components/button_big.dart';
import 'package:music_app/components/textfield.dart';

class DeleleAccount extends StatefulWidget {
  const DeleleAccount({super.key});

  @override
  State<DeleleAccount> createState() => _DeleleAccountState();
}

class _DeleleAccountState extends State<DeleleAccount> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  Future<void> _deleteAcc() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(_email.text).delete();
      await FirebaseAuth.instance.userChanges().listen((event) async {
        if (event!.email == _email.text) {
          await event.delete();
        }
      });
    } on FirebaseAuthException catch (e) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message.toString()),
            );
          });
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete account'),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            MyTextField(input: _email, obscure: false, hint: 'Confirm email'),
            const SizedBox(
              height: 10,
            ),
            MyTextField(
                input: _password, obscure: true, hint: 'Confirm password'),
            const SizedBox(
              height: 10,
            ),
            BigButton(
                buttonText: 'Delele account',
                ontap: () {
                  _deleteAcc();
                  // Navigator.of(context, rootNavigator: true).push(
                  //     MaterialPageRoute(
                  //         builder: (context) => const PlaylistCreate()));
                }),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
