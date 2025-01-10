import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1_shift_manager/refactor/actions/request_action.dart';
import 'package:flutter_application_1_shift_manager/refactor/screens/main_screen.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:provider/provider.dart';
import '../actions/getdata_action.dart';
import '../dialogs/dialog.dart';
import '../actions/predictSalary_action.dart';

class SubmitPage extends StatefulWidget {
  @override
  _SubmitPageState createState() => _SubmitPageState();
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
  int hourlyWage = 0;
  String? dropdownValue;
  var _groupValue = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "シフト提出",
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            Consumer<DataProvider>(builder: (context, dataProvider, child) {
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
                                        (num) => RadioListTile(
                                          value: num, // 値をインデックスにする
                                          groupValue: _groupValue,
                                          title: Text(dataProvider.groupName[
                                              num]), // テキストをリストの要素から取得
                                          onChanged: (int? value) async {
                                            final newstatus = await getStatus(
                                                dataProvider.groupId[num]);
                                            final newduration =
                                                await getDuration(
                                                    dataProvider.groupId[num]);
                                            final newstartTimeList =
                                                await generateEmptyList(
                                                    newduration.length);
                                            print(newstartTimeList);
                                            final newendTimeList =
                                                await generateEmptyList(
                                                    newduration.length);
                                            print(newendTimeList);

                                            setState(() {
                                              _groupValue = value!;
                                              groupName =
                                                  dataProvider.groupName[num];
                                              groupId = dataProvider.groupId[num];
                                              status = newstatus;
                                              duration = newduration;
                                              startTimeList = newstartTimeList;
                                              endTimeList = newendTimeList;
                                              hourlyWage = dataProvider.hourlyWage["${groupName}"];
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
                                  reloadedData["startTimeList"] = startTimeList;
                                  reloadedData["endTimeList"] = endTimeList;
                                  reloadedData["groupName"] = groupName;
                                  reloadedData["groupId"] = groupId;
                                  reloadedData["hourlyWage"] = hourlyWage;
                                }))
                          },
                      icon: const Icon(Icons.tune)),
                  IconButton(
                      onPressed: () => {
                            context.read<DataProvider>().fetchData(),
                            setState(() {
                              predictSalary = "0";
                              totalWorkTime = "0";
                              timeList = {};
                              salaryList = {};
                            })
                          },
                      icon: const Icon(Icons.restart_alt)),
                ],
              );
            }),
          ],
          backgroundColor: Color.fromARGB(255, 228, 228, 228),
        ),
        body: Consumer<DataProvider>(builder: (context, dataProvider, child) {
          return mainSubmitPage(
              reloadedData["status"] ?? dataProvider.status,
              reloadedData["duration"] ?? dataProvider.duration,
              reloadedData["startTimeList"] ?? dataProvider.startTimeList,
              reloadedData["endTimeList"] ?? dataProvider.endTimeList,
              reloadedData["hourlyWage"] ?? dataProvider.hourlyWage["${dataProvider.groupName[0]}"],
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
                child: groupName[0] !="no data" ?
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,   
                    children: [
                      Text(
                        "${reloadedData["groupName"] ?? groupName[0]}は",
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        "募集期間中ではありません",
                        style: TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ):Container(
                  child: Column(
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
              Container(
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
                        Spacer(),
                        Text("${reloadedData["groupName"] ?? groupName[0]}",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                            )),
                        Text("勤務時間${totalWorkTime}時間 × 時給${hourlyWage}円",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                            )),
                        Spacer(),
                        Container(
                            alignment: Alignment.bottomRight,
                            padding:
                                EdgeInsets.only(top: 5, right: 40, bottom: 5),
                            child: Container(
                              child: Row(
                                children: [
                                  Spacer(),
                                  Text("=",
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.black)),
                                  Text(
                                    "${predictSalary}円",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25),
                                  ),
                                ],
                              ),
                            )),
                        Spacer()
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
                          child: Text("${duration[index].split("/")[1]}/${duration[index].split("/")[2]}"),
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
                                  print("cancel");
                                  setState(() {
                                    startTimeList[index] = "-";
                                  });
                                }, onConfirm: (date) {
                                  print(date);
                                  setState(() {
                                    startTimeList[index] =
                                        "${date.hour.toString()}:${date.minute.toString().padLeft(2, '0')}";
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
                          child: Text("-"),
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
                                  print("cancel");
                                  setState(() {
                                    endTimeList[index] = "-";
                                  });
                                }, onConfirm: (date) {
                                  print(date);
                                  setState(() {
                                    endTimeList[index] =
                                        "${date.hour.toString()}:${date.minute.toString().padLeft(2, '0')}";
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
                          decoration: BoxDecoration(
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
                                  child: Text(
                                      "${(timeList["${index}"] ?? "0")}h")),
                              Container(
                                  alignment: Alignment.bottomLeft,
                                  padding: EdgeInsets.only(left: 10),
                                  height: 43,
                                  child: Row(
                                    children: [
                                      Text("¥"),
                                      Text("${(salaryList["${index}"] ?? "0")}",
                                          style: TextStyle(
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
                color: Color.fromARGB(255, 228, 228, 228),
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 15),
                width: double.infinity,
                height: 100,
                child: ElevatedButton(
                  child: Text(
                    "送信",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0)),
                    backgroundColor: Color.fromARGB(255, 54, 146, 57),
                  ),
                  onPressed: () async {
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
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
