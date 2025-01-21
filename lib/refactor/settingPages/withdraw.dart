import 'package:flutter/material.dart';
import 'package:flutter_application_1_shift_manager/refactor/dialogs/dialog.dart';
import 'package:flutter_application_1_shift_manager/refactor/screens/main_screen.dart';
import 'package:provider/provider.dart';

/// グループの退会を行うためのページ
///
/// グループからの退会はユーザー自身のドキュメントにあるグループIDのリストから
/// 該当グループのものを削除する処理にしている
/// そのため、グループから退会してもグループのドキュメントに存在するメンバーリスト
/// は変更されない。
/// したがって、退会後にグループの管理者がshiftManager Consoleから手動で削除する必要がある
///
/*
機能：
グループ退会のダイアログの起動
*/

// ignore: must_be_immutable
class Withdraw extends StatefulWidget {
  Withdraw(
      {super.key, required this.groupName,
      required this.groupId,
      required this.groupNameMap});
  List groupName = [];
  List groupId = [];
  Map<String, dynamic> groupNameMap = {};
  @override
  State<Withdraw> createState() => _WithdrawGroup();
}

class _WithdrawGroup extends State<Withdraw> {
  String infoText = "";
  Map<String, dynamic> newGroupIdMap = {};
  int? _groupValue = 0;
  var selectedGroupId = "";


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[350],
        title: const Text(
          "グループを退会",
          style: TextStyle(fontSize: 15),
        ),
        centerTitle: true,
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: (() {
                  if (widget.groupId[0] == "no data") {
                    return const Text("グループに参加していません\n[グループに参加する]から参加申請をしましょう");
                  } else {
                    return const Text(
                        "現在加入しているグループから退会するグループを選び、[退会する] ボタンを押してください。\n\n注意：退会後は退会したグループからの募集や通知を受け取らなくなります。");
                  }
                }()),
              ),
              widget.groupId[0] != "no data"
                  ? StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) =>
                          Column(
                        children: List.generate(
                          // 配列の要素数だけRadioListTileを生成
                          widget.groupId.length,
                          (index) => RadioListTile(
                            value: index, // 値をインデックスにする
                            groupValue: _groupValue,
                            title: Text(
                                widget.groupNameMap[widget.groupId[index]]), // テキストをリストの要素から取得
                            onChanged: (int? value) async {
                              setState(() {
                                _groupValue = value!;
                                selectedGroupId = widget.groupId[index];
                              });
                            },
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(),
              Container(
                margin: const EdgeInsets.only(top: 30),
                height: 45,
                decoration: BoxDecoration(
                    color: const Color(0xFFEB6434),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        spreadRadius: 1.0,
                        blurRadius: 8.0,
                        offset: Offset(3, 3),
                      )
                    ]),
                child: widget.groupId[0] != "no data"
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          backgroundColor: const Color(0xFFEB6434),
                        ),
                        onPressed: () async {
                          if (widget.groupId.length == 1 &&
                              widget.groupId[0] == selectedGroupId) {
                            newGroupIdMap["1"] = "no data";
                          } else {
                            for (int i = 0; i < widget.groupId.length; i++) {
                              int k =1;
                              if (widget.groupId[i] !=
                                  selectedGroupId) {
                                  newGroupIdMap["${k}"] = widget.groupId[i];
                                  k++;
                              }
                            }
                          }

                          await showDialog<void>(
                              context: context,
                              builder: (_) {
                                return WithdrawDialog(
                                  newGroupId: newGroupIdMap,
                                  groupId: widget.groupId,
                                );
                              });
                        },
                        child: const Text(
                          "退会する",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ))
                    : const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
