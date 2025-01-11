import 'package:intl/intl.dart';

/// メイン画面でカレンダーを動かしたときに次の月のシフト情報を取得する関数
/// 
/// focusedDay:カレンダーで選択中の日付（カレンダーページをめくると変化する）
/// shiftData:確定しているシフトデータのリスト
/// hourlyWage:時給データのリスト
/// groupName:グループ名のリスト
/// 
Future<List<dynamic>> calculateSalaryReload(
    focusedDay, shiftdata, hourlyWage, groupName) async {
  // データ型変換のフォーマット指定
  DateFormat formatter = DateFormat('yyyy/MM/dd HH:mm');
  // カレンダーページ変更後の月初めの日付
  final startDay =
      formatter.format(DateTime(focusedDay.year, focusedDay.month, 1));
  // カレンダーページ変更後の月末の日付
  final endDay = formatter.format(
      DateTime(focusedDay.year, focusedDay.month + 1, 1)
          .subtract(const Duration(days: 1)));
  // string型からDateTime型への変換
  final firstDay = formatter.parse(startDay);
  final finalDay = formatter.parse(endDay);
  // カレンダーページ変更後の当月の給与合計
  String summarySalaryText = "";
  // カレンダーページ変更後のグループ別の当月の給与合計
  Map<String, dynamic> calculatedDataMap = {};
  // 当月給与合計の一時保存変数
  int summarySalary = 0;
  // calculatedDataMapを戻り値として送る為の変数
  Map<String, dynamic> salaryInfo = {};

  // 所属グループ数に応じた繰り返し処理
  for (int i = 0; i < groupName.length; i++) {
    // 給与合計
    int totalsalary = 0;
    // 労働時間合計
    double totaldiffhour = 0;
    // 勤務日数
    var attendcount = 0;
    // 給与合計、労働時間、勤務日数をまとめる変数
    Map<String, dynamic> result = {};
    // グループごとに結果をまとめる変数
    Map<String, dynamic> responce = {};

    // 当月の日数分の繰り返し処理
    for (DateTime date = firstDay;
        date.isBefore(finalDay.add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))) {
      // (2025-01-01 00:00:00.000) → (2025/01/01)
      final dateString = date.toString().split(" ")[0].replaceAll("-", "/");
      // シフトデータを取り出してリストに追加
      final dataField = shiftdata[dateString];
      // 該当する日付のシフトデータが存在する場合だけ処理を行う
      if (dataField != null) {
        // その日付のシフトデータの数に応じた繰り返し処理
        for (int j = 0; j < dataField.length; j++) {
          // シフトデータからグループ名を取り出す
          final listItem = dataField[j].split("  ");
          // グループ名とシフトデータから取り出した文字列が等しいい場合だけ処理を行う
          if (groupName[i] == listItem[0]) {
            // 出勤日数を1つ増やす
            attendcount++;
            // listItem[1]は12:00 - 18:00のような形をしている
            final timeItem = listItem[1].split(" - ");
            // 開始時刻
            final start = timeItem[0];
            // 終了時刻
            final end = timeItem[1];
            // 労働時間の計算
            // 例：2025/01/01 12:00
            final dayListItemStart = "$dateString $start";
            // 例：2025/01/01 18:00
            final dayListItemEnd = "$dateString $end";
            // DateTimeに変換
            DateTime starttime = formatter.parse(dayListItemStart);
            DateTime endtime = formatter.parse(dayListItemEnd);
            // 二つのDateTimeの差分から労働時間を計算
            final diffminute = endtime.difference(starttime).inMinutes;
            // 分単位で計算されるため時間単位に直す
            final diffhour = diffminute / 60;
             // 労働時間と時給から給与を計算
            final salary = (diffhour * hourlyWage["${groupName[i]}"]).toInt();
            // 一日の給与を当月の給与に合計する
            totalsalary = totalsalary + salary;
            // 一日の労働時間を当月の労働時間に合計する
            totaldiffhour = totaldiffhour + diffhour;
          }
        }
      }
    }
    // グループごとの給与を全体の給与に合計
    summarySalary = summarySalary + totalsalary;
    // 給与金額にカンマを付ける為のフォーマット
    final numformatter = NumberFormat("#,###");
    // 給与、出勤日数、労働時間を格納
    result["totalsalary"] = numformatter.format(totalsalary);
    result["attendcount"] = attendcount;
    result["totaldiffhour"] = totaldiffhour.toStringAsFixed(2);
    // グループ名をキーとして結果を格納
    responce["${groupName[i]}"] = result;
    // 全てのグループの結果をまとめるために変数に格納
    calculatedDataMap.addAll(responce);
    
    // 給与が1000円以上の場合はカンマを打つ
    if(summarySalary >= 1000){
    summarySalaryText = numformatter.format(summarySalary);
    }
  }
  // 結果を戻り値の変数に格納
  salaryInfo["salaryInfo"] = calculatedDataMap;
  return [salaryInfo, summarySalaryText];
}
