
import 'package:flutter_application_1_shift_manager/refactor/functions/submitExtraShift_func.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;

class addShiftDialog extends StatefulWidget {
  addShiftDialog(
      {super.key,
      required this.selectedDay,
      required this.groupNameMap,
      required this.groupId,
      required this.shiftData});
  String selectedDay = "";
  Map<String, dynamic> groupNameMap = {};
  List<String> groupId = [];
  Map<String, List<String>> shiftData = {};

  @override
  State<addShiftDialog> createState() => _addShiftDialog();
}

class _addShiftDialog extends State<addShiftDialog> {
  String dropdownValue = '';
  String startTime = '';
  String endTime = '';
  Map<String, List<String>> newShiftData = {};
  @override
  void initState() {
    super.initState();
    if (widget.groupId.isNotEmpty) {
      setState(() {
        dropdownValue = widget.groupId.first; // groupIdの最初の要素を初期値とする
      });
    }
  }

  @override
  Widget build(BuildContext content) {
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), //丸み
        ),
        title: const Text(
          "シフト追加",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Text(
                  widget.selectedDay,
                  style: TextStyle(fontSize: 17),
                ),
              ),
              // グループ名を選択するドロップダウンメニューを作る
              DropdownButton<String>(
                value: dropdownValue,
                items: widget.groupId
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(widget.groupNameMap[value]),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  print(
                      "groupName:${widget.groupNameMap[newValue]} groupId:${newValue}");
                  setState(() {
                    dropdownValue = newValue!;
                  });
                },
              ),
              SizedBox(
                height: 20,
              ),
              // ここに時間入力のタイムピッカーを書く
              Container(
                child: Text("勤務時間"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: TextButton(
                      child: (() {
                        if (startTime == "") {
                          return const Text(
                            "00:00",
                            style: TextStyle(color: Colors.grey, fontSize: 23),
                          );
                        } else {
                          return Text(
                            startTime,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 23),
                          );
                        }
                      }()),
                      onPressed: () {
                        picker.DatePicker.showTimePicker(context,
                            showTitleActions: true,
                            showSecondsColumn: false, onCancel: () {
                          setState(() {
                            startTime = "";
                          });
                        }, onConfirm: (date) {
                          setState(() {
                            startTime =
                                "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
                          });
                        },
                            currentTime: DateTime.now(),
                            locale: picker.LocaleType.jp);
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: Text("～"),
                  ),
                  Container(
                    child: TextButton(
                      child: (() {
                        if (endTime == "") {
                          return const Text(
                            "00:00",
                            style: TextStyle(color: Colors.grey, fontSize: 23),
                          );
                        } else {
                          return Text(
                            endTime,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 23),
                          );
                        }
                      }()),
                      onPressed: () {
                        picker.DatePicker.showTimePicker(context,
                            showTitleActions: true,
                            showSecondsColumn: false, onCancel: () {
                          setState(() {
                            endTime = "";
                          });
                        }, onConfirm: (date) {
                          setState(() {
                            endTime =
                                "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
                          });
                        },
                            currentTime: DateTime.now(),
                            locale: picker.LocaleType.jp);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Container(
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("キャンセル")),
                  ),
                  Spacer(),
                  Container(
                    child: ElevatedButton(
                        onPressed: () async{
                          try {
                            String groupName = widget.groupNameMap[dropdownValue];
                            var shift = widget.shiftData[widget.selectedDay];
                            if (shift == null) {
                              var newShift = [
                                "$groupName  $startTime - $endTime"
                              ];
                              newShiftData = widget.shiftData;
                              newShiftData[widget.selectedDay] = newShift;
                            } else {
                              newShiftData = widget.shiftData;
                              newShiftData[widget.selectedDay]!.add(
                                  "$groupName  $startTime - $endTime");
                            }
                            String infoText =await submitExtraShift(startTime,endTime,dropdownValue,widget.selectedDay);
                          } catch (e) {
                            String errorMessage = "error";
                            print(errorMessage);
                          }

                          Navigator.pop(context, newShiftData);
                        },
                        child: Text("保存")),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}