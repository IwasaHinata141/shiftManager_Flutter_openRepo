import 'package:flutter/material.dart';
import 'package:flutter_application_1_shift_manager/refactor/functions/reload_func.dart';
import 'package:flutter_application_1_shift_manager/refactor/screens/main_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

// シフト確認画面（メイン画面インデックス０）
/* 
カレンダーのイベントがシフトに対応している

機能：
シフトデータをカレンダーに反映、
カレンダーの日付を選択時にシフトのカードを表示、
カレンダーの横スクロール（月を変更）時にその月の
シフトデータ・給与・出勤回数・勤務時間を取得、
appbarのボタンをタップ時にProviderを再読み込み、
給与、出勤回数、勤務時間を表示

今後追加したい機能：
・このアプリからのシフトの追加を可能にすること
・既にあるシフトを削除/編集可能にすること
この二つの機能にて編集されたシフトデータはユーザーのFirestoreに書き込む
までにとどめて、グループのFirestoreには書き込まない
*/

class ReceivePage extends StatefulWidget {
  const ReceivePage({super.key});

  @override
  State<ReceivePage> createState() => _ReceivePage();
}

class _ReceivePage extends State<ReceivePage> {
  // 選択中の日付のイベント
  List<String> _selectedEvents = [];
  // 選択したの日付
  DateTime? _selectedDay;
  // 選択されている日付（月変更時に自動でその月に切り替わる）
  DateTime _focusedDay = DateTime.now();
  // 現在の日付
  DateTime _currentDay = DateTime.now();
  // 給与情報、出勤回数、労働時間
  Map<String, dynamic> salaryInfo = {};
  // 合計給与金額
  Map<String, dynamic> summarySalary = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // アップバー（ページ上部）
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "ホーム",
          style: TextStyle(fontSize: 17),
        ),
        // Providerの情報更新用ボタン
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: IconButton(
                onPressed: () => {context.read<DataProvider>().fetchData()},
                icon: const Icon(Icons.restart_alt)),
          ),
        ],
        backgroundColor: const Color(0xFFEDF0ED),
        shape: const Border(
          bottom: BorderSide(
            color: Colors.black,
            width: 0.3,
          ),
        ),
      ),
      // ボディ（ページ中部）
      body: Container(
        color: const Color(0xFFEDF0ED),
        child: Consumer<DataProvider>(builder: (context, dataProvider, child) {
          // スクロール可能にする
          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  // カレンダーウィジェット
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 5),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(15),
                        // 影
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            spreadRadius: 1.0,
                            blurRadius: 10.0,
                            offset: Offset(5, 5),
                          )
                        ]),
                    child: TableCalendar<dynamic>(
                        // 言語指定
                        locale: "ja_JP",
                        // カレンダー範囲指定
                        firstDay: DateTime.utc(2010, 1, 1),
                        lastDay: DateTime.utc(2030, 1, 1),
                        // 選択されている日付
                        focusedDay: _focusedDay,
                        // 現在の日付
                        currentDay: _currentDay,
                        // 行の高さ指定
                        rowHeight: 48,
                        // 曜日部分の高さ指定
                        daysOfWeekHeight: 30,
                        // カレンダーヘッダーの設定
                        headerStyle: const HeaderStyle(
                          titleCentered: true,
                          titleTextStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Color(0xFF266901)),
                          formatButtonVisible: false,
                          leftChevronVisible: true,
                          rightChevronVisible: true,
                        ),
                        calendarStyle: const CalendarStyle(
                            markerDecoration: BoxDecoration(
                                color: Color(0xFF36AB13),
                                shape: BoxShape.circle)),
                        calendarBuilders: CalendarBuilders(
                          // カレンダー上のイベントの表示の設定
                          markerBuilder: (context, date, events) {
                            final children = <Widget>[];
                            if (events.isNotEmpty) {
                              children.add(
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.amber, // イベントの色を使用
                                  ),
                                ),
                              );
                            }
                            return null;
                          },
                        ),
                        selectedDayPredicate: (day) {
                          return isSameDay(_selectedDay, day);
                        },
                        // 日付を選択したときのイベントの更新
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedEvents = dataProvider.shiftdata[
                                    DateFormat('yyyy/MM/dd')
                                        .format(focusedDay)] ??
                                [];
                            _focusedDay = selectedDay;
                            _currentDay = selectedDay;
                          });
                        },
                        // 表示するイベントのリストを設定
                        eventLoader: (DateTime dateTime) {
                          return dataProvider.shiftdata[DateFormat('yyyy/MM/dd')
                                  .format(dateTime)
                                  .toString()] ??
                              [];
                        },

                        /// カレンダーの月を変更したときに起動
                        /// 給与、出勤回数、勤務時間を更新
                        onPageChanged: (focusedDay) async {
                          _selectedEvents = dataProvider.shiftdata[
                                  DateFormat('yyyy/MM/dd')
                                      .format(focusedDay)] ??
                              [];
                          var reloadedData = await calculateSalaryReload(
                            focusedDay,
                            dataProvider.hourlyWage,
                            dataProvider.groupName,
                            dataProvider.groupId,
                            dataProvider.rowShift,
                          );
                          setState(() {
                            _focusedDay = focusedDay;
                            salaryInfo = reloadedData[0];
                            summarySalary["summarySalary"] = reloadedData[1];
                          });
                        }),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(6),
                          height: 80,
                          decoration: const BoxDecoration(boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              spreadRadius: 1.0,
                              blurRadius: 10.0,
                              offset: Offset(5, 5),
                            )
                          ]),
                          child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                backgroundColor: const Color(0xFF67C7A8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.add_circle_outline,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "追加",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  )
                                ],
                              )),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(6),
                          height: 80,
                          decoration: const BoxDecoration(boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              spreadRadius: 1.0,
                              blurRadius: 10.0,
                              offset: Offset(5, 5),
                            )
                          ]),
                          child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                backgroundColor: const Color(0xFF67C7A8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Text(
                                    "編集",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  )
                                ],
                              )),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(6),
                          height: 80,
                          decoration: const BoxDecoration(boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              spreadRadius: 1.0,
                              blurRadius: 10.0,
                              offset: Offset(5, 5),
                            )
                          ]),
                          child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                backgroundColor: const Color(0xFF67C7A8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Text(
                                    "削除",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  )
                                ],
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
                // 選択中の日付をカレンダーの下に表示するcontainer
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF36AB13),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          spreadRadius: 1.0,
                          blurRadius: 10.0,
                          offset: Offset(2, 2),
                        )
                      ],
                    ),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 10),
                    child: Text("${_focusedDay.month} 月 ${_focusedDay.day} 日",
                        style:
                            const TextStyle(fontSize: 13, color: Colors.white)),
                  ),
                ),

                /// 選択した日付のシフトを表示するカードウィジェット
                /// シフトの数に応じてウィジェットの数を変える
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: SizedBox(
                    height: _selectedEvents.isEmpty
                        ? 0
                        : 60 * _selectedEvents.length.toDouble(),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _selectedEvents.length,
                      itemBuilder: (context, index) {
                        final event = _selectedEvents[index];
                        return Card(
                          child: ListTile(
                            title: Text(event),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // 給与金額、出勤回数、勤務時間、合計給与、時給を表示するウィジェット
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CalculateSalaryBox(
                    hourlyWage: dataProvider.hourlyWage,
                    focusedDay: _focusedDay,
                    salaryInfo:
                        salaryInfo["salaryInfo"] ?? dataProvider.salaryInfo,
                    groupCount: dataProvider.groupCount,
                    groupName: dataProvider.groupName,
                    groupId: dataProvider.groupId,
                    summarySalary: summarySalary["summarySalary"] ??
                        dataProvider.summarySalary,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ignore: must_be_immutable
class CalculateSalaryBox extends StatelessWidget {
  CalculateSalaryBox(
      {super.key,
      required this.hourlyWage,
      required this.focusedDay,
      required this.salaryInfo,
      required this.groupCount,
      required this.groupName,
      required this.summarySalary,
      required this.groupId});
  // 時給
  var hourlyWage = {};
  // 給与等の情報
  var salaryInfo = {};
  // 選択されている日付
  var focusedDay = DateTime.now();
  // 所属グループ数
  int groupCount;
  // 所属グループ名
  var groupName = [];
  // 合計給与
  var summarySalary = "";
  // グループID
  var groupId = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      /// 高さは所属しているグループの数によって決まる
      /// 基本の高さが68、グループ一つにつき高さ+100
      height: groupName.isEmpty
          ? 74
          : groupName[0] == "no data"
              ? 74
              : 100 * groupCount.toDouble() + 74,
      // 背景色、輪郭の丸み
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            spreadRadius: 1.0,
            blurRadius: 10.0,
            offset: Offset(5, 5),
          )
        ],
      ),
      child: Column(
        children: [
          // ウィジェットのタイトル部分
          Container(
            width: double.infinity,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 10),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              color: Color(0xFFFFFFFF),
            ),
            child: Text(
              " 見込給与(${focusedDay.year}年${focusedDay.month}月)",
              style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          ),
          // 所属グループの有無によって表示するウィジェット
          ListView.builder(
              // ウィジェットのスクロールを不可にする
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              // 所属グループによってコンテンツ数を決定
              itemCount: groupCount,
              itemBuilder: (context, index) {
                // グループ名が初期値のno dataの場合はウィジェットを表示しない
                if (groupName[index] != "no data") {
                  return Container(
                    height: 100,
                    decoration: const BoxDecoration(color: Color(0xFFFFFFFF)),
                    child: Column(
                      children: [
                        // グループ名、出勤回数の表示
                        Row(
                          children: [
                            const Spacer(),
                            Text(groupName[index]),
                            const Spacer(),
                            Text(
                                "出勤：${salaryInfo[groupId[index]]?["attendcount"] ?? "0"}",
                                style: const TextStyle(
                                    fontSize: 15, color: Colors.black)),
                            const Spacer(),
                          ],
                        ),
                        // 勤務時間、時給の表示
                        Text(
                            "勤務時間${salaryInfo[groupId[index]]?["totaldiffhour"] ?? "0"}時間 × 時給${hourlyWage["${groupId[index]}"]}円",
                            style: const TextStyle(
                                fontSize: 15, color: Colors.black)),
                        // グループの給与を表示
                        Container(
                            alignment: Alignment.bottomRight,
                            padding: const EdgeInsets.only(
                                top: 5, right: 40, bottom: 5),
                            child: Text(
                                "= ${salaryInfo[groupId[index]]?["totalsalary"] ?? "0"}円",
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.black))),
                      ],
                    ),
                  );
                }
                return null;
              }),
          // 所属グループの合計給与を表示
          Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
                color: Colors.green[100],
              ),
              height: 40,
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: Text("合計 $summarySalary 円",
                  style: const TextStyle(fontSize: 20, color: Colors.black))),
        ],
      ),
    );
  }
}
