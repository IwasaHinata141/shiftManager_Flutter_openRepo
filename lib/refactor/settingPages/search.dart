import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1_shift_manager/refactor/dialogs/dialog.dart';
import 'package:flutter_application_1_shift_manager/refactor/dialogs/loading.dart';
import '../screens/main_screen.dart';
import 'package:flutter_application_1_shift_manager/refactor/functions/request_func.dart';
import 'package:provider/provider.dart';

/// グループへの参加申請を行うためのページ
/// グループの検索はグループIDを使い、その後グループのパスワードを入力して参加申請を行う
/* 
機能：
グループの検索、
グループへの参加申請
*/

class SearchGroup extends StatefulWidget {
  const SearchGroup({super.key});

  @override
  State<SearchGroup> createState() => _SearchGroup();
}

class _SearchGroup extends State<SearchGroup> {
  String groupId = "";
  String infoText = "";
  List groupName = [];
  List adminName = [];
  List memberNum = [];
  String pass = "";
  String infoText2 = "";
  String inputPass = "";

  var userId = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey[350],
        title: const Text(
          "グループ検索",
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "グループID",
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                          color: Color(0xFF737971),
                          width: 2.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                          color: Color(0xFF36AB13),
                          width: 4.0,
                        ),
                      ),
                    ),
                    onChanged: (String value) {
                      setState(() {
                        groupId = value;
                      });
                    },
                  ),
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
                          blurRadius: 8.0,
                          offset: Offset(3, 3),
                        )
                      ]),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      backgroundColor: const Color(0xFF36AB13),
                    ),
                    child: const Text(
                      "検索",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                    onPressed: () async {
                      try {
                        List<String> groupData = await search(groupId);
                        setState(() {
                          groupName = [];
                          adminName = [];
                          memberNum = [];
                          groupName.add(groupData[0]);
                          adminName.add(groupData[1]);
                          memberNum.add(groupData[2]);
                        });
                      } catch (e) {
                        setState(() {
                          infoText = "該当するグループが存在しません";
                        });
                      }
                    },
                  ),
                ),
                ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: groupName.length,
                    itemBuilder: (context, index) {
                      return Container(
                        height: 170,
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.only(top: 30),
                        padding: const EdgeInsets.only(left: 40, right: 20),
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
                              child: Row(
                                children: [
                                  Container(
                                    child: Text("${groupName[index]}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20)),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    child: const Icon(
                                      Icons.lock,
                                      size: 20,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  RequestGroup(
                                                    groupName: groupName[index],
                                                    adminName: adminName[index],
                                                    memberNum: memberNum[index],
                                                    groupId: groupId,
                                                  )));
                                    },
                                    icon: const Icon(Icons.chevron_right),
                                    padding: const EdgeInsets.all(10),
                                  )
                                ],
                              ),
                            ),
                            Container(
                                height: 55,
                                alignment: Alignment.centerLeft,
                                decoration: const BoxDecoration(),
                                child: Text("管理者名 : ${adminName[index]}")),
                            Container(
                                height: 55,
                                alignment: Alignment.centerLeft,
                                decoration: const BoxDecoration(),
                                child: Text("参加人数 : ${memberNum[index]}"))
                          ],
                        ),
                      );
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
  // ignore: non_constant_identifier_names
}

// ignore: must_be_immutable
class RequestGroup extends StatefulWidget {
  RequestGroup({
    super.key,
    required this.groupName,
    required this.adminName,
    required this.memberNum,
    required this.groupId,
  });
  String groupName = "";
  String adminName = "";
  String memberNum = "";
  String groupId = "";
  @override
  State<RequestGroup> createState() => _RequestGroup();
}

class _RequestGroup extends State<RequestGroup> {
  String password = "";
  String responce = "";
  var userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey[350],
        title: const Text(
          "参加申請",
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
                Container(
                  height: 450,
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
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
                        alignment: Alignment.centerLeft,
                        child: const Text("グループ名",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20)),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        height: 40,
                        child: Text(widget.groupName),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: const Text("管理者",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20)),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        height: 40,
                        child: Text(widget.adminName),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: const Text("参加人数",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20)),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        height: 40,
                        child: Text("${widget.memberNum}人"),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 10, bottom: 15),
                        child: const Text("パスワードを入力してください"),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: "パスワード",
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                color: Color(0xFF737971),
                                width: 2.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                color: Color(0xFF36AB13),
                                width: 4.0,
                              ),
                            ),
                          ),
                          onChanged: (String value) {
                            setState(() {
                              password = value;
                            });
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        height: 50,
                        width: 120,
                        decoration: BoxDecoration(
                            color: const Color(0xFF36AB13),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.grey,
                                spreadRadius: 1.0,
                                blurRadius: 8.0,
                                offset: Offset(3, 3),
                              )
                            ]),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            backgroundColor: const Color(0xFF36AB13),
                          ),
                          child: const Text(
                            "加入申請",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                          onPressed: () async {
                            if (password == "") {
                              responce = "項目を埋めてください";
                            } else {
                              await loadingDialog(context: context);
                              try {
                                var auth = FirebaseAuth.instance;
                                userId = auth.currentUser!.uid.toString();
                                responce = await request(
                                    widget.groupId, userId, password);
                              } catch (e) {
                                responce = "エラーが発生しました";
                              }
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context);
                            }
                            showDialog<bool>(
                                // ignore: use_build_context_synchronously
                                context: context,
                                builder: (_) {
                                  return ResultDialog(infoText: responce);
                                });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
