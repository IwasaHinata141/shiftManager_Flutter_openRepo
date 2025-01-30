import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_application_1_shift_manager/refactor/functions/submit_func.dart';
import '../login_items/login.dart';
import 'package:flutter/material.dart';
import 'loading_dialog.dart';

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
          child:
              const Text('キャンセル', style: TextStyle(color: Colors.blueAccent)),
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
            await loadingDialog(context: context);
            try {
              final FirebaseAuth auth = FirebaseAuth.instance;
              await auth.signOut();
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
              // ignore: use_build_context_synchronously
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            } catch (e) {
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
              showDialog<bool>(
                  // ignore: use_build_context_synchronously
                  context: context,
                  builder: (_) {
                    return ResultDialog(infoText: "エラー");
                  });
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
          child:
              const Text('キャンセル', style: TextStyle(color: Colors.blueAccent)),
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
            await loadingDialog(context: context);
            final infoText = await submitMyshift(
                startTimeList, endTimeList, duration, groupId);
            // ignore: use_build_context_synchronously
            Navigator.pop(context);
            showDialog<bool>(
                barrierDismissible: false,
                // ignore: use_build_context_synchronously
                context: context,
                builder: (_) {
                  return ResultDialogPopToRoot(infoText: infoText);
                });
          },
        )
      ],
    );
  }
}

// ignore: must_be_immutable
class ResultDialog extends StatelessWidget {
  ResultDialog({super.key, required this.infoText});
  String infoText = "";
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(infoText),
      actions: [
        GestureDetector(
          child: const Text("閉じる"),
          onTap: (){
            Navigator.pop(context);
          },
        )
      ],
    );
  }
}

// ignore: must_be_immutable
class ResultDialogPopToRoot extends StatelessWidget {
  ResultDialogPopToRoot({super.key, required this.infoText});
  String infoText = "";
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(infoText),
      actions: [
        GestureDetector(
          child: const Text("閉じる"),
          onTap: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        )
      ],
    );
  }
}

// ignore: must_be_immutable
class WithdrawDialog extends StatelessWidget {
  WithdrawDialog({super.key, required this.newGroupId, required this.groupId});
  Map<String, dynamic> newGroupId = {};
  String responce = "";
  List groupId = [];

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      content: const Text("グループを退会しますか"),
      actions: <Widget>[
        CupertinoDialogAction(
          child:
              const Text('キャンセル', style: TextStyle(color: Colors.blueAccent)),
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
            print(newGroupId);
            if (newGroupId["1"] != null) {
              try {
                final db = FirebaseFirestore.instance;
                final auth = FirebaseAuth.instance;
                final userId = auth.currentUser?.uid.toString();

                await db
                    .collection('Users')
                    .doc(userId)
                    .collection("MyInfo")
                    .doc("userInfo")
                    .update({"groupId": newGroupId});
                responce = "処理が完了しました";
              } catch (e) {
                responce = "エラー";
              }

              // ignore: use_build_context_synchronously
            } else {
              responce = "選択されていません";
            }
            if (responce == "処理が完了しました") {
              showDialog<bool>(
                  // ignore: use_build_context_synchronously
                  barrierDismissible: false,
                  context: context,
                  builder: (_) {
                    return ResultDialogPopToRoot(infoText: responce);
                  });
            } else {
              showDialog<bool>(
                  // ignore: use_build_context_synchronously
                  barrierDismissible: false,
                  context: context,
                  builder: (_) {
                    return ResultDialog(infoText: responce);
                  });
            }
          },
        )
      ],
    );
  }
}

class MinusCheckDialog extends StatelessWidget {
  const MinusCheckDialog({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("入力に誤りがあります"),
      content: const Text("開始時刻が終了時刻より遅くなっている箇所があります。\n日を跨ぐ場合は二日に分けて入力してください"),
      actions: [
        GestureDetector(
          child: const Text("閉じる"),
          onTap: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        )
      ],
    );
  }
}
