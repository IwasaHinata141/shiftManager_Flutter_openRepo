import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

var data;
var doc_ref_pass;
var db = FirebaseFirestore.instance;

Future<List<String>> search(groupId, groupname, adminname) async {
  doc_ref_pass =
      db.collection("Groups").doc(groupId).collection("groupInfo").doc("pass");
  await doc_ref_pass.get().then((DocumentSnapshot doc) {
    data = doc.data() as Map<String, dynamic>;
    groupname = data["groupName"];
    adminname = data["adminName"];
    print(groupname);
  });
  print(groupname);
  print(adminname);
  return [groupname, adminname];
}

Future<String> request(groupId, userId, inputpass) async {
  String truePass = "";
  String responce ="";
  doc_ref_pass =
      db.collection("Groups").doc(groupId).collection("groupInfo").doc("pass");
  await doc_ref_pass.get().then((DocumentSnapshot doc) {
    data = doc.data() as Map<String, dynamic>;
    truePass = data["pass"];
  });
  print(truePass);
  if (truePass == inputpass) {
    http.post(
      Uri.parse('https://request-group-gpp774oc5q-an.a.run.app'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'groupId': groupId,
        'userId': userId,
      }),
    );
    responce = "参加リクエストを送信しました\nグループ管理者の操作をお待ち下さい";
  }else{
    responce = "パスワードが違います";
  }

  return responce;
}
