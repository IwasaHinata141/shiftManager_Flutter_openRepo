import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1_shift_manager/main.dart';
import '../actions/getdata_action.dart';
import 'dart:core';

Future<String> loginAction(loginUserEmail, loginUserPassword, context) async {
  String infoText = "";
  try {
    print(loginUserEmail);
    print(loginUserPassword);
    // メール/パスワードでログイン
    FirebaseAuth.instance.currentUser?.reload();
    final FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signInWithEmailAndPassword(
      email: loginUserEmail,
      password: loginUserPassword,
    );
    auth.authStateChanges().listen((User? user) {
      if (user == null) {
        print('サインアウトされています');
      } else {
        print('サインインしました uid:${user.uid}  email:${user.email}');
      }
    });
    if (auth.currentUser!.emailVerified) {
      final result = await auth.signInWithEmailAndPassword(
        email: loginUserEmail,
        password: loginUserPassword,
      );
      final userId = result.user?.uid;
      final groupId = await getGroupId(userId);
      print("groupId : ${groupId}");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );

      infoText = "ログイン成功";
      return infoText;
    } else {
      infoText = "メールアドレスが未認証です\n確認メールから認証を完了してください";
      return infoText;
    }
  } catch (e) {
    // ログインに失敗した場合
    infoText = "ログイン失敗\n入力情報に誤りがある可能性があります";
    return infoText;
  }
}
