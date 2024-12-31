import 'package:flutter/material.dart';
import 'package:flutter_application_1_shift_manager/refactor/screens/main_screen.dart';
import 'package:flutter_application_1_shift_manager/refactor/settingPages/withdraw.dart';
import 'package:provider/provider.dart';
import '../dialogs/dialog.dart';
import '../settingPages/search.dart';
import '../settingPages/announce.dart';
import '../settingPages/edit_user_info.dart';
import '../settingPages/hourly_wage.dart';
import '../settingPages/notification.dart';



class Setting extends StatelessWidget {
  Setting({super.key});
  
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
                      padding: EdgeInsets.only(left: 10),
                      child: CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      child: Icon(Icons.person,size: 65,color: Colors.grey,),
                        radius: 40,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(child: Text(dataProvider.username),),
                          Container(
                            child: Text(dataProvider.userEmail),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: EdgeInsets.only(left: 15),
                height: 40,
                alignment: Alignment.centerLeft,
                color: Color.fromARGB(255, 228, 228, 228),
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    Padding(padding: EdgeInsets.only(right: 10)),
                    Text("設定"),
                  ],
                ),
              ),
              editUserInfo(
                userEmail: dataProvider.userEmail,
                birthday: dataProvider.birthday,
                username: dataProvider.username,
              ),
              editHourlyWage(
                hourlyWage: dataProvider.hourlyWage,
                groupName: dataProvider.groupName,
              ),

              ///edtinotification(),
              Container(
                padding: EdgeInsets.only(left: 15),
                height: 40,
                alignment: Alignment.centerLeft,
                color: Color.fromARGB(255, 228, 228, 228),
                child: Row(
                  children: [
                    Icon(Icons.groups),
                    Padding(padding: EdgeInsets.only(right: 10)),
                    Text("グループ"),
                  ],
                ),
              ),
              entryGroup(),
              withdrawGroup(groupName: dataProvider.groupName, groupId: dataProvider.groupId,),
              Container(
                padding: EdgeInsets.only(left: 15),
                height: 40,
                alignment: Alignment.centerLeft,
                color: Color.fromARGB(255, 228, 228, 228),
                child: Row(
                  children: [
                    Icon(Icons.more_horiz),
                    Padding(padding: EdgeInsets.only(right: 10)),
                    Text("その他"),
                  ],
                ),
              ),

              logoutButton(),
            ],
          ),
        );
      }),
    );
  }
}

class entryGroup extends StatelessWidget {
  const entryGroup({
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
        child: Text("グループに参加する"),
        style: ElevatedButton.styleFrom(
            alignment: Alignment.centerLeft,
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(0))),
      ),
    );
  }
}

class withdrawGroup extends StatelessWidget {
  withdrawGroup({
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
            context,
            MaterialPageRoute(builder: (context) => withdraw(groupName: groupName, groupId: groupId,)),
          );
          
        },
        child: Text("グループを退会する"),
        style: ElevatedButton.styleFrom(
            alignment: Alignment.centerLeft,
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(0))),
      ),
    );
  }
}

class edtinotification extends StatelessWidget {
  const edtinotification({
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

class announcement extends StatelessWidget {
  const announcement({
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

class editHourlyWage extends StatelessWidget {
  editHourlyWage({
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
        child: Text("時給設定"),
        style: ElevatedButton.styleFrom(
            alignment: Alignment.centerLeft,
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(0))),
      ),
    );
  }
}

class editUserInfo extends StatelessWidget {
  editUserInfo(
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
        child: const Text("ユーザ情報編集"),
        style: ElevatedButton.styleFrom(
            alignment: Alignment.centerLeft,
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(0))),
      ),
    );
  }
}

class logoutButton extends StatelessWidget {
  const logoutButton({
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
