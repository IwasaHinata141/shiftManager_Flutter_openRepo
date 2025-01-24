import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1_shift_manager/refactor/functions/setting_func.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';

/// ユーザー情報を変更するためのページ
/*
機能：
生年月日、名前、メールアドレス、パスワードの変更
メールアドレスは所持しているかの検証を行う
パスワードの変更は現在のパスワードの入力が必要
*/
/// 

// ignore: must_be_immutable
class EditUserInfo extends StatefulWidget {
  EditUserInfo(
      {super.key,
      required this.emailaddress,
      required this.birthday,
      required this.username});
  String emailaddress = "";
  DateTime birthday;
  String username = "";
  @override
  State<EditUserInfo> createState() => _EditUserInfo();
}

class _EditUserInfo extends State<EditUserInfo> {
  var userId ="";
  var formatter = DateFormat('yyyy-MM-dd');
  String infoText1 = "";
  String infoText2 = "";
  String infoText3 = "";
  bool _isObscure1 = true;
  bool _isObscure2 = true;
  bool _isObscure3 = true;
  String? birthday;
  String inputUsername = "";
  String oldPassword = "";
  String newPassword = "";
  String newEmailAddress = "";
  String password = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("ユーザ情報編集"),
        backgroundColor: Colors.grey[350],
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            Navigator.pop(context);
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
                  height: 460,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Column(
                    children: [
                      Container(
                          padding: const EdgeInsets.all(15), child: const Text("基本情報の変更")),
                      SizedBox(
                        height: 30,
                        width: double.infinity,
                        child: Container(
                          padding: const EdgeInsets.only(left: 20),
                          alignment: Alignment.bottomLeft,
                          height: 30,
                          width: 100,
                          child: const Text("名前"),
                        ),
                      ),
                      Container(
                        height: 40,
                        width: double.infinity,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(left: 10),
                        child: Container(
                          padding: const EdgeInsets.only(left: 20),
                          alignment: Alignment.bottomLeft,
                          height: 30,
                          child: Text(widget.username),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                        width: double.infinity,
                        child: Container(
                          padding: const EdgeInsets.only(left: 20),
                          alignment: Alignment.bottomLeft,
                          height: 30,
                          width: 100,
                          child: const Text("生年月日"),
                        ),
                      ),
                      Container(
                        height: 40,
                        width: double.infinity,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(left: 10),
                        child: Container(
                          padding: const EdgeInsets.only(left: 20),
                          alignment: Alignment.bottomLeft,
                          height: 30,
                          child: Text(formatter.format(widget.birthday)),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                        width: double.infinity,
                        child: Container(
                          padding: const EdgeInsets.only(left: 20),
                          alignment: Alignment.bottomLeft,
                          height: 30,
                          width: 100,
                          child: const Text("新しい名前"),
                        ),
                      ),
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
                                inputUsername = value;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                        width: double.infinity,
                        child: Container(
                          padding: const EdgeInsets.only(left: 20),
                          alignment: Alignment.bottomLeft,
                          height: 30,
                          width: 100,
                          child: const Text("新しい生年月日"),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(right: 10, left: 10),
                        height: 50,
                        width: double.infinity,
                        child: Container(
                            padding: const EdgeInsets.all(5),
                            child: TextButton(
                                onPressed: () {
                                  DatePicker.showDatePicker(
                                    context,
                                    showTitleActions: true,
                                    minTime: DateTime(1960, 1, 1),
                                    maxTime: DateTime(2024, 12, 31),
                                    onConfirm: (date) {
                                      setState(() {
                                        birthday = formatter.format(date);
                                      });
                                    },
                                    currentTime: widget.birthday,
                                    locale: LocaleType.jp,
                                  );
                                },
                                child: Text(birthday ??
                                    formatter.format(widget.birthday)))),
                      ),
                      Container(
                          margin: const EdgeInsets.only(top: 10),
                          height: 50,
                          width: 200,
                          child: ElevatedButton(
                              onPressed: () async {
                                try {
                                  if (inputUsername == "" || birthday == null) {
                                    setState(() {
                                      infoText1 = "全ての項目を埋めてください";
                                    });
                                  } else {
                                    editMyUserInfo(inputUsername, birthday);
                                    setState(() {
                                      infoText1 = "保存しました";
                                    });
                                  }
                                } catch (e) {
                                  setState(() {
                                    infoText1 = "エラー";
                                  });
                                }
                              },
                              child: const Text("変更を保存"))),
                      Container(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(infoText1),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                    top: 20,
                  ),
                  height: 470,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Column(
                    children: [
                      Container(
                          padding: const EdgeInsets.all(15),
                          child: const Text("メールアドレス変更")),
                      Container(
                          padding: const EdgeInsets.all(15),
                          child: const Text("認証メールのリンクからメールアドレスの認証を完了してください")),
                      SizedBox(
                        height: 30,
                        width: double.infinity,
                        child: Container(
                          padding: const EdgeInsets.only(left: 20),
                          alignment: Alignment.bottomLeft,
                          height: 30,
                          width: 100,
                          child: const Text("現在のメールアドレス"),
                        ),
                      ),
                      Container(
                        height: 40,
                        width: double.infinity,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(left: 10),
                        child: Container(
                          padding: const EdgeInsets.only(left: 20),
                          alignment: Alignment.bottomLeft,
                          height: 30,
                          child: Text(widget.emailaddress),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                        width: double.infinity,
                        child: Container(
                          padding: const EdgeInsets.only(left: 20),
                          alignment: Alignment.bottomLeft,
                          height: 30,
                          width: 100,
                          child: const Text("新しいメールアドレス"),
                        ),
                      ),
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
                                newEmailAddress = value;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                        width: double.infinity,
                        child: Container(
                          padding: const EdgeInsets.only(left: 20),
                          alignment: Alignment.bottomLeft,
                          height: 30,
                          width: 100,
                          child: const Text("パスワード"),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(right: 10, left: 10),
                        height: 50,
                        width: double.infinity,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          child: TextField(
                            obscureText: _isObscure1,
                            decoration: InputDecoration(
                              border: const UnderlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(_isObscure1
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () {
                                  setState(() {
                                    _isObscure1 = !_isObscure1;
                                  });
                                },
                              ),
                            ),
                            onChanged: (String value) {
                              setState(() {
                                password = value;
                              });
                            },
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 10),
                        height: 50,
                        width: 200,
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              final auth = FirebaseAuth.instance;
                              await auth.signInWithEmailAndPassword(
                                  email: widget.emailaddress,
                                  password: password);
                              await auth.currentUser
                                  ?.verifyBeforeUpdateEmail(newEmailAddress);
                              setState(() {
                                infoText2 = "認証メールを送信しました";
                              });
                            } catch (e) {
                              setState(() {
                                infoText2 = "パスワードが違います";
                              });
                            }
                          },
                          child: const Text("認証メールを送信"),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(infoText2),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20, bottom: 20),
                  height: 370,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Column(
                    children: [
                      Container(
                          padding: const EdgeInsets.all(15), child: const Text("パスワード変更")),
                      SizedBox(
                        height: 30,
                        width: double.infinity,
                        child: Container(
                          padding: const EdgeInsets.only(left: 20),
                          alignment: Alignment.bottomLeft,
                          height: 30,
                          width: 100,
                          child: const Text("現在のパスワード"),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(right: 10, left: 10),
                        height: 50,
                        width: double.infinity,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          child: TextField(
                            obscureText: _isObscure2,
                            decoration: InputDecoration(
                              border: const UnderlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(_isObscure2
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () {
                                  setState(() {
                                    _isObscure2 = !_isObscure2;
                                  });
                                },
                              ),
                            ),
                            onChanged: (String value) {
                              setState(() {
                                oldPassword = value;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                        width: double.infinity,
                        child: Container(
                          padding: const EdgeInsets.only(left: 20),
                          alignment: Alignment.bottomLeft,
                          height: 30,
                          width: 100,
                          child: const Text("新しいパスワード"),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(right: 10, left: 10),
                        height: 50,
                        width: double.infinity,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          child: TextField(
                            obscureText: _isObscure3,
                            decoration: InputDecoration(
                              border: const UnderlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(_isObscure3
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () {
                                  setState(() {
                                    _isObscure3 = !_isObscure3;
                                  });
                                },
                              ),
                            ),
                            onChanged: (String value) {
                              setState(() {
                                newPassword = value;
                              });
                            },
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 10),
                        height: 50,
                        width: 100,
                        child: ElevatedButton(
                          onPressed: () async {
                            final auth = FirebaseAuth.instance;
                            try {
                              await auth.signInWithEmailAndPassword(
                                  email: widget.emailaddress,
                                  password: oldPassword);
                              if (oldPassword != newPassword) {
                                try {
                                  await auth.currentUser
                                      ?.updatePassword(newPassword);
                                  setState(() {
                                    infoText3 = "パスワードを変更しました";
                                  });
                                } catch (e) {
                                  setState(() {
                                    infoText3 = "失敗(パスワードは6文字以上で設定してください)";
                                  });
                                }
                              } else {
                                setState(() {
                                  infoText3 = "新しいパスワードは現在のパスワードと違うものにしてください";
                                });
                              }
                            } catch (e) {
                              setState(() {
                                infoText3 = "現在のパスワードが違います";
                              });
                            }
                          },
                          child: const Text("決定"),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 10, right: 40, left: 40),
                        child: Text(infoText3),
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
  // ignore: non_constant_identifier_names
}
