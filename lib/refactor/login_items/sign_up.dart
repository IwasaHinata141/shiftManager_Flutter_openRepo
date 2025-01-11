import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login.dart';
import 'package:flutter_application_1_shift_manager/refactor/login_items/sign_up_action.dart';

// 新規登録画面
/*
機能：
アカウント新規登録、パスワード再設定画面への遷移
備考：
新規登録はボタンを押して処理に成功すれば完了するが、
メールアドレスの認証を完了しなければログインできない。
メールアドレス認証は送られるリンクへのアクセスが必要。
また、このアプリ画面からはメールアドレス認証が完了したかどうかは分からない
*/

class SignUp extends StatefulWidget {
  @override
  _MyAuthPageState createState() => _MyAuthPageState();
}

class _MyAuthPageState extends State<SignUp> {
  // 入力されたメールアドレス
  String newUserEmail = "";
  // 入力されたパスワード
  String newUserPassword = "";
  // 登録に関する情報を表示
  String infoText = "";
  // 姓を格納
  String lastName = "";
  // 名を格納
  String firstName = "";
  // フルネームを格納
  String fullname = "";
  // ユーザーIDを格納
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
                  // メールアドレス入力フォーム
                  decoration: InputDecoration(labelText: "メールアドレス"),
                  onChanged: (String value) {
                    setState(() {
                      newUserEmail = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                // パスワード入力フォーム
                TextFormField(
                  decoration: InputDecoration(labelText: "パスワード（６文字以上）"),
                  obscureText: true,
                  onChanged: (String value) {
                    setState(() {
                      newUserPassword = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                // 姓の入力フォーム
                TextFormField(
                  decoration: InputDecoration(labelText: "姓"),
                  onChanged: (String value) {
                    setState(() {
                      lastName = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                // 名の入力フォーム
                TextFormField(
                  decoration: InputDecoration(labelText: "名"),
                  onChanged: (String value) {
                    setState(() {
                      firstName = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                // 登録情報を確定
                ElevatedButton(
                  onPressed: () async {
                    // 入力情報が抜けていたらinfoTextを更新して表示
                    try {
                      if (newUserEmail == "" ||
                          newUserPassword == "" ||
                          lastName == "" ||
                          firstName == "") {
                        setState(() {
                          infoText = "全ての項目を埋めてください";
                        });
                        // パスワードは6文字異常で設定可能
                      } else {
                        setState(() {
                          infoText = "処理中...";
                        });
                        // アカウント登録はフルネームで行うため、フルネームを生成
                        fullname = "${lastName}${firstName}";
                        // メールアドレス・パスワードでFirebase authにユーザー登録
                        final FirebaseAuth auth = FirebaseAuth.instance;
                        final UserCredential result =
                            await auth.createUserWithEmailAndPassword(
                          email: newUserEmail,
                          password: newUserPassword,
                        );
                        // メールアドレスの所持を確認（メールアドレスの認証）
                        auth.currentUser!.sendEmailVerification();
                        // ユーザーID取得
                        userId = auth.currentUser?.uid.toString();
                        // Firestoreにユーザーのコレクションを作成するための関数
                        await signUpAction(fullname, userId);
                        // 登録したユーザー情報
                        final User user = result.user!;
                        // メールアドレスの認証をしてもらうために、メッセージを表示
                        // 認証しても画面自体は変わらないため、手動で再度ログイン画面に戻りログインしてもらう
                        setState(() {
                          infoText = "${user.email}に確認メールを送信しました\n確認してください";
                        });
                      }
                    } on FirebaseAuthException catch (e) {
                      // 登録に失敗した際のエラー処理
                      if (e.code == 'email-already-in-use') {
                        // メールアドレスが登録済み
                        setState(() {
                          infoText = "登録済みのメールアドレスです";
                        });
                      } else if (e.code == 'invalid-email') {
                        // 無効なメールアドレスの場合
                        setState(() {
                          infoText = "無効なメールアドレスです";
                        });
                      } else if (e.code == 'operation-not-allowed') {
                        // 使用できないメールアドレス・パスワード
                        setState(() {
                          infoText = "指定されたメールアドレス・パスワードは現在使用出来ません";
                        });
                      } else if (e.code == 'weak-password') {
                        setState(() {
                          infoText = "パスワードは6文字以上にしてください";
                        });
                      }
                    } on Exception {
                      // 予期せぬエラーの場合
                      setState(() {
                        infoText = "処理に失敗しました";
                      });
                    }
                  },
                  child: Text("ユーザー登録"),
                ),
                // ログイン画面に戻るためのボタン
                ElevatedButton(
                  child: Text("ログイン画面に戻る"),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
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
