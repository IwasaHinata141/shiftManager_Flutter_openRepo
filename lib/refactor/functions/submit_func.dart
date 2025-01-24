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
///       {"2025-01-01":"12:00"},
///       {"2025-01-02":"14:00"},}
///     {"end" :
///       {"2025-01-01":"15:00"},
///       {"2025-01-02":"18:00"},}
///  }
///
Future<String> submitMyshift(
  startTimeList,
  endTimeList,
  duration,
  groupId,
) async {
  // Firestoreに書き込む内容
  Map<String, dynamic> uploadData = {};
  // シフトを入れる変数
  Map<String, dynamic> shift = {};
  // 成形したシフトの開始時刻を格納する
  Map<String, dynamic> startshift = {};
  // 成形したシフトの終了時刻を格納する
  Map<String, dynamic> endshift = {};
  // 処理の成功/失敗を知らせるメッセージ
  String infoText = "";

  /// シフトの日数分の繰り返し処理
  /// 開始時刻と終了時刻の両方が書き込まれている場合に限り処理を行う
  /// 日付をkey、シフトデータをvalueとして格納
  for (int i = 0; i < duration.length; i++) {
    if (startTimeList[i] != "-" && endTimeList[i] != "-") {
      // 日付の仕切りを変更
      var dayStr = duration[i].replaceAll('/', '-');
      startshift[dayStr] = startTimeList[i];
      endshift[dayStr] = endTimeList[i];
    }
  }
  // startをkeyとして開始時刻リストを格納
  shift["start"] = startshift;
  // endをkeyとして終了時刻リストを格納
  shift["end"] = endshift;
  // Firebase authインスタンス、ユーザーID
  try {
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
        .update(uploadData);
    infoText = "シフトの提出が完了しました。";
  } catch (e) {
    infoText = "エラー\n提出に失敗しました";
  }
  return infoText;
}
