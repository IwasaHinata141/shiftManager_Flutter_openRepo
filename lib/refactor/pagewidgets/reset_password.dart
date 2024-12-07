import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/login_screen.dart';

class ResetPassword extends StatefulWidget {
  @override
  State<ResetPassword> createState() => _ResetPassword();
}

class _ResetPassword extends State<ResetPassword> {
  String infoText = "";
  String emailaddress = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[350],
        centerTitle: true,
        title: Text("パスワード再設定"),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => LoginScreenPage()));
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
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Text(
                            "パスワードを忘れてしまった場合、パスワードの再設定が必要になります\n手順\n①アカウントのメールアドレスに認証メールを送信\n②認証メールのリンクにアクセス\n③リンク先で新しいパスワードを設定\n④shiftmanagerアプリでログイン"),
                      ),
                      Container(
                        height: 30,
                        width: double.infinity,
                        child: Container(
                          padding: EdgeInsets.only(left: 20),
                          alignment: Alignment.bottomLeft,
                          height: 30,
                          width: 100,
                          child: Text("メールアドレス"),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(right: 10, left: 10),
                        height: 50,
                        width: double.infinity,
                        child: Container(
                          padding: EdgeInsets.all(5),
                          child: TextField(
                            decoration: InputDecoration(
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
                      Container(
                        padding: EdgeInsets.only(top: 10),
                        height: 50,
                        width: 200,
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              final auth = FirebaseAuth.instance;
                              await auth.sendPasswordResetEmail(
                                  email: emailaddress);
                              setState(() {
                                infoText = "認証メールを送信しました\nパスワードの再設定を完了してください";
                              });
                            } catch (e) {
                              setState(() {
                                infoText = "エラー";
                              });
                            }
                          },
                          child: Text("認証メールを送信"),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 10),
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
