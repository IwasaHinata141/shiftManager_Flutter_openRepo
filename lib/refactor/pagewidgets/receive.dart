import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1_shift_manager/refactor/actions/request_action.dart';
import 'package:flutter_application_1_shift_manager/refactor/screens/main_screen.dart';
import 'package:flutter_application_1_shift_manager/refactor/settingPages/hourly_wage.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../actions/getdata_action.dart';

class ReceivePage extends StatefulWidget {
  @override
  State<ReceivePage> createState() => _ReceivePage();
}

class _ReceivePage extends State<ReceivePage> {
  List<String> _selectedEvents = [];
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();
  DateTime _currentDay = DateTime.now();
  Map<String, dynamic> salaryInfo = {};
  Map<String, dynamic> summarySalary = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "ホーム",
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          IconButton(
              onPressed: () => {context.read<DataProvider>().fetchData()},
              icon: const Icon(Icons.restart_alt)),
        ],
        backgroundColor: Color.fromARGB(255, 228, 228, 228),
      ),
      body: Consumer<DataProvider>(builder: (context, dataProvider, child) {
        return SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(5),
                child: TableCalendar<dynamic>(
                    locale: "ja_JP",
                    firstDay: DateTime.utc(2010, 1, 1),
                    lastDay: DateTime.utc(2030, 1, 1),
                    focusedDay: _focusedDay,
                    currentDay: _currentDay,
                    rowHeight: 48,
                    daysOfWeekHeight: 30,
                    headerStyle: const HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                      leftChevronVisible: true,
                      rightChevronVisible: true,
                    ),
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        final children = <Widget>[];
                        if (events.isNotEmpty) {
                          children.add(
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.amber, // イベントの色を使用
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedEvents = dataProvider.shiftdata[
                                DateFormat('yyyy/MM/dd').format(focusedDay)] ??
                            [];
                        _focusedDay = selectedDay;
                        _currentDay = selectedDay;
                      });
                    },
                    eventLoader: (DateTime dateTime) {
                      return dataProvider.shiftdata[DateFormat('yyyy/MM/dd')
                              .format(dateTime)
                              .toString()] ??
                          [];
                    },
                    onPageChanged: (focusedDay) async {
                      _selectedEvents = dataProvider.shiftdata[
                              DateFormat('yyyy/MM/dd').format(focusedDay)] ??
                          [];
                      var reloadedData = await calculateSalaryReload(
                          focusedDay,
                          dataProvider.shiftdata,
                          dataProvider.hourlyWage,
                          dataProvider.groupName);
                      print("reloadedData:${reloadedData}");
                      setState(() {
                        _focusedDay = focusedDay;
                        salaryInfo = reloadedData[0];
                        summarySalary["summarySalary"] = reloadedData[1];
                      });
                    }),
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 54, 146, 57),
                ),
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 10),
                child: Text("${_focusedDay.month} 月 ${_focusedDay.day} 日",
                    style: TextStyle(fontSize: 13, color: Colors.white)),
              ),
              Container(
                height: _selectedEvents.length == 0
                    ? 0
                    : 60 * _selectedEvents.length.toDouble(),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _selectedEvents.length,
                  itemBuilder: (context, index) {
                    final event = _selectedEvents[index];
                    return Card(
                      child: ListTile(
                        title: Text("  ${event}"),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Divider(
                  color: Colors.grey,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: calculateSalaryBox(
                  hourlyWage: dataProvider.hourlyWage,
                  focusedDay: _focusedDay,
                  salaryInfo:
                      salaryInfo["salaryInfo"] ?? dataProvider.salaryInfo,
                  groupCount: dataProvider.groupCount,
                  groupName: dataProvider.groupName,
                  summarySalary: summarySalary["summarySalary"] ??
                      dataProvider.summarySalary,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class calculateSalaryBox extends StatelessWidget {
  calculateSalaryBox(
      {super.key,
      required this.hourlyWage,
      required this.focusedDay,
      required this.salaryInfo,
      required this.groupCount,
      required this.groupName,
      required this.summarySalary});
  var hourlyWage;
  var salaryInfo;
  var focusedDay;
  int groupCount;
  var groupName;
  var summarySalary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: groupName.isEmpty ? 68:groupName[0] == "no data"? 68:100 * groupCount.toDouble() + 68,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              color: Color.fromARGB(255, 54, 146, 57),
            ),
            child: Text(
              "ー 見込給与(${focusedDay.year}年${focusedDay.month}月) ー",
              style: TextStyle(fontSize: 17, color: Colors.white),
            ),
          ),
          ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: groupCount,
              itemBuilder: (context, Index) {
                if (groupName[Index] != "no data") {
                  return Container(
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Spacer(),
                            Text(groupName[Index]),
                            Spacer(),
                            Text(
                                "出勤：${salaryInfo[groupName[Index]]?["attendcount"] ?? "0"}",
                                style: TextStyle(
                                    fontSize: 15, color: Colors.black)),
                            Spacer(),
                          ],
                        ),
                        Text(
                            "勤務時間${salaryInfo[groupName[Index]]?["totaldiffhour"] ?? "0"}時間 × 時給${hourlyWage["${groupName[Index]}"]}円",
                            style:
                                TextStyle(fontSize: 15, color: Colors.black)),
                        Container(
                            alignment: Alignment.bottomRight,
                            padding:
                                EdgeInsets.only(top: 5, right: 40, bottom: 5),
                            child: Text(
                                "= ${salaryInfo[groupName[Index]]?["totalsalary"] ?? "0"}円",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.black))),
                      ],
                    ),
                  );
                }
              }),
          Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
                color: Colors.green[100],
              ),
              height: 40,
              alignment: Alignment.bottomCenter,
              padding: EdgeInsets.only(top: 5, bottom: 5),
              child: Text("合計 ${summarySalary} 円",
                  style: TextStyle(fontSize: 20, color: Colors.black))),
        ],
      ),
    );
  }
}
