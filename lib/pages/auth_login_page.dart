import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_app/components/button_big.dart';
import 'package:music_app/components/textfield.dart';
import 'package:music_app/pages/auth_forgotpassword_page.dart';
import 'package:provider/provider.dart';

import '../model/songsprovider.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const LoginPage({super.key, required this.showRegisterPage});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final dynamic songsProvider;

  @override
  void initState(){
    super.initState();
    songsProvider = Provider.of<SongsProvider>(context, listen: false);

  }

  Future<void> signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());
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
    // TODO: implement dispose
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        systemNavigationBarContrastEnforced: true,
        systemNavigationBarColor: Theme.of(context).colorScheme.background,
        systemNavigationBarDividerColor:
        Theme.of(context).colorScheme.background,
        systemNavigationBarIconBrightness:
        Theme.of(context).brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        // backgroundColor: Theme.of(context).colorScheme.background,
        body: Center(
            // child: SingleChildScrollView(
              child: Stack(
                children: [
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
                      'Welcome back!',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "Sign in to your music world",
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                    return const ForgotPasswordPage();
                                  }));
                            },
                            child: const Text(
                              'Forget your password?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    BigButton(buttonText: 'Sign In', ontap: signIn),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Not a member?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: widget.showRegisterPage,
                          child: const Text(
                            ' Register now',
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
          // ),
        ),
      ),
    );
  }
}
