import 'package:flutter/material.dart';
import 'package:flutter_application_1_shift_manager/refactor/actions/request_action.dart';
import 'package:flutter_application_1_shift_manager/refactor/pagewidgets/submit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../pagewidgets/receive.dart';
import '../pagewidgets/settings.dart';
import '../actions/getdata_action.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({
    super.key,
    required this.count
  });
  int count = 0;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void initState() {
    super.initState();
    // データの初期取得
    Provider.of<DataProvider>(context, listen: false).fetchData();
  }

   late final _pageWidgets = [
            ReceivePage(),
            SubmitPage(),                
            Setting()
          ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:_pageWidgets.elementAt(widget.count),

      bottomNavigationBar: BottomNavigationBar(
        // 選択中のアイテムindex
        currentIndex: widget.count,
        // タップ時のハンドラ
        onTap: (selectedIndex) => setState(() {
          widget.count = selectedIndex;
        }),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'シフト提出'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'マイページ'),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}


class DataProvider extends ChangeNotifier {
  
  // データを格納する変数
  Map<String, List<String>> shiftdata = {};
  List<String> duration = [];
  List<String> startTimeList = [];
  List<String> endTimeList = [];
  bool status=true;
  String userEmail = "";
  String groupId = "";
  Map<String, dynamic> salaryInfo = {};
  List timeList = [];
  List salaryList = [];
  String totalWorkTime="";
  DateTime birthday=DateTime.now();
  String username ="";
  int hourlyWage =0;
  String groupName="";

  // データを取得する関数 (実際の取得処理をここに記述)
  Future<void> fetchData() async {
    final db = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;

    var dataList = await getData(db);
    shiftdata = dataList[0];
    duration = dataList[1];
    startTimeList = dataList[2];
    endTimeList = dataList[3];
    status = dataList[4];
    salaryInfo = dataList[5];
    groupId = dataList[6];
    birthday = dataList[7];
    username = dataList[8];
    hourlyWage = dataList[9]; 
    groupName = dataList[10];
    
    userEmail = auth.currentUser!.email.toString();
    
    notifyListeners(); // 状態が変更されたことを通知
  }
}