import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future submitEditedShift(submitData) async {
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
  
}
