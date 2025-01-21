import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1_shift_manager/refactor/dialogs/loading.dart';
import 'package:flutter_application_1_shift_manager/refactor/screens/main_screen.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:provider/provider.dart';
import '../functions/getdata_func.dart';
import '../dialogs/dialog.dart';
import '../functions/predictsalary_func.dart';

/// シフト提出画面（メイン画面インデックス１）
/// 募集中のシフトに対して希望を入力し送信するページ
/// 募集期間外の場合は入力不可
/* 
機能：
シフトの入力（datetime_pickerを使用）、
予測給与の表示、表示するグループの切換、
募集状況の狂信、シフトの送信のダイアログの起動
*/

class SubmitPage extends StatefulWidget {
  const SubmitPage({super.key});

  @override
  State<SubmitPage> createState() => _SubmitPageState();
}

class _SubmitPageState extends State<SubmitPage> {
  final formatter = DateFormat('d');
  final List<int> colorCodes = <int>[];
  int colorswitch = 0;
  int colorNumber = 100;
  String infoText = "";
  String predictSalary = "0";
  List dataList = [];
  String totalWorkTime = "0";
  Map<String, dynamic> timeList = {};
  Map<String, dynamic> salaryList = {};
  Map<String, dynamic> reloadedData = {};
  bool status = true;
  List<String> duration = [];
  List<String> startTimeList = [];
  List<String> endTimeList = [];
  String groupName = "";
  String groupId = "";
  String hourlyWage = "";
  String? dropdownValue;
  bool minusCheck = true;
  var _groupValue = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "シフト提出",
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 10),
              child: Consumer<DataProvider>(
                  builder: (context, dataProvider, child) {
                return Row(
                  children: [
                    IconButton(
                        alignment: Alignment.centerLeft,
                        onPressed: () async => {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    content: StatefulBuilder(
                                      builder: (BuildContext context,
                                              StateSetter setState) =>
                                          Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: List.generate(
                                          // 配列の要素数だけRadioListTileを生成
                                          dataProvider.groupName.length,
                                          (index) => RadioListTile(
                                            value: index, // 値をインデックスにする
                                            groupValue: _groupValue,
                                            title: Text(dataProvider.groupName[
                                                index]), // テキストをリストの要素から取得
                                            onChanged: (int? value) async {
                                              final newstatus = await getStatus(
                                                  dataProvider.groupId[index]);
                                              final newduration =
                                                  await getDuration(dataProvider
                                                      .groupId[index]);
                                              final newstartTimeList =
                                                  await generateEmptyList(
                                                      newduration.length);
                                              final newendTimeList =
                                                  await generateEmptyList(
                                                      newduration.length);

                                              setState(() {
                                                _groupValue = value!;
                                                groupName = dataProvider
                                                    .groupName[index];
                                                groupId =
                                                    dataProvider.groupId[index];
                                                status = newstatus;
                                                duration = newduration;
                                                startTimeList =
                                                    newstartTimeList;
                                                endTimeList = newendTimeList;
                                                hourlyWage = dataProvider
                                                    .hourlyWage[groupId];
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ).then((value) => setState(() {
                                    reloadedData["status"] = status;
                                    reloadedData["duration"] = duration;
                                    reloadedData["startTimeList"] =
                                        startTimeList;
                                    reloadedData["endTimeList"] = endTimeList;
                                    reloadedData["groupName"] = groupName;
                                    reloadedData["groupId"] = groupId;
                                    reloadedData["hourlyWage"] = hourlyWage;
                                    predictSalary = "0";
                                    totalWorkTime = "0";
                                    timeList = {};
                                    salaryList = {};
                                  }))
                            },
                        icon: const Icon(Icons.tune)),
                    IconButton(
                        onPressed: () async {
                          await loadingDialog(context: context);
                          try {
                            await context
                                .read<DataProvider>()
                                .fetchData()
                                .timeout(const Duration(seconds: 3));
                            Navigator.pop(context);
                          } on TimeoutException catch (e) {
                            print("errorMessage:${e}");
                            var infoText = "更新に失敗しました";
                            Navigator.pop(context);
                            showDialog<bool>(
                                context: context,
                                builder: (_) {
                                  return ResultDialog(infoText: infoText);
                                });
                          }
                          setState(() {
                            predictSalary = "0";
                            totalWorkTime = "0";
                            timeList = {};
                            salaryList = {};
                          });
                        },
                        icon: const Icon(Icons.restart_alt)),
                  ],
                );
              }),
            ),
          ],
          backgroundColor: const Color.fromARGB(255, 228, 228, 228),
        ),
        body: Consumer<DataProvider>(builder: (context, dataProvider, child) {
          return mainSubmitPage(
              reloadedData["status"] ?? dataProvider.status,
              reloadedData["duration"] ?? dataProvider.duration,
              reloadedData["startTimeList"] ?? dataProvider.startTimeList,
              reloadedData["endTimeList"] ?? dataProvider.endTimeList,
              reloadedData["hourlyWage"] ??
                  dataProvider.hourlyWage["${dataProvider.groupId[0]}"],
              reloadedData["groupName"] ?? dataProvider.groupName,
              reloadedData["groupId"] ?? dataProvider.groupId[0]);
        }));
  }

  ///---------------------------------------------------------///

  Center mainSubmitPage(status, duration, startTimeList, endTimeList,
      hourlyWage, groupName, groupId) {
    if (status == false) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                color: const Color.fromARGB(255, 71, 69, 62),
                child: groupName[0] != "no data"
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${reloadedData["groupName"] ?? groupName[0]}は",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const Text(
                            "募集期間中ではありません",
                            style: TextStyle(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "グループに参加していません",
                            style: TextStyle(color: Colors.white70),
                          ),
                          Text(
                            "マイページからグループに参加してください",
                            style: TextStyle(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
              ),
            )
          ],
        ),
      );
    } else {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                  height: 140,

                  ///----------------------------///
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 54, 146, 57),
                          ),
                          child: const Text(
                            "ー 予測給与 ー",
                            style: TextStyle(fontSize: 17, color: Colors.white),
                          ),
                        ),
                        const Spacer(),
                        Text("${reloadedData["groupName"] ?? groupName[0]}",
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                            )),
                        Text("勤務時間$totalWorkTime時間 × 時給$hourlyWage円",
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                            )),
                        const Spacer(),
                        Container(
                            alignment: Alignment.bottomRight,
                            padding: const EdgeInsets.only(
                                top: 5, right: 40, bottom: 5),
                            child: Row(
                              children: [
                                const Spacer(),
                                const Text("=",
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.black)),
                                Text(
                                  "$predictSalary円",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25),
                                ),
                              ],
                            )),
                        const Spacer()
                      ],
                    ),
                  )),
              ////---------------------------//////
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(0),
                itemCount: duration.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    height: 70,
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey)),
                    ),
                    child: Center(

                        ///-------------------↓ListBuilder content-----------------------------------------////
                        child: Row(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.center,
                          height: 70,
                          width: 70,
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 230, 228, 228),
                          ),
                          child: Text(
                              "${duration[index].split("/")[1]}/${duration[index].split("/")[2]}"),
                        ),
                        Expanded(
                          child: TextButton(
                            child: Text(
                              "開始:${startTimeList[index]}",
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            onPressed: () {
                              try {
                                picker.DatePicker.showTimePicker(context,
                                    showTitleActions: true,
                                    showSecondsColumn: false, onCancel: () {
                                  setState(() {
                                    startTimeList[index] = "-";
                                  });
                                }, onConfirm: (date) {
                                  setState(() {
                                    startTimeList[index] =
                                        "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
                                    dataList = calsulatePredictSalary(
                                        startTimeList, endTimeList, hourlyWage);
                                    totalWorkTime = dataList[0];
                                    predictSalary = dataList[1];
                                    timeList = dataList[2];
                                    salaryList = dataList[3];
                                  });
                                },
                                    currentTime: DateTime.now(),
                                    locale: picker.LocaleType.jp);
                              } catch (e) {
                                print(e);
                              }
                            },
                          ),
                        ),
                        Container(
                          width: 30,
                          alignment: Alignment.center,
                          child: const Text("-"),
                        ),
                        Expanded(
                          child: TextButton(
                            child: Text(
                              "終了:${endTimeList[index]}",
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            onPressed: () {
                              try {
                                picker.DatePicker.showTimePicker(context,
                                    showTitleActions: true,
                                    showSecondsColumn: false, onCancel: () {
                                  setState(() {
                                    endTimeList[index] = "-";
                                  });
                                }, onConfirm: (date) {
                                  setState(() {
                                    endTimeList[index] =
                                        "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
                                    dataList = calsulatePredictSalary(
                                        startTimeList, endTimeList, hourlyWage);
                                    totalWorkTime = dataList[0];
                                    predictSalary = dataList[1];
                                    timeList = dataList[2];
                                    salaryList = dataList[3];
                                  });
                                },
                                    currentTime: DateTime.now(),
                                    locale: picker.LocaleType.jp);
                              } catch (e) {
                                print(e);
                              }
                            },
                          ),
                        ),
                        Container(
                          width: 90,
                          decoration: const BoxDecoration(
                              border:
                                  Border(left: BorderSide(color: Colors.grey))),
                          child: Column(
                            children: [
                              Container(
                                  alignment: Alignment.bottomCenter,
                                  decoration: const BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(color: Colors.grey)),
                                  ),
                                  height: 25,
                                  child:
                                      Text("${(timeList["$index"] ?? "0")}h")),
                              Container(
                                  alignment: Alignment.bottomLeft,
                                  padding: const EdgeInsets.only(left: 10),
                                  height: 43,
                                  child: Row(
                                    children: [
                                      const Text("¥"),
                                      Text("${(salaryList["$index"] ?? "0")}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18)),
                                    ],
                                  )),
                            ],
                          ),
                        ),
                      ],
                    )

                        ///-----------------------------↑ListBuilder------------------------------////

                        ),
                  );
                },
              ),
              Container(
                height: 50,
                color: const Color.fromARGB(255, 228, 228, 228),
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 15),
                width: double.infinity,
                height: 100,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0)),
                    backgroundColor: const Color.fromARGB(255, 54, 146, 57),
                  ),
                  onPressed: () async {
                    for (int i = 0; i < salaryList.length; i++) {
                      if (int.parse(salaryList["$i"]) < 0) {
                        print(salaryList["$i"]);
                        minusCheck = false;
                      }
                    }

                    print("minuscheck:${minusCheck}");
                    if (minusCheck) {
                      showDialog<bool>(
                          context: context,
                          builder: (_) {
                            return SubmitDialog(
                              startTimeList: startTimeList,
                              endTimeList: endTimeList,
                              duration: duration,
                              groupId: groupId,
                            );
                          });
                    } else {}
                  },
                  child: const Text(
                    "送信",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
