import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

Future<List<dynamic>> getMyShift(userId, db, hourlyWage) async {
  Map<String, List<String>> shift = {};
  int summarySalary = 0;
  Map<String, dynamic> salaryInfo = {};
  Map<String, dynamic> calculatedDataMap = {};
  String summarySalaryText = "";
  final doc_ref_shift = db
      .collection("Users")
      .doc(userId)
      .collection("CompletedShift")
      .doc("shift");
  await doc_ref_shift.get().then((DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;

    if (data.length != 1) {
      Iterable<String> keys = data.keys;
      for (String key in keys) {
        final groupName = key;
        if (groupName != "no data") {
          Map<String, dynamic> valueData = data["${groupName}"];
          Map<String, dynamic> calculatedDataInstance =
              await calculateSalary2(hourlyWage, groupName, valueData);
          calculatedDataMap.addAll(calculatedDataInstance);
          int salary = calculatedDataInstance["${groupName}"]["totalsalary"];
          summarySalary = summarySalary + salary;

          salaryInfo["salaryInfo"] = calculatedDataMap;

          await Future.forEach(valueData.entries, (entry) {
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
      String newkey = "";
      Iterable<String> keys = data.keys;
      for (String key in keys) {
        newkey = key;
      }
      final groupName = newkey;
      Map<String, dynamic> valueData = data["${groupName}"];

      Map<String, dynamic> calculatedDataInstance =
          await calculateSalary2(hourlyWage, groupName, valueData);
      calculatedDataMap.addAll(calculatedDataInstance);
      if (calculatedDataInstance["${groupName}"]["totalsalary"] != "0") {
        List salarysplit =
            (calculatedDataInstance["${groupName}"]["totalsalary"].split(","));
        summarySalary =
            summarySalary + int.parse(salarysplit[0] + salarysplit[1]);
      } else {
        summarySalary = 0;
      }
      salaryInfo["salaryInfo"] = calculatedDataMap;

      await Future.forEach(valueData.entries, (entry) {
        var list = ["${groupName}  ${entry.value.toString()}"];
        if (shift["${entry.key}"] == null) {
          shift["${entry.key}"] = list;
        } else {
          final List<String> previousData = shift["${entry.key}"]!;
          previousData.add(list[0]);
        }
      });
    }

    final numformatter = NumberFormat("#,###");
    summarySalaryText = numformatter.format(summarySalary);
  });
  return [shift, salaryInfo, summarySalaryText];
}

Future<Map<String, dynamic>> calculateSalary2(
    hourlyWage, groupName, shiftdata) async {
  int totalsalary = 0;
  double totaldiffhour = 0;
  Map<String, dynamic> result = {};
  Map<String, dynamic> responce = {};
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
    final dataField = shiftdata["${dateString}"];
    if (dataField != null) {
      attendcount++;
      final timeItem = dataField.split(" - ");
      final start = timeItem[0];
      final end = timeItem[1];
      final dayListItemStart = "${dateString} ${start}";
      final dayListItemEnd = "${dateString} ${end}";
      DateTime starttime = formatter.parse(dayListItemStart);
      DateTime endtime = formatter.parse(dayListItemEnd);

      final diffminute = endtime.difference(starttime).inMinutes;
      final diffhour = diffminute / 60;
      final salary = (diffhour * hourlyWage["${groupName}"]).toInt();
      totalsalary = totalsalary + salary;
      totaldiffhour = totaldiffhour + diffhour;
    }
  }
  result["totalsalary"] = totalsalary;
  result["attendcount"] = attendcount;
  result["totaldiffhour"] = totaldiffhour.toStringAsFixed(2);
  responce[groupName] = result;
  return responce;
}

Future<List<String>> getDuration(groupId) async {
  final db = FirebaseFirestore.instance;
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
    DateFormat formatter = DateFormat('yyyy/MM/dd');
    for (int i = 0; i <= difference.inDays; i++) {
      String formattedDate = formatter.format(day_of_start);
      listOfShiftDay.add("${formattedDate}");
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
  groupId,
) async {
  final Map<String, dynamic> uploadData = {};
  final Map<String, dynamic> shift = {};
  final Map<String, dynamic> startshift = {};
  final Map<String, dynamic> endshift = {};
  for (int i = 0; i < duration.length; i++) {
    if (startTimeList[i] != "-" && endTimeList[i] != "-") {
      startshift[duration[i]] = startTimeList[i];
      endshift[duration[i]] = endTimeList[i];
    }
  }
  shift["start"] = startshift;
  shift["end"] = endshift;
  var auth = FirebaseAuth.instance;
  var userId = auth.currentUser?.uid.toString();
  uploadData["${userId}"] = shift;
  print(uploadData);
  final db = FirebaseFirestore.instance;

  await db
      .collection('Groups')
      .doc(groupId)
      .collection("groupInfo")
      .doc("RequestShiftList")
      .set(uploadData);
}

Future getUserInfo(userId) async {
  final db = FirebaseFirestore.instance;

  final docRef =
      db.collection('Users').doc(userId).collection("MyInfo").doc("userInfo");
  var groupId = [];
  DateTime birthday;
  String username = "";
  Map<String, dynamic> hourlyWage = {};
  List<dynamic> userInfo = [];
  try {
    await docRef.get().then(
      onError: (e) => print("Error getting document: $e"),
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        if (data["groupId"].length == 1) {
          print("length is 1");
          groupId.add(data["groupId"]["1"]);
        } else {
          data["groupId"].forEach((key, value) {
            groupId.add(value);
          });
        }
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

Future<bool> getStatus(groupId) async {
  final db = FirebaseFirestore.instance;
  bool status = true;
  final docRef = db
      .collection('Groups')
      .doc(groupId)
      .collection("groupInfo")
      .doc("status");
  await docRef.get().then((DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    status = data["status"];
  });
  return status;
}

Future<List<dynamic>> calculateSalaryReload(
    focusedDay, shiftdata, hourlyWage, groupName) async {
  Map<String, dynamic> result = {};
  DateFormat formatter = DateFormat('yyyy/MM/dd HH:mm');
  final startDay =
      formatter.format(DateTime(focusedDay.year, focusedDay.month, 1));
  final endDay = formatter.format(
      DateTime(focusedDay.year, focusedDay.month + 1, 1)
          .subtract(Duration(days: 1)));
  final firstDay = formatter.parse(startDay);
  final finalDay = formatter.parse(endDay);
  var attendcount = 0;
  String summarySalaryText = "";
  Map<String, dynamic> calculatedDataMap = {};
  int summarySalary = 0;
  Map<String, dynamic> salaryInfo = {};

  for (int i = 0; i < groupName.length; i++) {
    var testDic = {};
    int totalsalary = 0;
    double totaldiffhour = 0;
    var attendcount = 0;
    Map<String, dynamic> result = {};
    Map<String, dynamic> responce = {};

    for (DateTime date = firstDay;
        date.isBefore(finalDay.add(Duration(days: 1)));
        date = date.add(Duration(days: 1))) {
      final dateString = date.toString().split(" ")[0].replaceAll("-", "/");
      final dataField = shiftdata[dateString];
      if (dataField != null) {
        for (int j = 0; j < dataField.length; j++) {
          final listItem = dataField[j].split("  ");
          if (groupName[i] == listItem[0]) {
            attendcount++;
            final timeItem = listItem[1].split(" - ");
            final start = timeItem[0];
            final end = timeItem[1];
            final dayListItemStart = "${dateString} ${start}";
            final dayListItemEnd = "${dateString} ${end}";
            DateTime starttime = formatter.parse(dayListItemStart);
            DateTime endtime = formatter.parse(dayListItemEnd);
            final diffminute = endtime.difference(starttime).inMinutes;
            final diffhour = diffminute / 60;
            final salary = (diffhour * hourlyWage["${groupName[i]}"]).toInt();
            totalsalary = totalsalary + salary;
            totaldiffhour = totaldiffhour + diffhour;
          }
        }
      }
    }
    summarySalary = summarySalary + totalsalary;
    final numformatter = NumberFormat("#,###");
    result["totalsalary"] = numformatter.format(totalsalary);
    result["attendcount"] = attendcount;
    result["totaldiffhour"] = totaldiffhour.toStringAsFixed(2);
    responce["${groupName[i]}"] = result;
    calculatedDataMap.addAll(responce);
    summarySalaryText = numformatter.format(summarySalary);
  }
  salaryInfo["salaryInfo"] = calculatedDataMap;
  return [salaryInfo, summarySalaryText];
}

Future<List> getGroupName(groupId, db) async {
  List groupName = [];

  for (int i = 0; i < groupId.length; i++) {
    final doc_ref_groupname = db
        .collection("Groups")
        .doc(groupId[i])
        .collection("groupInfo")
        .doc("pass");
    await doc_ref_groupname.get().then((DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;
      groupName.add(data["groupName"]);
    });
  }

  return groupName;
}

Future<String> getUserImage(userId) async {
  String userImage = "";
  final storageRef = FirebaseStorage.instance.ref();
  final pathReference =
      storageRef.child("Users/${userId}/UserImage/userImage.png");
  userImage = await pathReference.getDownloadURL();
  return userImage;
}

Future<List> getData(db) async {
  var auth = FirebaseAuth.instance;
  final userId = auth.currentUser?.uid.toString();
  final userInfo = await getUserInfo(userId);
  final groupId = userInfo[0];
  final int groupCount = groupId.length;

  final birthday = userInfo[1];
  final username = userInfo[2];
  final hourlyWage = userInfo[3];

  final shiftdata = await getMyShift(userId, db, hourlyWage);

  final duration = await getDuration(groupId[0]);
  final List<String> startTimeList = await generateEmptyList(duration.length);
  final List<String> endTimeList = await generateEmptyList(duration.length);
  final bool status = await getStatus(groupId[0]);
  final groupName = await getGroupName(groupId, db);
  final Map<String, dynamic> salaryInfo = shiftdata[1]["salaryInfo"];
  final summarySalary = shiftdata[2];

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
  ];
}
