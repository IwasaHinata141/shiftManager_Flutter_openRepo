import 'package:intl/intl.dart';

/// シフト提出画面で表示する予測給与を表示する為の関数
/// startTimeList:シフト開始時刻のリスト
/// endTimeList:シフト終了時刻のリスト
/// hourlyWage:時給データのリスト
/// 
List calsulatePredictSalary( startTimeList, endTimeList,hourlyWage) {
  // 一日の労働時間を格納するリスト
  Map<String,dynamic> timeList = {};
  // 一日の給与を格納するリスト
  Map<String,dynamic> salaryList ={};
  // 合計労働時間
  int totalWorkTime = 0;
  // 給与金額にカンマを入れる為のフォーマット指定
  final numformatter = NumberFormat("#,###");
  // 労働時間計算のためのフォーマット指定
  DateFormat formatter = DateFormat("HH:mm");
  // 募集シフトの日数分の繰り返し処理
  for (var i = 0; i < startTimeList.length; i++) {
    // 開始時刻と終了時刻が両方とも入力済みの場合だけ計算する
    if (startTimeList[i] != "-" && endTimeList[i] != "-") {
      // 入力された時間の文字列からDateTime型に変換
      final startTime = formatter.parse("${startTimeList[i]}");
      final endTime = formatter.parse("${endTimeList[i]}");
      // 開始時刻と終了時刻の差分から労働時間を計算
      final diffminute = endTime.difference(startTime).inMinutes;
      // 全体の労働時間を算出するために合計
      totalWorkTime = totalWorkTime + diffminute;
      // 労働時間を時間単位に直し、小数点以下を2桁まで表示するように指定
      final diffhour = (diffminute / 60).toStringAsFixed(2);
      // 一日の労働時間と時給から一日の給与を算出
      final salary = numformatter.format((diffminute / 60 )*double.parse(hourlyWage));
      // 成形した一日の労働時間を格納
      timeList["$i"] = diffhour;
      // 一日の給与を格納
      salaryList["$i"] = salary;
    }else{
      // シフトの入力がされなかった場合の処理
      // 一日の労働時間・給与に仮の要素を格納
      timeList["$i"] = "-";
      salaryList["$i"] = "0";
    }
  }
  // 全体の労働時間と時給から全体の給与を算出
  final totalsalary =numformatter.format((totalWorkTime / 60 )*double.parse(hourlyWage));
  // 全体の労働時間を時間単位に直した後、小数点以下を2桁表示するように設定
  final totalWorkTimeAsHour = (totalWorkTime / 60).toStringAsFixed(2);
  return [totalWorkTimeAsHour,totalsalary,timeList,salaryList];
}
