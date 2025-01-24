import 'package:flutter_application_1_shift_manager/refactor/functions/submit_edited_shift_func.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class DeleteShiftDialog extends StatefulWidget {
  DeleteShiftDialog(
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
  State<DeleteShiftDialog> createState() => _DeleteShiftDialog();
}

class _DeleteShiftDialog extends State<DeleteShiftDialog> {
  List<String> startTime = [];
  List<String> endTime = [];
  Map<String, List<String>> newShiftData = {};
  List<dynamic> relatedGroupId = [];
  int _shiftValue = 0;
  var selectedGroupId = "";
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
          "シフト削除",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                  child: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) =>
                        Column(
                      children: List.generate(
                        // 配列の要素数だけRadioListTileを生成
                        relatedGroupId.length,
                        (index) => RadioListTile(
                          value: index, // 値をインデックスにする
                          groupValue: _shiftValue,
                          title: Column(
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                    "${widget.groupNameMap[relatedGroupId[index]]}"),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    startTime[index],
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 23),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 5),
                                    child: const Text("～"),
                                  ),
                                  Text(
                                    endTime[index],
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 23),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onChanged: (int? value) async {
                            setState(() {
                              _shiftValue = value!;
                              selectedGroupId = widget.groupId[value];
                            });
                          },
                        ),
                      ),
                    ),
                  )),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("キャンセル")),
                  const Spacer(),
                  ElevatedButton(
                      onPressed: () async {
                        Map<String, dynamic> submitData = widget.rawShift;
                        newShiftData = widget.shiftData;
                        try {
                          for (int i = 0; i < relatedGroupId.length; i++) {
                            if (i == _shiftValue) {
                              submitData[relatedGroupId[i]]
                                  .remove(widget.selectedDay);
                              newShiftData[widget.selectedDay]
                                  ?.removeAt(_shiftValue);
                            }
                          }
                  
                          String responceMassage =
                              await submitEditedShift(submitData);
                          print(responceMassage);
                        } catch (e) {
                          String errorMessage = "error";
                          print(errorMessage);
                        }
                  
                        Navigator.pop(context, newShiftData);
                      },
                      child: const Text("削除")),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
