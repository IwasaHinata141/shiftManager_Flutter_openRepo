import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/main_screen.dart';
import 'package:flutter_application_1_shift_manager/refactor/functions/request_func.dart';
import 'package:provider/provider.dart';

class SearchGroup extends StatefulWidget {
  @override
  State<SearchGroup> createState() => _SearchGroup();
}

class _SearchGroup extends State<SearchGroup> {
  String groupId = "";
  String infoText = "";
  String groupname = "";
  String adminname = "";
  String pass = "";
  String infoText2 = "";
  String inputPass = "";

  var userId;

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
                        create: (_) => DataProvider(), child: MyHomePage(count: 2,))));
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
                Text("グループ参加申請"),
                TextField(
                  decoration: InputDecoration(labelText: 'グループID'),
                  onChanged: (String value) {
                    setState(() {
                      groupId = value;
                    });
                  },
                ),
                Text(infoText),
                ElevatedButton(
                  child: Text("検索"),
                  onPressed: () async {
                    try {
                      List<String> groupData =
                          await search(groupId);
                      groupname = groupData[0];
                      adminname = groupData[1];
                      setState(() {
                        infoText = "グループ： ${groupname}\n 管理者： ${adminname}";
                      });
                    } catch (e) {
                      setState(() {
                        infoText = "該当するグループが存在しません";
                      });
                    }
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'pass'),
                  onChanged: (String value) {
                    setState(() {
                      inputPass = value;
                    });
                  },
                ),
                ElevatedButton(
                  child: Text("加入申請"),
                  onPressed: () async {
                    try {
                      var auth = FirebaseAuth.instance;
                      userId = auth.currentUser!.uid.toString();
                      String responce = await request(groupId, userId, inputPass);
                      setState(() {
                        infoText2 = responce;
                      });
                    } catch (e) {
                      setState(() {
                        infoText2 = "${e}";
                      });
                    }
                  },
                ),
                Text(infoText2),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // ignore: non_constant_identifier_names
}
