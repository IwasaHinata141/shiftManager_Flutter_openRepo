import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1_shift_manager/main.dart';
import 'dart:core';

/// ログイン関数
/* 
機能：
ログイン（メールアドレス・パスワード）、FCMトークンの取得、
MyAppへの遷移
*/

Future<String> loginAction(loginUserEmail, loginUserPassword, context) async {
  String infoText = "";
  try {
    // Firebase authのリロード
    FirebaseAuth.instance.currentUser?.reload();
    // Firebase authのインスタンス取得
    final FirebaseAuth auth = FirebaseAuth.instance;
    // メールアドレス・パスワードでログイン
    await auth.signInWithEmailAndPassword(
      email: loginUserEmail,
      password: loginUserPassword,
    );
    // メールアドレスの認証を検証
    if (auth.currentUser!.emailVerified) {
      // FCM の通知権限リクエスト
      final messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      print('User granted permission: ${settings.authorizationStatus}');
      // FCMトークンを取得
      var fcmToken = await messaging.getToken();
      // FCMトークンを付加してMyAppに遷移
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MyApp(
                  fcmToken: fcmToken,
                )),
      );

      infoText = "ログイン成功";
      return infoText;
    } else {
      // メールアドレスが未認証の場合は画面遷移せずにメッセージを表示する
      infoText = "メールアドレスが未認証です\n確認メールから認証を完了してください";
      return infoText;
    }
  } on FirebaseAuthException catch (e) {
    // 列挙保護が有効なため、エラーコードはinvalid-credentialのみが返ってくる
    print("e.code:${e.code}");
    // ログインに失敗した場合
    if (e.code == 'invalid-credential') {
      // パスワードが間違っている場合
      infoText = "入力情報に誤りがある可能性があります";
    } else {
      infoText = "エラー";
    }
    return infoText;
  } on Exception {
    // 予期せぬエラーの場合
    infoText = "処理に失敗しました";
    return infoText;
  }
}
