import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<String> submitEditedShift(submitData) async {
  String responseText = "";
  var auth = FirebaseAuth.instance;
  var userId = auth.currentUser!.uid.toString();

  // Firestoreインスタンス
  final db = FirebaseFirestore.instance;
  Map<String,dynamic> submitShift = submitData;

  await db
      .collection('Users')
      .doc(userId)
      .collection("CompletedShift")
      .doc("shift")
      .update(submitShift);
  
  responseText = "シフトの提出が完了しました。";

  return responseText;
}
