import 'package:flutter/material.dart';
import 'package:flutter_application_1_shift_manager/refactor/login_items/sign_up.dart';
import 'package:flutter_application_1_shift_manager/refactor/login_items/login_action.dart';
import 'reset_password.dart';

// ログイン画面
/* 
機能：
ログイン、新規登録画面への遷移、パスワードの再設定画面への遷移
*/

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  // 入力されたメールアドレス
  String loginUserEmail = "";
  // 入力されたパスワード
  String loginUserPassword = "";
  // ログインに関する情報を表示
  String infoText = "";
  // ログイン関数からの戻り値
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
                // メールアドレスの入力フォーム
                TextFormField(
                  decoration: InputDecoration(labelText: "メールアドレス"),
                  onChanged: (String value) {
                    setState(() {
                      loginUserEmail = value;
                    });
                  },
                ),
                // パスワードの入力フォーム
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
                //パスワードを忘れた場合にはパスワード再設定を行う
                Container(
                    height: 40,
                    child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ResetPassword()),
                          );
                        },
                        child: Text("パスワードをお忘れの場合"))),
                Text(infoText),

                //ログインボタン
                ElevatedButton(
                  child: Text("ログイン"),
                  onPressed: () async {
                    // loginActionはログイン処理を行う関数
                    answer = await loginAction(
                        loginUserEmail, loginUserPassword, context);
                    if (mounted) {
                      setState(() {
                        infoText = answer;
                      });
                    }
                  },
                ),
                //新規登録画面への遷移を行うボタン
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
