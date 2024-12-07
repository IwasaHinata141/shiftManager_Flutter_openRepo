import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1_shift_manager/refactor/actions/request_action.dart';
import 'package:flutter_application_1_shift_manager/refactor/screens/main_screen.dart';
import 'package:flutter_application_1_shift_manager/refactor/settingPages/hourly_wage.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class ReceivePage extends StatefulWidget {
  @override
  State<ReceivePage> createState() => _ReceivePage();
}

class _ReceivePage extends State<ReceivePage> {
  List<String> _selectedEvents = [];
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();
  DateTime _currentDay = DateTime.now();

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
              Divider(),
              Padding(
                padding: EdgeInsets.all(5),
                child: TableCalendar<dynamic>(
                  locale: "ja_JP",
                  firstDay: DateTime.utc(2010, 1, 1),
                  lastDay: DateTime.utc(2030, 1, 1),
                  focusedDay: _focusedDay,
                  currentDay: _currentDay,
                  rowHeight: 50,
                  daysOfWeekHeight: 32,
                  headerStyle: const HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                    leftChevronVisible: true,
                    rightChevronVisible: true,
                  ),
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedEvents = dataProvider.shiftdata[
                              DateFormat('yyyy/MM/dd').format(selectedDay)] ??
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
                ),
              ),
              Divider(),
              Container(
                height: 80,
                child: ListView.builder(
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
              SizedBox(height: 30,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: calculateSalaryBox(
                  salary: dataProvider.salaryInfo,
                  hourlyWage: dataProvider.hourlyWage,
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
  const calculateSalaryBox(
      {super.key, required this.salary, required this.hourlyWage});
  final salary;
  final hourlyWage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                  color: Color.fromARGB(255, 54, 146, 57),
                ),
                child: Text(
                  "ー 見込給与(12月) ー",
                  style: TextStyle(fontSize: 17, color: Colors.white),
                ),
              ),
              Spacer(),
              Text("出勤日数：${salary["attendcount"]?? "0"}",
                  style: TextStyle(fontSize: 15, color: Colors.black)),
              Spacer(),
              Text("勤務時間${salary["totaldiffhour"] ?? "0"}時間 × 時給${hourlyWage}円",
                  style: TextStyle(fontSize: 15, color: Colors.black)),
              Spacer(),
              Container(
                  alignment: Alignment.bottomRight,
                  padding: EdgeInsets.only(top: 5, right: 40, bottom: 5),
                  child: Text("= ${salary["totalsalary"] ?? "0"}円",
                      style: TextStyle(fontSize: 20, color: Colors.black))),
              Spacer()
            ],
          ),
        ),
      ),
    );
  }
}
