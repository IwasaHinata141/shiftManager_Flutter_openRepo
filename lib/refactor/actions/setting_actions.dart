import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

Future<void> editMyhourlyWage(newHourlyWageMap) async {
  final db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  final userId = auth.currentUser?.uid.toString();
  print(newHourlyWageMap);

  await db
      .collection('Users')
      .doc(userId)
      .collection("MyInfo")
      .doc("userInfo")
      .update({"hourlyWage":newHourlyWageMap});

}

Future<void> editMyUserInfo(username,birthday) async {
  final db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  final userId = auth.currentUser?.uid.toString();
  

  await db
      .collection('Users')
      .doc(userId)
      .collection("MyInfo")
      .doc("userInfo")
      .update({"username":username,"birthday":birthday});
}

