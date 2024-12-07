import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

Future<Map<String, List<String>>> getMyShift(userId, db) async {
  Map<String, List<String>> shift = {};
  final doc_ref_shift = db
      .collection("Users")
      .doc(userId)
      .collection("CompletedShift")
      .doc("shift");
  await doc_ref_shift.get().then((DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    data.forEach((key, value) {
      final list = [value.toString()];
      shift["${key}"] = list;
    });
  });
  return shift;
}

Future<List<String>> getDuration(groupId, db) async {
  List<String> listOfShiftDay = [];
  final doc_ref_duration = db
      .collection("Groups")
      .doc(groupId)
      .collection("groupInfo")
      .doc("tableRequest");
  await doc_ref_duration.get().then((DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    var start = data["start"];
    var end = data["end"];
    if (start == "no data") {
      start = "2024/01/01";
      end = "2024/01/01";
    }
    final startDay = start.replaceAll('/', '-');
    final endDay = end.replaceAll('/', '-');

    DateTime day_of_start = DateTime.parse(startDay);
    DateTime day_of_end = DateTime.parse(endDay);
    Duration difference = day_of_end.difference(day_of_start);
    for (int i = 0; i <= difference.inDays; i++) {
      listOfShiftDay.add("${day_of_start.month}/${day_of_start.day}");
      day_of_start = day_of_start.add(Duration(days: 1));
    }
  });

  return listOfShiftDay;
}

Future<List<String>> generateEmptyList(number) async {
  List<String> emptyList = [];
  for (int i = 0; i < number; i++) {
    emptyList.add("-");
  }
  return emptyList;
}

Future submitMyshift(
  startTimeList,
  endTimeList,
  duration,
) async {
  final Map<String, Map<String, dynamic>> shift = {};
  final Map<String, dynamic> startshift = {};
  final Map<String, dynamic> endshift = {};
  List<String> dayList = [];
  for (int i = 0; i < duration.length; i++) {
    dayList.add(duration[i].split("/")[1]);
  }
  for (int i = 0; i < dayList.length; i++) {
    startshift[dayList[i]] = startTimeList[i];
    endshift[dayList[i]] = endTimeList[i];
  }
  shift["開始"] = startshift;
  shift["終了"] = endshift;

  var auth = FirebaseAuth.instance;
  var userId = auth.currentUser?.uid.toString();
  final db = FirebaseFirestore.instance;

  await db
      .collection('Users')
      .doc(userId)
      .collection("RequestShift")
      .doc("shift")
      .set(shift);
}

Future getGroupId(userId) async {
  final db = FirebaseFirestore.instance;
  final docRef =
      db.collection('Users').doc(userId).collection("MyInfo").doc("userInfo");
  var groupId = "";
  DateTime birthday;
  String username = "";
  int hourlyWage = 0;
  List<dynamic> userInfo = [];
  try {
    await docRef.get().then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        groupId = data["groupId"];
        birthday = DateTime.parse(data["birthday"]);
        username = data["username"];
        hourlyWage = data["hourlyWage"];
        userInfo.add(groupId);
        userInfo.add(birthday);
        userInfo.add(username);
        userInfo.add(hourlyWage);
      },
    );
  } catch (e) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
  }

  return userInfo;
}

Future<bool> getStatus(db, groupId) async {
  bool status = true;
  final docRef = db
      .collection('Groups')
      .doc(groupId)
      .collection("groupInfo")
      .doc("download");
  await docRef.get().then((DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    status = data["status"];
  });
  return status;
}

Future<Map<String, dynamic>> calculateSalary(shiftdata, hourlyWage) async {
  int totalsalary = 0;
  double totaldiffhour = 0;
  Map<String, dynamic> result = {};
  DateFormat formatter = DateFormat('yyyy/MM/dd HH:mm');
  final DateTime now = DateTime.now();
  final startDay = formatter.format(DateTime(now.year, now.month, 1));
  final endDay = formatter
      .format(DateTime(now.year, now.month + 1, 1).subtract(Duration(days: 1)));
  final firstDay = formatter.parse(startDay);
  final finalDay = formatter.parse(endDay);
  var attendcount = 0;
  // 空のリストを初期化
  // firstDayからfinalDayまでの間の日付を順にリストに追加
  for (DateTime date = firstDay;
      date.isBefore(finalDay.add(Duration(days: 1)));
      date = date.add(Duration(days: 1))) {
    final dateString = date.toString().split(" ")[0].replaceAll("-", "/");
    final dataField = shiftdata[dateString];
    if (dataField != null) {
      attendcount++;
      final timeItems = dataField[0].split(" - ");
      final start = timeItems[0];
      final end = timeItems[1];
      final dayListItemStart = "${dateString} ${start}";
      final dayListItemEnd = "${dateString} ${end}";
      DateTime starttime = formatter.parse(dayListItemStart);
      DateTime endtime = formatter.parse(dayListItemEnd);

      final diffminute = endtime.difference(starttime).inMinutes;
      final diffhour = diffminute / 60;
      final salary = (diffhour * hourlyWage).toInt();
      totalsalary = totalsalary + salary;
      totaldiffhour = totaldiffhour + diffhour;
    }
  }
  final numformatter = NumberFormat("#,###");
  result["totalsalary"] = numformatter.format(totalsalary);
  result["attendcount"] = attendcount;
  result["totaldiffhour"] = totaldiffhour.toStringAsFixed(2);
  return result;
}

Future<String> getGroupName(groupId, db) async {
  String groupName = "";

  final doc_ref_groupname = db
      .collection("Groups")
      .doc(groupId)
      .collection("groupInfo")
      .doc("pass");
  await doc_ref_groupname.get().then((DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    groupName = data["groupName"];
  });

  return groupName;
}

Future<List> getData(db) async {
  var auth = FirebaseAuth.instance;
  final userId = auth.currentUser?.uid.toString();
  final userInfo = await getGroupId(userId);
  final groupId = userInfo[0];
  final birthday = userInfo[1];
  final username = userInfo[2];
  final hourlyWage = userInfo[3];

  final shiftdata = await getMyShift(userId, db);
  final duration = await getDuration(groupId, db);
  final List<String> startTimeList = await generateEmptyList(duration.length);
  final List<String> endTimeList = await generateEmptyList(duration.length);
  final bool status = await getStatus(db, groupId);
  final Map<String, dynamic> salaryInfo =
      await calculateSalary(shiftdata, hourlyWage);
  final groupName = await getGroupName(groupId, db);
  return [
    shiftdata,
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
  ];
}
