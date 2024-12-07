import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import '../login_items.dart/login.dart';
import 'package:flutter/material.dart';
import '../actions/getdata_action.dart';


class LogoutDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      content: Text('ログアウトしてよろしいですか'),
      actions: <Widget>[
        CupertinoDialogAction(
          child: Text('キャンセル', style: TextStyle(color: Colors.blueAccent)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        CupertinoDialogAction(
          child: Text(
            'ログアウト',
            style: TextStyle(color: Colors.redAccent),
          ),
          onPressed: () async {
            try {
              final FirebaseAuth auth = FirebaseAuth.instance;
              await auth.signOut();
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
  });
  List<String> startTimeList;
  List<String> endTimeList;
  List<String> duration = [];
  bool responce = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text('シフトを提出しますか'),
      content: Text("※提出したシフトは取り消しできません"),
      actions: <Widget>[
        CupertinoDialogAction(
          child: Text('キャンセル', style: TextStyle(color: Colors.blueAccent)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        CupertinoDialogAction(
          child: Text('提出', style: TextStyle(color: Colors.blueAccent),
          ),
          onPressed: () async {
            await submitMyshift(startTimeList, endTimeList, duration);
            Navigator.pop(context);
          },
        )
      ],
    );
  }
}
