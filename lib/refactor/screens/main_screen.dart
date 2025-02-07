import 'package:flutter/material.dart';
import 'package:flutter_application_1_shift_manager/refactor/mainPages/submit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../mainPages/receive.dart';
import '../mainPages/settings.dart';
import '../functions/get_data_func.dart';
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
  MyHomePage({super.key, required this.count});
  // bottomNavigationBarのインデックス
  int count = 0;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    // データの初期取得
    Provider.of<DataProvider>(context, listen: false).fetchData();
    // データの取得を数秒待つ
    Future.delayed(const Duration(milliseconds: 500));
  }

  // bottomNavigationBarのページのリスト
  late final _pageWidgets = [
    // ホーム画面
    const ReceivePage(),
    // シフト提出画面
    const SubmitPage(),
    // ユーザー設定画面
    const Setting()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bottomNavigationBarで指定された画面の表示
      body: _pageWidgets.elementAt(widget.count),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          // ナビゲーションバーの上部に線を引く
          border: Border(
            top: BorderSide(
              width: 0.3,
              color: Colors.black,
            ),
          ),
        ),
        child: BottomNavigationBar(
          // アイコンの色を指定
          selectedIconTheme: const IconThemeData(color: Color(0xFF36AB13)),
          unselectedIconTheme: const IconThemeData(color: Color(0xFF9DA39B)),
          // ラベルの色を指定
          selectedItemColor: const Color(0xFF36AB13),
          unselectedItemColor: const Color(0xFF9DA39B),
          // 背景色を指定
          backgroundColor: const Color(0xFFEDF0ED),
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
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month), label: 'シフト提出'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'マイページ'),
          ],
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}

/// Firestoreからユーザーの情報を取得し利用する為のProvider
/*
機能：
事前情報の取得、情報を他widgetで呼び出せるようにすること、
リロードで呼び出されたときには情報を再取得する
*/

class DataProvider extends ChangeNotifier {
  /// データを格納する変数の定義
  // シフトデータ（確定済み）
  Map<String, List<String>> shiftdata = {};
  // 募集中シフトの期間
  List<String> duration = [];
  // durationの数に対応したリスト（シフト提出画面でシフトの開始時間のリストを格納する）
  List<String> startTimeList = [];
  // durationの数に対応したリスト（シフト提出画面でシフトの終了時間のリストを格納する）
  List<String> endTimeList = [];
  // シフトが募集中か停止中かの真偽値
  bool status = true;
  // ユーザーのメールアドレス
  String userEmail = "";
  // グループID
  List<String> groupId = [];
  // 当月の賃金の情報(予測給与、出勤日、労働時間)
  Map<String, dynamic> salaryInfo = {};
  // 生年月日（初期値では一時的に現在の日付データを格納）
  DateTime birthday = DateTime.now();
  // ユーザー名
  String username = "";
  // 時給データ
  Map<String, dynamic> hourlyWage = {};
  // グループ名のリスト
  List groupName = [];
  // グループを表示する際のインスタンス
  int groupCount = 0;
  // 当月の合計給与
  String summarySalary = "";
  // 加工前シフトデータ（カレンダーページの変更時に使用）
  Map<String, dynamic> rawShift = {};
  // グループ名とグループIDの対応表
  Map<String, dynamic> groupNameMap = {};

  // 取得したデータの格納を行う関数
  Future<void> fetchData() async {
    // Firestoreインスタンス
    final db = FirebaseFirestore.instance;
    // Firebase authインスタンス
    final auth = FirebaseAuth.instance;

    // getDataは実際にデータを取得する関数
    // dataListに戻り値のリストを格納し、dataListから変数に格納する
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
    rawShift = dataList[13];
    groupNameMap = dataList[14];
    userEmail = auth.currentUser!.email.toString();

    // 状態が変更されたことを通知
    notifyListeners();
  }

  // シフトの変更を行う
  setShift(Map<String, List<String>> newShiftData) {
    shiftdata = newShiftData;
    notifyListeners();
  }

  Future<dynamic> setRawShift() async {
    final db = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;
    final userId = auth.currentUser?.uid.toString();
    final shiftData = await getMyShift(userId, db, hourlyWage, groupNameMap);
    rawShift = shiftData[3];
    notifyListeners();
  }
}
