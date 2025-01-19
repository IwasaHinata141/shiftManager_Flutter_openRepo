
import 'package:flutter/material.dart';
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
  HourlyWage({super.key, 
    required this.hourlyWage,
    required this.groupName,
    required this.groupId
  });
  Map<String, dynamic> hourlyWage = {};
  List groupName = [];
  List groupId = [];

  @override
  State<HourlyWage> createState() => _HourlyWage();
}

class _HourlyWage extends State<HourlyWage> {
  var userId;
  String infoText1 = "";
  String newHourlyWage = "";
  Map<String, dynamic> newHourlyWageMap = {};
  
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
        title: const Text("時給設定"),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider(
                        create: (_) => DataProvider(),
                        child: MyHomePage(
                          count: 2,
                        ))));
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
                    return 
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey)),
                      child: Column(
                        children: [
                          Container(
                            height: 58,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.only(right: 40, left: 40),
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(color: Colors.grey))),
                            child: Text(widget.groupName[index]),
                          ),
                          Row(
                            children: [
                              Container(
                                  width: 130,
                                  height: 58,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          right:
                                              BorderSide(color: Colors.grey))),
                                  child: Text(
                                      "${widget.hourlyWage["${widget.groupId[index]}"]} 円")),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.only(left: 10, right: 10),
                                height: 58,
                                width: 200,
                                alignment: Alignment.center,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 150,
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          border: UnderlineInputBorder(),
                                        ),
                                        onChanged: (String value) {
                                          setState(() {
                                            newHourlyWage = value;

                                            newHourlyWageMap[
                                                    "${widget.groupId[index]}"] =
                                                int.parse(newHourlyWage);
                                          });
                                        },
                                      ),
                                    ),
                                    const Text("円"),
                                  ],
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Container(
                  margin: const EdgeInsets.only(top: 50),
                  height: 50,
                  width: 100,
                  child: ElevatedButton(
                      onPressed: () async {
                        if (newHourlyWage != "") {
                          try {
                            editMyhourlyWage(newHourlyWageMap);
                            setState(() {
                              infoText1 = "変更しました。";
                            });
                          } catch (e) {
                            setState(() {
                              infoText1 = "エラー";
                            });
                          }
                        } else {
                          setState(() {
                            infoText1 = "項目を埋めてください";
                          });
                        }
                      },
                      child: const Text("変更")),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(infoText1),
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
