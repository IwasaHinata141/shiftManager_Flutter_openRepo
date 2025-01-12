import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1_shift_manager/refactor/login_items/login.dart';

// パスワードの再設定画面
/*
機能：
メールアドレスにパスワード再設定のリンクを送信する
備考：
パスワード再設定はリンクにアクセスしてから完了する
このアプリ側からは再設定が完了したかどうかは分からない
*/

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPassword();
}

class _ResetPassword extends State<ResetPassword> {
  // パスコード再設定に関する情報を表示
  String infoText = "";
  // 入力されたメールアドレス
  String emailaddress = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // アップバー（ページ上部）
      appBar: AppBar(
        backgroundColor: Colors.grey[350],
        centerTitle: true,
        title: const Text("パスワード再設定"),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          // ログインページへ戻る
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => LoginPage()));
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  height: 400,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey)),
                  child: Column(
                    children: [
                      // パスワード再設定の手順の解説の文章
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: const Text(
                            "パスワードを忘れてしまった場合、パスワードの再設定が必要になります\n手順\n①アカウントのメールアドレスに認証メールを送信\n②認証メールのリンクにアクセス\n③リンク先で新しいパスワードを設定\n④shiftmanagerアプリでログイン"),
                      ),
                      SizedBox(
                        height: 30,
                        width: double.infinity,
                        child: Container(
                          padding: const EdgeInsets.only(left: 20),
                          alignment: Alignment.bottomLeft,
                          height: 30,
                          width: 100,
                          child: const Text("メールアドレス"),
                        ),
                      ),
                      // メールアドレスの入力フォーム
                      Container(
                        padding: const EdgeInsets.only(right: 10, left: 10),
                        height: 50,
                        width: double.infinity,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          child: TextField(
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                            ),
                            onChanged: (String value) {
                              setState(() {
                                emailaddress = value;
                              });
                            },
                          ),
                        ),
                      ),
                      // 認証メールの送信の起動ボタン
                      Container(
                        padding: const EdgeInsets.only(top: 10),
                        height: 50,
                        width: 200,
                        child: ElevatedButton(
                          onPressed: () async {
                            // 送信時のエラー処理
                            if (emailaddress != "") {
                              try {
                                // 成功時
                                final auth = FirebaseAuth.instance;
                                await auth.sendPasswordResetEmail(
                                    email: emailaddress);
                                setState(() {
                                  infoText = "認証メールを送信しました\nパスワードの再設定を完了してください";
                                });
                              } on FirebaseAuthException catch (e) {
                                if (e.code == 'invalid-email') {
                                  // 無効なメールアドレスの場合
                                  setState(() {
                                    infoText = "無効なメールアドレスです";
                                  });
                                } else if (e.code == 'user-not-found') {
                                  // ユーザーが存在しない場合
                                  setState(() {
                                    infoText = "このアドレスは使用されていません";
                                  });
                                } else {
                                  // その他の失敗の場合
                                  setState(() {
                                    infoText = "処理に失敗しました";
                                  });
                                }
                              } on Exception {
                                // 予期せぬエラーの場合
                                setState(() {
                                  infoText = "処理に失敗しました";
                                });
                              }
                            } else {
                              // メールアドレスの入力がない場合
                              setState(() {
                                infoText = "メールアドレスを入力してください";
                              });
                            }
                          },
                          child: const Text("認証メールを送信"),
                        ),
                      ),
                      // メッセージテキストの表示
                      Container(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(infoText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
