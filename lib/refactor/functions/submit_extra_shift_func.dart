import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future submitExtraShift(
    startTime, endTime, groupId, selectedDay) async {
  Map<String, dynamic> extraShift = {};
  var auth = FirebaseAuth.instance;
  var userId = auth.currentUser!.uid.toString();
  // Firestoreインスタンス
  final db = FirebaseFirestore.instance;
  final docRefShift = db
      .collection("Users")
      .doc(userId)
      .collection("CompletedShift")
      .doc("shift");
  await docRefShift.get().then((DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    extraShift = data["$groupId"];
  });
  String newShift = "$startTime - $endTime";
  extraShift[selectedDay] = newShift;
  Map<String, dynamic> submitExtraData = {};
  submitExtraData[groupId] = extraShift;

  // グループのシフトのリクエストドキュメントに書き込み
  await db
      .collection('Users')
      .doc(userId)
      .collection("CompletedShift")
      .doc("shift")
      .update(submitExtraData);
}
