import 'package:flutter/material.dart';
import 'package:flutter_application_1_shift_manager/refactor/dialogs/dialog.dart';
import 'package:flutter_application_1_shift_manager/refactor/dialogs/loading.dart';
import '../screens/main_screen.dart';
import 'package:provider/provider.dart';
import '../functions/setting_func.dart';

/// 時給設定をするためのページ
/// 変更前の初期状態では時給は1000円になっている
/* 
機能：
グループごとの時給の変更
*/

// ignore: must_be_immutable
class HourlyWage extends StatefulWidget {
  HourlyWage(
      {super.key,
      required this.hourlyWage,
      required this.groupName,
      required this.groupId,
      required this.groupNameMap});
  Map<String, dynamic> hourlyWage = {};
  List groupName = [];
  List groupId = [];
  Map<String, dynamic> groupNameMap = {};

  @override
  State<HourlyWage> createState() => _HourlyWage();
}

class _HourlyWage extends State<HourlyWage> {
  var userId;
  String infoText1 = "";
  String newHourlyWage = "";
  Map<String, dynamic> newHourlyWageMap = {};
  int currentIndex = 999;

  @override
  void initState() {
    for (int i = 0; i < widget.groupId.length; i++) {
      newHourlyWageMap["${widget.groupId[i]}"] =
          widget.hourlyWage["${widget.groupId[i]}"];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey[350],
        title: const Text(
          "時給設定",
          style: TextStyle(fontSize: 15),
        ),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.groupId.length,
                  itemBuilder: (context, index) {
                    return Container(
                      height: 170,
                      width: double.infinity,
                      margin: const EdgeInsets.only(
                          top: 10, bottom: 15, left: 5, right: 5),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.grey,
                              spreadRadius: 1.0,
                              blurRadius: 10.0,
                              offset: Offset(5, 5),
                            ),
                          ]),
                      child: Column(
                        children: [
                          Container(
                            height: 55,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 40, right: 40),
                            child: Row(
                              children: [
                                Container(
                                  decoration: const BoxDecoration(),
                                  child: Text("${widget.groupName[index]}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18)),
                                ),
                                const Spacer(),
                                Container(
                                  child: (() {
                                    if (currentIndex == index) {
                                      return const Icon(
                                          Icons.radio_button_checked,
                                          color: Color(0xFFEB6434));
                                    } else {
                                      return const Icon(
                                          Icons.radio_button_unchecked,
                                          color: Color(0xFF9DA39B));
                                    }
                                  }()),
                                ),
                              ],
                            ),
                          ),
                          Container(
                              height: 55,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 40),
                              decoration: const BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(color: Colors.grey))),
                              child: Text(
                                  "現在の時給 : ${widget.hourlyWage["${widget.groupId[index]}"]} 円")),
                          Container(
                            padding: const EdgeInsets.only(left: 40, right: 40),
                            height: 55,
                            alignment: Alignment.center,
                            child: Row(
                              children: [
                                const Text("新しい時給  :  "),
                                Expanded(
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      border: UnderlineInputBorder(),
                                    ),
                                    onChanged: (String value) {
                                      setState(() {
                                        newHourlyWage = value;
                                        currentIndex = index;

                                        newHourlyWageMap[
                                                "${widget.groupId[index]}"] =
                                            newHourlyWage;
                                      });
                                    },
                                  ),
                                ),
                                const Text("円"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  height: 50,
                  width: 100,
                  decoration: BoxDecoration(
                      color: const Color(0xFF36AB13),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          spreadRadius: 1.0,
                          blurRadius: 15.0,
                          offset: Offset(3, 3),
                        )
                      ]),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        backgroundColor: const Color(0xFF36AB13),
                      ),
                      onPressed: () async {
                        if (newHourlyWage == "") {
                          infoText1 = "項目を埋めてください";
                        } else {
                          await loadingDialog(context: context);
                          try {
                            int number = int.parse(newHourlyWage);
                            if (number > 0) {
                              try {
                                await editMyhourlyWage(newHourlyWageMap);
                                infoText1 =
                                    "${widget.groupNameMap[widget.groupId[currentIndex]]}の時給を\n$newHourlyWage円に変更しました";
                              } catch (e) {
                                infoText1 = "更新に失敗しました";
                              }
                            } else {
                              infoText1 = "自然数で入力してください";
                            }
                          } catch (e) {
                            infoText1 = "フォーマットが違います";
                          }

                          Navigator.pop(context);
                        }
                        showDialog<bool>(
                            context: context,
                            builder: (_) {
                              return ResultDialog(infoText: infoText1);
                            });
                      },
                      child: const Text(
                        "変更",
                        style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 15),
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // ignore: non_constant_identifier_names
}
