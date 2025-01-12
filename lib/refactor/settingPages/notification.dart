import 'package:flutter/material.dart';
import '../screens/main_screen.dart';
import 'package:provider/provider.dart';

/// 通知設定をするためのページ
/// 今後、グループごとにメッセージを受け取れる様にしていく予定
/// 製作中

class NotificationSetting extends StatefulWidget {
  const NotificationSetting({super.key});

  @override
  State<NotificationSetting> createState() => _NotificationSetting();
}

class _NotificationSetting extends State<NotificationSetting> {
  var userId="";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      body: const SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(8.0),
          ),
        ),
      ),
    );
  }
  // ignore: non_constant_identifier_names
}
