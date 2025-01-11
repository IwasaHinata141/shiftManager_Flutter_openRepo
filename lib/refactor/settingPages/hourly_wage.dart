import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../screens/main_screen.dart';
import 'package:provider/provider.dart';
import '../functions/setting_func.dart';

class HourlyWage extends StatefulWidget {
  HourlyWage({
    required this.hourlyWage,
    required this.groupName,
  });
  Map<String, dynamic> hourlyWage = {};
  List groupName = [];

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
   

    for (int i = 0; i < widget.groupName.length; i++) {
      newHourlyWageMap["${widget.groupName[i]}"] =
          widget.hourlyWage["${widget.groupName[i]}"];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey[350],
        title: Text("時給設定"),
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
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: widget.groupName.length,
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
                            child: Text(widget.groupName[index]),
                            padding: EdgeInsets.only(right: 40, left: 40),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(color: Colors.grey))),
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
                                      "${widget.hourlyWage["${widget.groupName[index]}"]} 円")),
                              Spacer(),
                              Container(
                                padding: EdgeInsets.only(left: 10, right: 10),
                                height: 58,
                                width: 200,
                                alignment: Alignment.center,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 150,
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          border: UnderlineInputBorder(),
                                        ),
                                        onChanged: (String value) {
                                          setState(() {
                                            newHourlyWage = value;

                                            newHourlyWageMap[
                                                    "${widget.groupName[index]}"] =
                                                int.parse(newHourlyWage);
                                          });
                                        },
                                      ),
                                    ),
                                    Text("円"),
                                  ],
                                ),
                              ),
                              Spacer(),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                /*
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
                        child: Text(widget.groupName[0]),
                        padding: EdgeInsets.only(right: 40, left: 40),
                        decoration: BoxDecoration(
                            border:
                                Border(bottom: BorderSide(color: Colors.grey))),
                      ),
                      Row(
                        children: [
                          Container(
                              width: 130,
                              height: 58,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                  border: Border(
                                      right: BorderSide(color: Colors.grey))),
                              child: Text("${widget.hourlyWage} 円")),
                          Spacer(),
                          Container(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            height: 58,
                            width: 200,
                            alignment: Alignment.center,
                            child: Row(
                              children: [
                                Container(
                                  width: 150,
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      border: UnderlineInputBorder(),
                                    ),
                                    onChanged: (String value) {
                                      setState(() {
                                        newHourlyWage = value;
                                      });
                                    },
                                  ),
                                ),
                                Text("円"),
                              ],
                            ),
                          ),
                          Spacer(),
                        ],
                      ),
                    ],
                  ),
                ),*/
                Container(
                  margin: EdgeInsets.only(top: 50),
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
                      child: Text("変更")),
                ),
                Container(
                  padding: EdgeInsets.only(top: 10),
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
