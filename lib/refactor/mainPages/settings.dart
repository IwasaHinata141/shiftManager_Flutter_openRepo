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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Container(
                      height: 70,
                      padding: const EdgeInsets.only(left: 10),
                      child: CircleAvatar(
                      backgroundColor: Colors.grey[200],
                        radius: 40,
                      child: const Icon(Icons.person,size: 65,color: Colors.grey,),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(dataProvider.username),
                          Text(dataProvider.userEmail),
                        ],
                      ),
                    ),
                  ],
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
              EditHourlyWage(
                hourlyWage: dataProvider.hourlyWage,
                groupName: dataProvider.groupName,
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
              const EntryGroup(),
              WithdrawGroup(groupName: dataProvider.groupName, groupId: dataProvider.groupId,),
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
          Navigator.pushReplacement(
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
  });
  List groupName =[];
  List groupId = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 1),
      width: double.infinity,
      height: 70,
      child: ElevatedButton(
        onPressed: () async{
          await context.read<DataProvider>().fetchData();
          
          Navigator.pushReplacement(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(builder: (context) => Withdraw(groupName: groupName, groupId: groupId,)),
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
/*
class Edtinotification extends StatelessWidget {
  const Edtinotification({
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
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => NotificationSetting()));
        },
        child: Text("通知設定"),
        style: ElevatedButton.styleFrom(
            alignment: Alignment.centerLeft,
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(0))),
      ),
    );
  }
}


class Announcement extends StatelessWidget {
  const Announcement({
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
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Announce()));
        },
        child: Text("運営からのお知らせ"),
        style: ElevatedButton.styleFrom(
            alignment: Alignment.centerLeft,
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(0))),
      ),
    );
  }
}
*/
// ignore: must_be_immutable
class EditHourlyWage extends StatelessWidget {
  EditHourlyWage({
    super.key,
    required this.hourlyWage,
    required this.groupName,
  });
  Map<String,dynamic> hourlyWage = {};
  List groupName = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 1),
      width: double.infinity,
      height: 70,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => HourlyWage(
                        hourlyWage: hourlyWage,
                        groupName: groupName,
                      )));
        },
        style: ElevatedButton.styleFrom(
            alignment: Alignment.centerLeft,
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(0))),
        child: const Text("時給設定"),
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
          Navigator.pushReplacement(
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
