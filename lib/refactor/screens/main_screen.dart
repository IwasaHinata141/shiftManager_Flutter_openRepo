import 'package:flutter/material.dart';
import 'package:flutter_application_1_shift_manager/refactor/pagewidgets/submit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../pagewidgets/receive.dart';
import '../pagewidgets/settings.dart';
import '../actions/getdata_action.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// メイン画面を切り換えるための土台となるウィジェット
/// 画面の切換にはbottomNavigationBarを使用
/// ファイルない下部にProviderを配置しているが、移動を考えている
/*
機能：
bottomNavigationBarによる画面の切換
*/

// ignore: must_be_immutable
class MyHomePage extends StatefulWidget {
  MyHomePage({
    super.key,
    required this.count
  });
  // bottomNavigationBarのインデックス
  int count = 0;

  

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void initState() {
    super.initState();
    // データの初期取得
    Provider.of<DataProvider>(context, listen: false).fetchData();
    // データの取得を0.5秒待つ
    Future.delayed(Duration(milliseconds: 500));
  }

   // bottomNavigationBarのページのリスト
   late final _pageWidgets = [
            // ホーム画面
            ReceivePage(),
            // シフト提出画面
            SubmitPage(),    
            // ユーザー設定画面            
            Setting()
          ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bottomNavigationBarで指定された画面の表示
      body:_pageWidgets.elementAt(widget.count),

      bottomNavigationBar: BottomNavigationBar(
        // 選択中のアイテムindex
        currentIndex: widget.count,
        // タップ時のハンドラ
        onTap: (selectedIndex) => setState(() {
          // インデックスを更新する
          widget.count = selectedIndex;
        }),
        // bottomNavigationBarに表示するコンテンツのリスト
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'シフト提出'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'マイページ'),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}


/// Firestoreからユーザーの情報を取得し利用する為のProveider
/// 
/*
機能(取得する情報)：
シフトデータ、
*/

class DataProvider extends ChangeNotifier {
  
  // データを格納する変数
  Map<String, List<String>> shiftdata = {};
  List<String> duration = [];
  List<String> startTimeList = [];
  List<String> endTimeList = [];
  bool status=true;
  String userEmail = "";
  List groupId = [];
  Map<String, dynamic> salaryInfo = {};
  List timeList = [];
  List salaryList = [];
  String totalWorkTime="";
  DateTime birthday=DateTime.now();
  String username ="";
  Map<String, dynamic> hourlyWage ={};
  List groupName=[];
  int groupCount=0;
  String summarySalary = "";


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
    groupCount = dataList[11];
    summarySalary = dataList[12];
   
    
    userEmail = auth.currentUser!.email.toString();

    notifyListeners(); // 状態が変更されたことを通知
  }
}