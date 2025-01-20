import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// グループを検索する関数
Future<List<String>> search(groupId) async {
  // Firestoreのインスタンス
  var db = FirebaseFirestore.instance;
  // グループ名
  String groupname = "";
  // グループの管理者名
  String adminname = "";
  // Firestoreから取得したデータ
  Map<String, dynamic> data;
  // Firestoreの参照
  var docRef =
      db.collection("Groups").doc(groupId).collection("groupInfo").doc("pass");
  // Firestoreから値を取得・格納
  await docRef.get().then((DocumentSnapshot doc) {
    data = doc.data() as Map<String, dynamic>;
    groupname = data["groupName"];
    adminname = data["adminName"];
  });
  return [groupname, adminname];
}

/// 検索したグループに参加申請を送る関数
Future<String> request(groupId, userId, inputpass) async {
  // Firestoreのインスタンス
  var db = FirebaseFirestore.instance;
  // Firestoreから取得したデータ
  Map<String, dynamic> data;
  // Firestoreから取得した本当のパスワード
  String truePass = "";
  // 画面に表示するメッセージテキスト
  String responseText = "";
  // Firestoreの参照
  var docRef =
      db.collection("Groups").doc(groupId).collection("groupInfo").doc("pass");
  // Firestoreから値を取得・格納
  await docRef.get().then((DocumentSnapshot doc) {
    data = doc.data() as Map<String, dynamic>;
    truePass = data["pass"];
  });
  // 入力されたパスワードが正しいか検証
  if (truePass == inputpass) {
    /// パスワードが正解だった場合
    /// Cloud functions for Firebase にある関数にリクエストを送る
    /// 送り先の関数ではグループIDとユーザーIDを使用するため付加して送信する
    try {
      final response = await http.post(
        Uri.parse('https://request-group-gpp774oc5q-an.a.run.app'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          "data": {
            'groupId': groupId,
            'userId': userId,
          }
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // 成功時の処理
        print(data);
        responseText = "参加リクエストを送信しました\nグループ管理者の操作をお待ち下さい";
      } else {
        // エラー処理
        print(data);
        print('Request failed with status: ${response.statusCode}.');
        print('Body: ${response.body}');
        responseText = "エラーが発生しました";
      }
    } catch (e) {
      responseText = "エラーが発生しました";
    }
  } else {
    // 失敗時のメッセージテキストを代入
    responseText = "エラー\nパスワードが間違っている可能性があります";
  }
  return responseText;
}
