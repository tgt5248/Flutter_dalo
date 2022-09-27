import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart'; //local 설정
import 'dart:collection';

import 'package:dalo/db/db_helper.dart';
import 'package:dalo/db/db_model.dart';

class Calendar extends StatefulWidget {
  const Calendar({Key? key}) : super(key: key);
  @override
  _CalendarState createState() => _CalendarState();
}

class Event {
  String date;
  String time;
  String loc;
  Event(this.date, this.time, this.loc);
  @override
  String toString() => ' $date $time $loc';
}

class _CalendarState extends State<Calendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  Map<DateTime, dynamic> _eventsList = {};
  late Future<Map<DateTime, dynamic>> _future;

  Future<Map<DateTime, dynamic>> getCalenderContents() async {
    _eventsList.addAll(await DBHeler().getAll());
    return _eventsList;
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _future = getCalenderContents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('DaLo - TableCalendar'),
        ),
        body: SingleChildScrollView(
            child: FutureBuilder(
                future: _future,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  final _events = LinkedHashMap<DateTime, dynamic>(
                    equals: isSameDay,
                  )..addAll(_eventsList);

                  List<dynamic> _getEventForDay(DateTime day) {
                    return _events[day] ?? [];
                  }

                  // 당일 이벤트가 안됨 수정해야됨
                  List _selectedEvents = _events[_selectedDay] ?? [];

                  return Column(
                    children: [
                      TableCalendar(
                        locale: 'ko-KR',
                        firstDay: DateTime.utc(2022, 09, 01), //처음 보여줄 날짜
                        lastDay: DateTime.utc(2030, 12, 31), //맨 마지막
                        focusedDay: _focusedDay, // 첫 빌드시 보여지는 날
                        eventLoader: _getEventForDay, //이벤트 마커 표시

                        //날짜 선택하기
                        selectedDayPredicate: (day) {
                          return isSameDay(_selectedDay, day);
                        },

                        onDaySelected: (selectedDay, focusedDay) {
                          if (!isSameDay(_selectedDay, selectedDay)) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                          }
                          List _selectedEvents = _events[_selectedDay] ?? [];

                          print(_selectedEvents);
                        },
                        headerStyle: const HeaderStyle(
                            titleCentered: true,
                            formatButtonVisible: false,
                            titleTextStyle:
                                TextStyle(fontSize: 17.0, color: Colors.black)),
                        calendarStyle: const CalendarStyle(
                          markerDecoration: //이벤트마커
                              BoxDecoration(
                                  color: Colors.blue, shape: BoxShape.circle),
                          markerSize: 5,
                          todayDecoration: //오늘 표시
                              BoxDecoration(
                                  color: Colors.blue, shape: BoxShape.circle),
                          defaultTextStyle: TextStyle(
                            //평일날짜 색상
                            color: Colors.black,
                          ),
                          weekendTextStyle:
                              TextStyle(color: Colors.black), //주말날짜 색상
                        ),
                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(color: Colors.black), //월~금색상
                          weekendStyle: TextStyle(color: Colors.black), //토일 색상
                        ),
                      ),
                      ListView.separated(
                        // scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(8),
                        itemCount: _selectedEvents.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            height: 50,
                            child: Text(_selectedEvents[index]),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(),
                      ),
                      ListView(
                        shrinkWrap: true,
                        children: _selectedEvents
                            .map((event) => Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 0.8),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 4.0),
                                  child: ListTile(
                                    title: Text(event.toString()),
                                  ),
                                ))
                            .toList(),
                      )
                    ],
                  );
                })));
  }
}
