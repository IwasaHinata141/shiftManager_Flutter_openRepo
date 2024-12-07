import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1_shift_manager/refactor/screens/login_screen.dart';
import 'package:flutter_application_1_shift_manager/refactor/login_items.dart/sign_up_action.dart';

class SignUp extends StatefulWidget {
  @override
  _MyAuthPageState createState() => _MyAuthPageState();
}

class _MyAuthPageState extends State<SignUp> {
  // 入力されたメールアドレス
  String newUserEmail = "";
  // 入力されたパスワード
  String newUserPassword = "";
  // 登録・ログインに関する情報を表示
  String infoText = "";
  //uidを格納
  String lastName = "";
  String firstName = "";
  String fullname = "";
  var userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: EdgeInsets.all(32),
            child: Column(
              children: <Widget>[
                TextFormField(
                  // テキスト入力のラベルを設定
                  decoration: InputDecoration(labelText: "メールアドレス"),
                  onChanged: (String value) {
                    setState(() {
                      newUserEmail = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: InputDecoration(labelText: "パスワード（６文字以上）"),
                  // パスワードが見えないようにする
                  obscureText: true,
                  onChanged: (String value) {
                    setState(() {
                      newUserPassword = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  // テキスト入力のラベルを設定
                  decoration: InputDecoration(labelText: "氏"),
                  onChanged: (String value) {
                    setState(() {
                      lastName = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  // テキスト入力のラベルを設定
                  decoration: InputDecoration(labelText: "名"),
                  onChanged: (String value) {
                    setState(() {
                      firstName = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      if (newUserEmail == "" ||
                          newUserPassword == "" ||
                          lastName == "" ||
                          firstName == "") {
                        setState(() {
                          infoText = "全ての項目を埋めてください";
                        });
                      }else if(newUserPassword.length <6){
                        setState(() {
                          infoText = "パスワードは6文字以上にしてください";
                        });
                      } else {
                        setState(() {
                          infoText = "処理中...";
                        });
                        fullname = "${lastName}${firstName}";
                        // メール/パスワードでユーザー登録
                        final FirebaseAuth auth = FirebaseAuth.instance;
                        final UserCredential result =
                            await auth.createUserWithEmailAndPassword(
                          email: newUserEmail,
                          password: newUserPassword,
                        );

                        auth.currentUser!.sendEmailVerification();
                        userId = auth.currentUser?.uid.toString();
                        await signUpAction(fullname, userId);
                        // 登録したユーザー情報
                        final User user = result.user!;
                        setState(() {
                          infoText = "${user.email}に確認メールを送信しました\n確認してください";
                        });
                      }
                    } catch (e) {
                      // 登録に失敗した場合
                      setState(() {
                        infoText ="このアドレスは既に使われています";
                      });
                    }
                  },
                  child: Text("ユーザー登録"),
                ),
                ElevatedButton(
                  child: Text("ログイン画面に戻る"),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LoginScreenPage()),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(infoText),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
