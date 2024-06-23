import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:music_app/components/button_big.dart';
import 'package:music_app/components/textfield.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;

  const RegisterPage({super.key, required this.showLoginPage});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());
      addUser(_emailController.text, _passwordController.text);
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

  Future<void> addUser(String email, String password) async {
    await FirebaseFirestore.instance.collection('users').doc(email).set({
      'email': email,
      'password': password,
    });
    await FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .collection('tracks')
        .doc('null')
        .set({});
    await FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .collection('playlists')
        .doc('null')
        .set({});
    await FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .collection('albums')
        .doc('null')
        .set({});
    await FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .collection('artists')
        .doc('null')
        .set({});
    await FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .collection('history')
        .doc('null')
        .set({});
    await FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .collection('search')
        .doc('null')
        .set({});
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        //   child: SingleChildScrollView(
            child: Stack(
              children:[
                Image.asset('lib/assets/login_image.jpg',height: screenWidth,width: screenWidth,fit: BoxFit.cover,),
                // CachedNetworkImage(
                //   width: screenWidth,
                //   height: screenWidth,
                //   fit: BoxFit.cover,
                //   imageUrl: widget.artist.artistProfile,
                //   // imageBuilder: (context, imageProvider) {
                //   // },
                //   placeholder: (context, url) =>
                //       Image.asset('lib/assets/artist.png'),
                //   errorWidget: (context, url, error) =>
                //       Image.asset('lib/assets/artist.png'),
                //   // ),
                // ),
                Container(
                  width: screenWidth,
                  height: screenWidth,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).colorScheme.background.withOpacity(0.3),
                        Theme.of(context).colorScheme.background.withOpacity(0.3),
                        Theme.of(context).colorScheme.background.withOpacity(0.3),
                        Theme.of(context).colorScheme.background.withOpacity(0.4),
                        Theme.of(context).colorScheme.background.withOpacity(0.5),
                        Theme.of(context).colorScheme.background.withOpacity(0.5),
                        Theme.of(context).colorScheme.background.withOpacity(0.8),
                        Theme.of(context).colorScheme.background,
                      ],
                    ),
                  ),
                ),
                Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Hello there!',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    'Register below',
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  MyTextField(
                      input: _emailController, obscure: false, hint: 'Email'),
                  const SizedBox(
                    height: 10,
                  ),
                  MyTextField(
                      input: _passwordController,
                      obscure: true,
                      hint: 'Password'),
                  const SizedBox(
                    height: 10,
                  ),
                  BigButton(buttonText: 'Sign Up', ontap: signUp),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already a member?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.showLoginPage,
                        child: const Text(
                          ' Login now',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20,)
                ],
              ),]
            ),
          // ),
        ),
      // ),
    );
  }
}
