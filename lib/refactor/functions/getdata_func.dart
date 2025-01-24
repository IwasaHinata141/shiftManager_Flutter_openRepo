import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

/// このファイルにはProviderに格納するデータを取得するための関数を記述する

// Providerに渡す値を取得して、一括で返す関数。
Future<List> getData(db) async {
  var auth = FirebaseAuth.instance;
  final userId = auth.currentUser?.uid.toString();
  // FirestoreからユーザーのグループID、生年月日、名前、時給を取得
  final userInfo = await getUserInfo(userId);
  // グループID
  final List<String> groupId = userInfo[0];
  // 生年月日
  final birthday = userInfo[1];
  // 名前
  final username = userInfo[2];
  // 時給
  final hourlyWage = userInfo[3];
  // グループIDの数から所属グループの数を取得
  final int groupCount = groupId.length;
  // グループ名のリストを取得
  final groupNameMap = await getGroupNameMap(db,userId);
  // シフトデータと給与金額を取得する関数
  final shiftdata = await getMyShift(userId, db, hourlyWage, groupNameMap);
  // 募集中のシフトの期間を取得
  final duration = await getDuration(groupId[0]);
  // durationの数に対応したリスト（シフト提出画面でシフトの開始時間のリストを格納する）を取得
  final List<String> startTimeList = await generateEmptyList(duration.length);
  // durationの数に対応したリスト（シフト提出画面でシフトの終了時間のリストを格納する）を取得
  final List<String> endTimeList = await generateEmptyList(duration.length);
  // シフトが募集中か停止中かの真偽値を取得
  final bool status = await getStatus(groupId[0]);
  // 所属グループの名前をリストで取得
  final groupName = await getGroupName(groupId, db,groupNameMap);
  // 給与のデータを取得
  final Map<String, dynamic> salaryInfo = shiftdata[1]["salaryInfo"];
  // 複数のグループでの給与の合計金額を取得
  final summarySalary = shiftdata[2];
  // 加工前シフトデータ（カレンダーページの変更時に使用する）
  final rawShift = shiftdata[3];

  // 取得した値をリストにまとめて返す
  return [
    shiftdata[0],
    duration,
    startTimeList,
    endTimeList,
    status,
    salaryInfo,
    groupId,
    birthday,
    username,
    hourlyWage,
    groupName,
    groupCount,
    summarySalary,
    rawShift,
    groupNameMap
  ];
}

/// ---------以下はgetData()で使用した関数--------- ///
/// グループ名とグループIDの紐づけを行っているデータを取得する関数
/// groupNameListはキーがグループID、値がグループ名
Future<Map<String,dynamic>> getGroupNameMap(db,userId) async{
  // 戻り値を格納する変数
  Map<String, dynamic> groupNameMap = {};
  // Firestoreへの参照
  final docRefGroupName = db
      .collection("Users")
      .doc(userId)
      .collection("MyInfo")
      .doc("userInfo");
  // データの取得と変数への格納
   await docRefGroupName.get().then((DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    groupNameMap = data["groupNameList"];
   });
  print("groupNameList:${groupNameMap}");
  return groupNameMap;
}

// シフトデータの取得、給与の計算を行う関数
Future<List<dynamic>> getMyShift(userId, db, hourlyWage, groupNameMap) async {
  // シフトデータ
  Map<String, List<String>> shift = {};
  // 合計給与
  int summarySalary = 0;
  // グループ別給与
  Map<String, dynamic> salaryInfo = {};
  // 給与計算時に使う箱
  Map<String, dynamic> calculatedDataMap = {};
  // 合計給与を文字列に変換した後に代入する変数
  String summarySalaryText = "";
  // 加工前のシフトデータを格納する
  Map<String, dynamic> rawshift = {};
  // Firestoreのシフトデータへの参照
  final doc_ref_shift = db
      .collection("Users")
      .doc(userId)
      .collection("CompletedShift")
      .doc("shift");
  // 参照からのデータをMap型で取得
  await doc_ref_shift.get().then((DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    rawshift = data;
    // シフトデータはグループごとに分けているため、要素数で所属グループ数を取得できる
    // 所属グループ数が1つか、それ以外かで分岐
    if (data.length != 1) {
      // 所属グループが1つではない場合
      // keyは所属グループのグループIDになっている
      Iterable<String> keys = data.keys;
      // グループごとに給与の計算を行うための繰り返し処理
      for (String key in keys) {
        // グループ名を格納
        final groupId = key;
        // グループ名がno dataの場合処理を省く
        /// no data はグループに所属していない最初期のエラー回避のために設定しているグループ名
        /// no data の情報は表示する必要がないため、処理を省いている
        if (groupId != "no data") {
          // シフトデータを取得する(valueDataの構造(例): {2000/01/01:"12:00-18:00"})
          Map<String, dynamic> valueData = data["${groupId}"];
          // 時給とシフトデータを基に給与、労働時間、出勤日数を計算する
          Map<String, dynamic> calculatedDataInstance =
              await calculateSalary(hourlyWage, groupId, valueData);
          // 全てのグループの結果をまとめるために変数に格納
          calculatedDataMap.addAll(calculatedDataInstance);
          // 現在のグループの当月の給与を格納
          int salary = calculatedDataInstance["${groupId}"]["totalsalary"];
          // 当月の全てのグループからの給与を算出するために合計する
          summarySalary = summarySalary + salary;
          // 結果を戻り値の変数に格納
          salaryInfo["salaryInfo"] = calculatedDataMap;
          // シフトデータを1つずつ成形し、戻り値の変数に格納
          await Future.forEach(valueData.entries, (entry) {
            var groupName = groupNameMap[groupId];
            var list = ["${groupName}  ${entry.value.toString()}"];
            if (shift["${entry.key}"] == null) {
              shift["${entry.key}"] = list;
            } else {
              final List<String> previousData = shift["${entry.key}"]!;
              previousData.add(list[0]);
            }
          });
        }
      }
    } else {
      /// 所属しているグループが1つの場合
      String newkey = "";
      // グループIDの取得・格納
      Iterable<String> keys = data.keys;
      for (String key in keys) {
        newkey = key;
      }
      final groupId = newkey;
      // シフトデータを取得する(valueDataの構造(例): {2000/01/01:"12:00-18:00"})
      Map<String, dynamic> valueData = data["${groupId}"];
      // 時給とシフトデータを基に給与、労働時間、出勤日数を計算する
      Map<String, dynamic> calculatedDataInstance =
          await calculateSalary(hourlyWage, groupId, valueData);
      // 全てのグループの結果をまとめるために変数に格納
      calculatedDataMap.addAll(calculatedDataInstance);
      // 結果を戻り値の変数に格納
      salaryInfo["salaryInfo"] = calculatedDataMap;
      // シフトデータを1つずつ成形し、戻り値の変数に格納
      await Future.forEach(valueData.entries, (entry) {
        var groupName = groupNameMap[groupId];
        var list = ["${groupName}  ${entry.value.toString()}"];
        if (shift["${entry.key}"] == null) {
          shift["${entry.key}"] = list;
        } else {
          final List<String> previousData = shift["${entry.key}"]!;
          previousData.add(list[0]);
        }
      });
    }
    // 合計給与にカンマを打つためのフォーマット
    final numformatter = NumberFormat("#,###");
    // 給与が1000円以上の場合はカンマを打つ
    if (summarySalary >= 1000) {
      summarySalaryText = numformatter.format(summarySalary);
    }
  });
  return [shift, salaryInfo, summarySalaryText, rawshift];
}

/// 1グループごとに時給とシフトデータから給与を計算する関数
/// ただし、手当などのオプションは一切加味していない
Future<Map<String, dynamic>> calculateSalary(
    hourlyWage, groupId, shiftdata) async {
  // 給与の合計
  int totalsalary = 0;
  // 合計労働時間
  double totaldiffhour = 0;
  // 出勤回数、労働時間、給与をまとめる箱
  Map<String, dynamic> result = {};
  // 戻り値を格納する箱
  Map<String, dynamic> responce = {};
  // 型変換に使用するフォーマット
  DateFormat formatter = DateFormat('yyyy/MM/dd HH:mm');
  // 現在の日時
  final DateTime now = DateTime.now();
  // 当月の1日の日付
  final startDay = formatter.format(DateTime(now.year, now.month, 1));
  // 当月の月末の日付
  final endDay = formatter
      .format(DateTime(now.year, now.month + 1, 1).subtract(Duration(days: 1)));
  // startDayのDatetime型
  final firstDay = formatter.parse(startDay);
  // endDayのDatetime型
  final finalDay = formatter.parse(endDay);
  // 出勤日数
  var attendcount = 0;

  // firstDayからfinalDayまでの間の日付部分を成形して順にリストに追加
  for (DateTime date = firstDay;
      date.isBefore(finalDay.add(Duration(days: 1)));
      date = date.add(Duration(days: 1))) {
    // (2025-01-01 00:00:00.000) → (2025/01/01)
    final dateString = date.toString().split(" ")[0].replaceAll("-", "/");
    // シフトデータを取り出してリストに追加
    final dataField = shiftdata["${dateString}"];
    // 該当する日付のシフトデータが存在する場合だけ処理を行う
    if (dataField != null) {
      // 出勤日数を1つ増やす
      attendcount++;
      // dataFieldは12:00 - 18:00のような形をしている
      final timeItem = dataField.split(" - ");
      // 開始時刻
      final start = timeItem[0];
      // 終了時刻
      final end = timeItem[1];
      // 労働時間の計算
      // 例：2025/01/01 12:00
      final dayListItemStart = "$dateString $start";
      // 例：2025/01/01 18:00
      final dayListItemEnd = "$dateString $end";
      // DateTimeに変換
      DateTime starttime = formatter.parse(dayListItemStart);
      DateTime endtime = formatter.parse(dayListItemEnd);
      // 二つのDateTimeの差分から労働時間を計算
      final diffminute = endtime.difference(starttime).inMinutes;
      // 分単位で計算されるため時間単位に直す
      final diffhour = diffminute / 60;
      // 労働時間と時給から給与を計算
      final salary = (diffhour * double.parse(hourlyWage["${groupId}"])).toInt();
      // 一日の給与を当月の給与に合計する
      totalsalary = totalsalary + salary;
      // 一日の労働時間を当月の労働時間に合計する
      totaldiffhour = totaldiffhour + diffhour;
    }
  }
  // 給与、出勤日数、労働時間を格納
  result["totalsalary"] = totalsalary;
  result["attendcount"] = attendcount;
  result["totaldiffhour"] = totaldiffhour.toStringAsFixed(2);
  // グループIDをキーとして結果を格納
  responce[groupId] = result;
  return responce;
}

/// 募集中のシフトの期間を取得する関数
/// シフトが募集中でない場合でもこの関数は動くが、表示されるかはstatusの値によって変化する
Future<List<String>> getDuration(groupId) async {
  final db = FirebaseFirestore.instance;
  // シフト期間の日付を格納するリスト
  List<String> listOfShiftDay = [];
  // Firestoreへの参照
  final doc_ref_duration = db
      .collection("Groups")
      .doc(groupId)
      .collection("groupInfo")
      .doc("tableRequest");
  // 参照からデータを取得
  await doc_ref_duration.get().then((DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    // シフトの開始日
    var start = data["start"];
    // シフトの終了日
    var end = data["end"];
    // シフトが募集されていない場合(no data)は仮の日付を代入
    if (start == "no data") {
      start = "2024/01/01";
      end = "2024/01/01";
    }
    // 日付の文字列を成形 例：(2000/01/01) → (2000-01-01)
    final startDay = start.replaceAll('/', '-');
    final endDay = end.replaceAll('/', '-');
    // 日付型に変換
    DateTime dayOfStart = DateTime.parse(startDay);
    DateTime dayOfEnd = DateTime.parse(endDay);
    // 開始と終了の差分（日数）を計算
    Duration difference = dayOfEnd.difference(dayOfStart);
    // フォーマット指定
    DateFormat formatter = DateFormat('yyyy/MM/dd');
    // 日数分の繰り返し処理を行い、日付をリストに格納
    for (int i = 0; i <= difference.inDays; i++) {
      String formattedDate = formatter.format(dayOfStart);
      listOfShiftDay.add("${formattedDate}");
      dayOfStart = dayOfStart.add(Duration(days: 1));
    }
  });
  return listOfShiftDay;
}

/// シフト提出画面で使うためのリストを作成する関数(numberはシフトの日数)
Future<List<String>> generateEmptyList(number) async {
  // 戻り値のリスト
  List<String> emptyList = [];
  // 日数分繰り返し処理を行いリストに"-"を格納する
  for (int i = 0; i < number; i++) {
    emptyList.add("-");
  }
  return emptyList;
}

/// Firestoreからユーザー情報を取得する関数
Future getUserInfo(userId) async {
  final db = FirebaseFirestore.instance;
  // Firestoreへの参照
  final docRef =
      db.collection('Users').doc(userId).collection("MyInfo").doc("userInfo");
  // グループIDを格納するリスト
  List<String> groupId = [];
  // 生年月日
  DateTime birthday;
  // ユーザー名
  String username = "";
  // 時給を格納するMap型 {グループ名:時給}
  Map<String, dynamic> hourlyWage = {};
  // 戻り値の変数
  List<dynamic> userInfo = [];
  // 参照からデータを取得
  await docRef.get().then(
    (DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;
      // グループIDの数によって分岐
      if (data["groupId"].length == 1) {
        // グループIDをリストに格納
        groupId.add(data["groupId"]["1"]);
      } else {
        // グループの数だけ繰り返し処理をしてリストに格納
        data["groupId"].forEach((key, value) {
          groupId.add(value);
        });
      }
      // 生年月日をDateTimeに変換
      birthday = DateTime.parse(data["birthday"]);
      // ユーザー名を取得
      username = data["username"];
      // 時給を取得
      hourlyWage = data["hourlyWage"];
      // グループIDを格納
      userInfo.add(groupId);
      // 生年月日を格納
      userInfo.add(birthday);
      // ユーザー名を格納
      userInfo.add(username);
      // 時給を格納
      userInfo.add(hourlyWage);
    },
  );
  return userInfo;
}

/// シフトの募集状況を取得する関数(statusがtrue:募集中,statusがfalse:停止中)
Future<bool> getStatus(groupId) async {
  final db = FirebaseFirestore.instance;
  // 募集状況を格納する変数
  bool status = false;
  // Firestoreの参照
  final docRef = db
      .collection('Groups')
      .doc(groupId)
      .collection("groupInfo")
      .doc("status");
  // 参照を基にデータを取得
  await docRef.get().then((DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    status = data["status"];
  });
  return status;
}

/// 所属しているグループのグループ名を取得する
Future<List> getGroupName(groupId, db, groupNameMap) async {
  // 戻り値を入れるリスト
  List groupName = [];
  // グループIDの数だけ繰り返し処理
  // グループIDを基にしてグループ名を格納
  for (int i = 0; i < groupId.length; i++) {
      // グループ名をリストに格納
      groupName.add(groupNameMap[groupId[i]]);
  }
  return groupName;
}
