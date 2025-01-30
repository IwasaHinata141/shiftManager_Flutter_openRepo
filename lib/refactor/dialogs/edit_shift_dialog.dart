import 'package:flutter_application_1_shift_manager/refactor/dialogs/loading_dialog.dart';
import 'package:flutter_application_1_shift_manager/refactor/functions/submit_edited_shift_func.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;

// ignore: must_be_immutable
class EditShiftDialog extends StatefulWidget {
  EditShiftDialog(
      {super.key,
      required this.selectedDay,
      required this.groupNameMap,
      required this.groupId,
      required this.shiftData,
      required this.rawShift});
  String selectedDay = "";
  Map<String, dynamic> groupNameMap = {};
  List<String> groupId = [];
  Map<String, List<String>> shiftData = {};
  Map<String, dynamic> rawShift = {};

  @override
  State<EditShiftDialog> createState() => _EditShiftDialog();
}

class _EditShiftDialog extends State<EditShiftDialog> {
  List<String> startTime = [];
  List<String> endTime = [];
  Map<String, List<String>> newShiftData = {};
  List<dynamic> relatedGroupId = [];
  String infoText = "";
  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.groupId.length; i++) {
      var shiftMap = widget.rawShift[widget.groupId[i]];
      if (shiftMap[widget.selectedDay] != null) {
        var flagment = shiftMap[widget.selectedDay].split(" - ");
        setState(() {
          relatedGroupId.add(widget.groupId[i]);
          startTime.add(flagment[0]);
          endTime.add(flagment[1]);
        });
      }
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
          "シフト編集",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.maxFinite,
                alignment: Alignment.center,
                child: Text(infoText),
              ),
              Container(
                width: double.maxFinite,
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.selectedDay,
                  style: const TextStyle(fontSize: 17),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              SizedBox(
                width: double.maxFinite,
                height: 200,
                child: ListView.builder(
                    itemCount: relatedGroupId.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.grey,
                                  spreadRadius: 1.0,
                                  blurRadius: 10.0,
                                  offset: Offset(3, 3),
                                )
                              ]),
                          child: Column(
                            children: [
                              Container(
                                alignment: Alignment.bottomLeft,
                                padding: const EdgeInsets.only(left: 15),
                                child: Text(
                                    widget.groupNameMap[relatedGroupId[index]]),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    child: (() {
                                      return Text(
                                        startTime[index],
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 23),
                                      );
                                    }()),
                                    onPressed: () {
                                      picker.DatePicker.showTimePicker(context,
                                          showTitleActions: true,
                                          showSecondsColumn: false,
                                          onCancel: () {}, onConfirm: (date) {
                                        setState(() {
                                          startTime[index] =
                                              "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
                                        });
                                      },
                                          currentTime: DateTime.now(),
                                          locale: picker.LocaleType.jp);
                                    },
                                  ),
                                  Container(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 5),
                                    child: const Text("～"),
                                  ),
                                  TextButton(
                                    child: (() {
                                      return Text(
                                        endTime[index],
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 23),
                                      );
                                    }()),
                                    onPressed: () {
                                      picker.DatePicker.showTimePicker(context,
                                          showTitleActions: true,
                                          showSecondsColumn: false,
                                          onCancel: () {}, onConfirm: (date) {
                                        setState(() {
                                          endTime[index] =
                                              "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
                                        });
                                      },
                                          currentTime: DateTime.now(),
                                          locale: picker.LocaleType.jp);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context,widget.shiftData);
                      },
                      child: const Text("キャンセル")),
                  const Spacer(),
                  ElevatedButton(
                      onPressed: () async {
                        Map<String, dynamic> submitDataInstance = {};
                        List<String> newShiftDataInstance = [];
                        newShiftData = widget.shiftData;
                        bool timeoutCheck = false;
                        bool minusCheck = true;
                        for (int j = 0; j < relatedGroupId.length; j++) {
                          DateTime startDate =
                              DateTime.parse("2025-01-20 ${startTime[j]}:00");
                          DateTime endDate =
                              DateTime.parse("2025-01-20 ${endTime[j]}:00");
                         
                          if (endDate.isBefore(startDate)) {
                            minusCheck = false;
                          }
                        }
                        if (minusCheck) {
                          await loadingDialog(context: context);
                          try {
                            for (int i = 0; i < relatedGroupId.length; i++) {
                              Map<String, dynamic> submitText = {};
                              submitText[widget.selectedDay] =
                                  "${startTime[i]} - ${endTime[i]}";
                              submitDataInstance[relatedGroupId[i]] = {}
                                ..addAll(widget.rawShift[relatedGroupId[i]])
                                ..addAll(submitText);
                              newShiftDataInstance.add(
                                  "${widget.groupNameMap[relatedGroupId[i]]}  ${startTime[i]} - ${endTime[i]}");
                              newShiftData[widget.selectedDay] =
                                  newShiftDataInstance;
                            }

                            Map<String, dynamic> submitData = {}
                              ..addAll(widget.rawShift)
                              ..addAll(submitDataInstance);

                            await submitEditedShift(submitData).timeout(
                              const Duration(seconds: 5),
                              onTimeout: () {
                                timeoutCheck = true;
                                print("タイムアウトしました。");
                              },
                            );
                            if (timeoutCheck) {
                              Navigator.pop(context);
                              setState(() {
                                infoText = "タイムアウトしました";
                              });
                            } else {
                              Navigator.pop(context);
                              Navigator.pop(context, newShiftData);
                            }
                          } on Exception {
                            Navigator.pop(context);
                            setState(() {
                              infoText = "処理に失敗しました";
                            });
                          }
                        } else {
                          setState(() {
                            infoText = "開始時刻を終了時刻より遅い時刻にしないで下さい";
                          });
                        }
                      },
                      child: const Text("保存")),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
