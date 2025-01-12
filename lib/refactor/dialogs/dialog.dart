import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_application_1_shift_manager/refactor/functions/submit_func.dart';
import '../login_items/login.dart';
import 'package:flutter/material.dart';

/// このファイルはダイアログのウィジェットをまとめたファイル
/// ダイアログは主にフールプルーフ目的で作っている
/// 
/// 今後ダイアログを作る必要があると思われる処理
/// ・グループ参加申請
/// ・メールアドレス・パスワード申請
/// ・新規アカウントと登録


class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      content: const Text('ログアウトしてよろしいですか'),
      actions: <Widget>[
        CupertinoDialogAction(
          child: const Text('キャンセル', style: TextStyle(color: Colors.blueAccent)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        CupertinoDialogAction(
          child: const Text(
            'ログアウト',
            style: TextStyle(color: Colors.redAccent),
          ),
          onPressed: () async {
            try {
              final FirebaseAuth auth = FirebaseAuth.instance;
              await auth.signOut();
              // ignore: use_build_context_synchronously
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            } catch (e) {
              print("error");
            }
          },
        )
      ],
    );
  }
}

// ignore: must_be_immutable
class SubmitDialog extends StatelessWidget {
  SubmitDialog({
    super.key,
    required this.startTimeList,
    required this.endTimeList,
    required this.duration,
    required this.groupId,
  });
  List<String> startTimeList;
  List<String> endTimeList;
  List<String> duration = [];
  String groupId = "";
  bool responce = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text('シフトを提出しますか'),
      content: const Text("※提出したシフトは取り消しできません"),
      actions: <Widget>[
        CupertinoDialogAction(
          child: const Text('キャンセル', style: TextStyle(color: Colors.blueAccent)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        CupertinoDialogAction(
          child: const Text(
            '提出',
            style: TextStyle(color: Colors.blueAccent),
          ),
          onPressed: () async {
            await submitMyshift(startTimeList, endTimeList, duration, groupId);
            // ignore: use_build_context_synchronously
            Navigator.pop(context);
          },
        )
      ],
    );
  }
}

// ignore: must_be_immutable
class WithdrawDialog extends StatelessWidget {
  WithdrawDialog({super.key, required this.newGroupId});
  Map<String,dynamic> newGroupId = {};

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      content: const Text("グループを退会しますか"),
      actions: <Widget>[
        CupertinoDialogAction(
          child: const Text('キャンセル', style: TextStyle(color: Colors.blueAccent)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        CupertinoDialogAction(
          child: const Text(
            '退会する',
            style: TextStyle(color: Colors.blueAccent),
          ),
          onPressed: () async {
            if (newGroupId["1"] != null) {
              final db = FirebaseFirestore.instance;
              final auth = FirebaseAuth.instance;
              final userId = auth.currentUser?.uid.toString();
              
              await db
                  .collection('Users')
                  .doc(userId)
                  .collection("MyInfo")
                  .doc("userInfo")
                  .update({"groupId": newGroupId});
                  
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
            }
          },
        )
      ],
    );
  }
}
