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
  // グループ参加者の人数
  String memberNum = "";
  // Firestoreから取得したデータ
  Map<String, dynamic> data;
  Map<String, dynamic> data2;
  // Firestoreの参照
  var docRef =
      db.collection("Groups").doc(groupId).collection("groupInfo").doc("pass");
  // Firestoreから値を取得・格納
  await docRef.get().then((DocumentSnapshot doc) {
    data = doc.data() as Map<String, dynamic>;
    groupname = data["groupName"];
    adminname = data["adminName"];
  });
  // Firestoreから取得したデータ
  var docRef2 = db
      .collection("Groups")
      .doc(groupId)
      .collection("groupInfo")
      .doc("member");
  // Firestoreから値を取得・格納
  await docRef2.get().then((DocumentSnapshot doc) {
    data2 = doc.data() as Map<String, dynamic>;
    memberNum = (data2.length).toString();
  });
  return [groupname, adminname, memberNum];
}

/// 検索したグループに参加申請を送る関数
Future<String> request(groupId, userId, inputpass) async {
  // Firestoreのインスタンス
  var db = FirebaseFirestore.instance;
  // Firestoreから取得したデータ
  Map<String, dynamic> data;
  // Firestoreから取得したデータ
  Map<String, dynamic> data2;
  // Firestoreから取得したデータ
  Map<String, dynamic> data3;
  // Firestoreから取得した本当のパスワード
  String truePass = "";
  // 画面に表示するメッセージテキスト
  String responseText = "";
  // 既に申請しているかを検証
  bool checkSecondTime = false;
  // 既に所属しているかを検証
  bool checkBelonging = false;
  // Firestoreの参照
  var docRef =
      db.collection("Groups").doc(groupId).collection("groupInfo").doc("pass");
  // Firestoreから値を取得・格納
  await docRef.get().then((DocumentSnapshot doc) {
    data = doc.data() as Map<String, dynamic>;
    truePass = data["pass"];
  });
  // Firestoreの参照
  var docRef2 = db
      .collection("Groups")
      .doc(groupId)
      .collection("groupInfo")
      .doc("applicants");
  // Firestoreの参照
  var docRef3 = db
      .collection("Groups")
      .doc(groupId)
      .collection("groupInfo")
      .doc("member");
  // Firestoreから値を取得・格納
  await docRef2.get().then((DocumentSnapshot doc) {
    data2 = doc.data() as Map<String, dynamic>;
    if (data2["1"] != "no data") {
      for (int i = 1; i <= data2.length; i++) {
        String uid = data2["$i"]["uid"];
        if (userId == uid) {
          checkSecondTime = true;
        }
      }
    }
  });
  // Firestoreから値を取得・格納
  await docRef3.get().then((DocumentSnapshot doc) {
    data3 = doc.data() as Map<String, dynamic>;
    if (data3["1"] != "no data") {
      for (int i = 1; i <= data3.length; i++) {
        String uid = data3["$i"]["uid"];
        if (userId == uid) {
          checkBelonging = true;
        }
      }
    }
  });

  if (checkSecondTime) {
    // 既に参加申請をしていた場合
    responseText = "このグループには既に参加申請をしています";
  } else if(checkBelonging){
    // 既に所属している場合
    responseText = "既に所属しているグループです";
  }else{
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
        if (response.statusCode == 200) {
          // 成功時の処理
          responseText = "参加リクエストを送信しました\nグループ管理者の操作をお待ち下さい";
        } else {
          // エラー処理
          responseText = "エラーが発生しました";
        }
      } catch (e) {
        responseText = "エラーが発生しました";
      }
    } else {
      // 失敗時のメッセージテキストを代入
      responseText = "エラー\nパスワードが間違っている可能性があります";
    }
  }

  return responseText;
}
