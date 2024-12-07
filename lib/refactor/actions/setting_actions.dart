import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

Future<void> editMyhourlyWage(newHourlyWage) async {
  final db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  final userId = auth.currentUser?.uid.toString();
  final int newHourlyWageInt = int.parse(newHourlyWage);

  await db
      .collection('Users')
      .doc(userId)
      .collection("MyInfo")
      .doc("userInfo")
      .update({"hourlyWage":newHourlyWageInt});
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

