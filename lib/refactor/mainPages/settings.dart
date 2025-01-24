import 'package:flutter/material.dart';
import 'package:flutter_application_1_shift_manager/refactor/screens/main_screen.dart';
import 'package:flutter_application_1_shift_manager/refactor/settingPages/withdraw.dart';
import 'package:provider/provider.dart';
import '../dialogs/dialog.dart';
import '../settingPages/search.dart';
import '../settingPages/edit_user_info.dart';
import '../settingPages/hourly_wage.dart';
// import '../settingPages/notification.dart';
// import '../settingPages/announce.dart';

/// 設定ページ（メイン画面インデックス２）
/// ユーザー情報編集やグループへの参加を行うためページへアクセスするためのメインページ
/// ログアウトもこのページから行う
/* 
機能：
ユーザー情報編集画面への遷移、グループの参加・退会画面への遷移、
時給設定画面への遷移、ログアウトのダイアログの起動
今後追加したい機能：
通知設定、運営からのお知らせページ
*/

class Setting extends StatelessWidget {
  const Setting({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "マイページ",
          style: TextStyle(fontSize: 15),
        ),
        backgroundColor: const Color.fromARGB(255, 228, 228, 228),
      ),
      body: Consumer<DataProvider>(builder: (context, dataProvider, child) {
        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: Color(0xFF2D7A5D),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          width: double.infinity,
                          child: Text(dataProvider.username,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20))),
                      Container(
                          width: double.infinity,
                          child: Text(dataProvider.userEmail,style: TextStyle(color: Colors.white))),
                    ],
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.only(left: 15),
                height: 40,
                alignment: Alignment.centerLeft,
                color: const Color.fromARGB(255, 228, 228, 228),
                child: const Row(
                  children: [
                    Icon(Icons.settings),
                    Padding(padding: EdgeInsets.only(right: 10)),
                    Text("設定"),
                  ],
                ),
              ),
              EditUser(
                userEmail: dataProvider.userEmail,
                birthday: dataProvider.birthday,
                username: dataProvider.username,
              ),

              ///Edtinotification(),
              Container(
                padding: const EdgeInsets.only(left: 15),
                height: 40,
                alignment: Alignment.centerLeft,
                color: const Color.fromARGB(255, 228, 228, 228),
                child: const Row(
                  children: [
                    Icon(Icons.groups),
                    Padding(padding: EdgeInsets.only(right: 10)),
                    Text("グループ"),
                  ],
                ),
              ),
              EditHourlyWage(
                  hourlyWage: dataProvider.hourlyWage,
                  groupName: dataProvider.groupName,
                  groupId: dataProvider.groupId,
                  groupNameMap: dataProvider.groupNameMap),
              const EntryGroup(),
              WithdrawGroup(
                groupName: dataProvider.groupName,
                groupId: dataProvider.groupId,
                groupNameMap: dataProvider.groupNameMap,
              ),
              Container(
                padding: const EdgeInsets.only(left: 15),
                height: 40,
                alignment: Alignment.centerLeft,
                color: const Color.fromARGB(255, 228, 228, 228),
                child: const Row(
                  children: [
                    Icon(Icons.more_horiz),
                    Padding(padding: EdgeInsets.only(right: 10)),
                    Text("その他"),
                  ],
                ),
              ),

              const LogoutButton(),
            ],
          ),
        );
      }),
    );
  }
}

class EntryGroup extends StatelessWidget {
  const EntryGroup({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 1),
      width: double.infinity,
      height: 70,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SearchGroup()),
          );
        },
        style: ElevatedButton.styleFrom(
            alignment: Alignment.centerLeft,
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(0))),
        child: const Text("グループに参加する"),
      ),
    );
  }
}

// ignore: must_be_immutable
class WithdrawGroup extends StatelessWidget {
  WithdrawGroup({
    super.key,
    required this.groupName,
    required this.groupId,
    required this.groupNameMap,
  });
  List groupName = [];
  List groupId = [];
  Map<String, dynamic> groupNameMap = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 1),
      width: double.infinity,
      height: 70,
      child: ElevatedButton(
        onPressed: () async {
          Navigator.push(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(
                builder: (context) => Withdraw(
                      groupName: groupName,
                      groupId: groupId,
                      groupNameMap: groupNameMap,
                    )),
          );
        },
        style: ElevatedButton.styleFrom(
            alignment: Alignment.centerLeft,
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(0))),
        child: const Text("グループを退会する"),
      ),
    );
  }
}

// ignore: must_be_immutable
class EditHourlyWage extends StatelessWidget {
  EditHourlyWage({
    super.key,
    required this.hourlyWage,
    required this.groupName,
    required this.groupId,
    required this.groupNameMap,
  });
  Map<String, dynamic> hourlyWage = {};
  List groupName = [];
  List groupId = [];
  Map<String, dynamic> groupNameMap = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 1),
      width: double.infinity,
      height: 70,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HourlyWage(
                        hourlyWage: hourlyWage,
                        groupName: groupName,
                        groupId: groupId,
                        groupNameMap: groupNameMap,
                      )));
        },
        style: ElevatedButton.styleFrom(
            alignment: Alignment.centerLeft,
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(0))),
        child: const Text("時給設定 / グループ名変更"),
      ),
    );
  }
}

// ignore: must_be_immutable
class EditUser extends StatelessWidget {
  EditUser(
      {super.key,
      required this.userEmail,
      required this.birthday,
      required this.username});
  String userEmail = "";
  DateTime birthday;
  String username = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 1),
      width: double.infinity,
      height: 70,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EditUserInfo(
                        emailaddress: userEmail,
                        birthday: birthday,
                        username: username,
                      )));
        },
        style: ElevatedButton.styleFrom(
            alignment: Alignment.centerLeft,
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(0))),
        child: const Text("ユーザ情報編集"),
      ),
    );
  }
}

class LogoutButton extends StatelessWidget {
  const LogoutButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 0),
      width: double.infinity,
      height: 70,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          alignment: Alignment.centerLeft,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        ),
        onPressed: () async {
          showDialog<void>(
              context: context,
              builder: (_) {
                return LogoutDialog();
              });
        },
        child: const Text(
          "ログアウト",
        ),
      ),
    );
  }
}
