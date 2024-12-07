import 'package:intl/intl.dart';

List calsulatePredictSalary( startTimeList, endTimeList,hourlyWage) {
  
  Map<String,dynamic> timeList = {};
  Map<String,dynamic> salaryList ={};
  int totalWorkTime = 0;
  final numformatter = NumberFormat("#,###");
 
  DateFormat formatter = DateFormat("HH:mm");
  for (var i = 0; i < startTimeList.length; i++) {
    if (startTimeList[i] != "-" && endTimeList[i] != "-") {
      final startTime = formatter.parse("${startTimeList[i]}");
      final endTime = formatter.parse("${endTimeList[i]}");
      final diffminute = endTime.difference(startTime).inMinutes;
      totalWorkTime = totalWorkTime + diffminute;
      final diffhour = (diffminute / 60).toStringAsFixed(2);
      final salary = numformatter.format((diffminute / 60 )*hourlyWage);
      timeList["${i}"] = diffhour;
      salaryList["${i}"] = salary;
    }else{
      timeList["${i}"] = "-";
      salaryList["${i}"] = "0";
    }
  }
  
  final totalsalary =numformatter.format((totalWorkTime / 60 )*hourlyWage);
  final totalWorkTimeAsHour = (totalWorkTime / 60).toStringAsFixed(2);
  return [totalWorkTimeAsHour,totalsalary,timeList,salaryList];
}
