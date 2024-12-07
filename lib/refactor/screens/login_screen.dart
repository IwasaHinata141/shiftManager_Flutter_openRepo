import 'package:flutter/material.dart';
import '../login_items.dart/login.dart';


class LoginScreenPage extends StatelessWidget{
  
  
  @override
  Widget build(BuildContext context) {
    return _LoginScreenPageLayout(
      loginPage: LoginPage(),
    );
  }
}

class _LoginScreenPageLayout extends StatelessWidget {
  const _LoginScreenPageLayout({
    required this.loginPage,
  });

  final Widget loginPage;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: loginPage,
      
    );
  }
}
