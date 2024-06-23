import 'package:flutter/material.dart';
import 'package:music_app/pages/auth_login_page.dart';

import '../pages/auth_register_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {

  bool showLogin=true;
  void toggleScreen(){
    setState(() {
      showLogin=!showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(showLogin) {
      return LoginPage(showRegisterPage: toggleScreen);
    } else {
      return RegisterPage(showLoginPage: toggleScreen);
    }
  }
}
