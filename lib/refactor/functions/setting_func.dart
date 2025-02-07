import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Firestoreににある時給データの変更を行う関数
/// newHourlyWageMapは新しい時給データ（Map型）
/// グループ名の変更機能を追加した
Future<void> editMyhourlyWage(newHourlyWageMap,newGroupNameMap) async {
  // Firestoreインスタンス
  final db = FirebaseFirestore.instance;
  // Firebase authインスタンス
  final auth = FirebaseAuth.instance;
  // ユーザーID取得
  final userId = auth.currentUser?.uid.toString();
  //Firestoreのドキュメントの該当箇所を更新
  newHourlyWageMap.addAll({"no data":"1000"});
  newGroupNameMap.addAll({"no data":"no data"});

  await db
      .collection('Users')
      .doc(userId)
      .collection("MyInfo")
      .doc("userInfo")
      .update({"hourlyWage":newHourlyWageMap,"groupNameList":newGroupNameMap});
}

/// Firestoreにあるユーザー名と生年月日のデータの変更を行う関数
Future<void> editMyUserInfo(username,birthday) async {
  // Firestoreインスタンス
  final db = FirebaseFirestore.instance;
  // Firebase authインスタンス
  final auth = FirebaseAuth.instance;
  // ユーザーID取得
  final userId = auth.currentUser?.uid.toString();
  //Firestoreのドキュメントの該当箇所を更新
  await db
      .collection('Users')
      .doc(userId)
      .collection("MyInfo")
      .doc("userInfo")
      .update({"username":username,"birthday":birthday});
}

