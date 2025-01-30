import 'dart:convert';
import 'package:http/http.dart' as http;

// 新規登録時に実行する関数
/* 
Firestoreにユーザーのコレクションを作成する関数
ユーザーIDとフルネームを付加してリクエストする
関数はClouf functions for Firebase にある
*/

Future signUpAction(fullname, userId) async {
  print("userId:${userId}");
  print("fullname:${fullname}");

  return http.post(
    Uri.parse('https://make-directory-gpp774oc5q-an.a.run.app'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{"data":{'userId': userId, 'fullname': fullname}}),
  );
}
