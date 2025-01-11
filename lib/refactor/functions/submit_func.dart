import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// シフトをFirestoreに送信する関数
/// 
/// startTimeList:シフトの開始時刻のリスト
/// endTimeList:シフトの終了時刻のリスト
/// duration:シフトの日付のリスト
/// groupId:グループID
/// 
/// 書き込む際のデータ構造(例)
/// {ユーザーID：
///     {"start":
///       {"2025/01/01":"12:00"},
///       {"2025/01/02":"14:00"},}
///     {"end" :
///       {"2025/01/01":"15:00"},
///       {"2025/01/02":"18:00"},}
///  } 
/// 
Future submitMyshift(
  startTimeList,
  endTimeList,
  duration,
  groupId,
) async {
  // Firestoreに書き込む内容
  final Map<String, dynamic> uploadData = {};
  // シフトを入れる変数
  final Map<String, dynamic> shift = {};
  // 成形したシフトの開始時刻を格納する
  final Map<String, dynamic> startshift = {};
  // 成形したシフトの終了時刻を格納する
  final Map<String, dynamic> endshift = {};
  /// シフトの日数分の繰り返し処理
  /// 開始時刻と終了時刻の両方が書き込まれている場合に限り処理を行う
  /// 日付をkey、シフトデータをvalueとして格納
  for (int i = 0; i < duration.length; i++) {
    if (startTimeList[i] != "-" && endTimeList[i] != "-") {
      startshift[duration[i]] = startTimeList[i];
      endshift[duration[i]] = endTimeList[i];
    }
  }
  // startをkeyとして開始時刻リストを格納
  shift["start"] = startshift;
  // endをkeyとして終了時刻リストを格納
  shift["end"] = endshift;
  // Firebase authインスタンス、ユーザーID
  var auth = FirebaseAuth.instance;
  var userId = auth.currentUser!.uid.toString();
  // ユーザーIDをkeyとしてシフトを格納
  uploadData[userId] = shift;
  // Firestoreインスタンス
  final db = FirebaseFirestore.instance;
  // グループのシフトのリクエストドキュメントに書き込み
  await db
      .collection('Groups')
      .doc(groupId)
      .collection("groupInfo")
      .doc("RequestShiftList")
      .set(uploadData);
}
