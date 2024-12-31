import 'package:flutter/material.dart';
import 'package:flutter_application_1_shift_manager/refactor/login_items.dart/sign_up.dart';
import 'package:flutter_application_1_shift_manager/refactor/login_items.dart/login_action.dart';
import '../pagewidgets/reset_password.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  // 入力されたメールアドレス（ログイン）
  String loginUserEmail = "";
  // 入力されたパスワード（ログイン）
  String loginUserPassword = "";
  // 登録・ログインに関する情報を表示
  String infoText = "";
  String answer = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: EdgeInsets.all(32),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 32),
                TextFormField(
                  decoration: InputDecoration(labelText: "メールアドレス"),
                  onChanged: (String value) {
                    setState(() {
                      loginUserEmail = value;
                    });
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "パスワード"),
                  obscureText: true,
                  onChanged: (String value) {
                    setState(() {
                      loginUserPassword = value;
                    });
                  },
                ),
                const SizedBox(height: 3),
                Container(
                    height: 40,
                    child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => ResetPassword()),
                          );
                        },
                        child: Text("パスワードをお忘れの場合"))),
                Text(infoText),
                ElevatedButton(
                  child: Text("ログイン"),
                  onPressed: () async {
                    answer = await loginAction(
                        loginUserEmail, loginUserPassword, context);
                    if (mounted) {
                      setState(() {
                        infoText = answer;
                      });
                    }
                  },
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  child: Text("新規登録"),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SignUp()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
