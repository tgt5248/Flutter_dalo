import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart'; //local 설정
import 'dart:collection';

class Calendar extends StatefulWidget {
  const Calendar({Key? key}) : super(key: key);
  @override
  _CalendarState createState() => _CalendarState();
}

class Event {
  String location;
  String time;
  Event(this.location, this.time);
  @override
  String toString() => '$time  $location';
}

//이벤트는 Map 객체로
Map<DateTime, dynamic> eventSource = {
  DateTime.utc(2022, 9, 13): [Event('우리집', '10:00'), Event('학교', '17:00')],
  DateTime.utc(2022, 9, 21): [Event('집', '12:00')],
  DateTime.utc(2022, 9, 22): [Event('집', '17:00')],
  DateTime.utc(2022, 9, 24): [Event('집', '19:00')],
  DateTime.utc(2022, 09, 28): [Event('집', '29:00')]
};
//LinkedHashMap 객체로 변환
final events = LinkedHashMap(
  equals: isSameDay,
)..addAll(eventSource);

class _CalendarState extends State<Calendar> {
  List<Event> _getEventsForDay(DateTime day) {
    return events[day] ?? [];
  }

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  //당일 이벤트도 표시되게 설정 (시간 바꾸는거 꼼수)
  List _selectedEvents = events[DateTime.parse(
      DateFormat('yyyy-MM-dd').format(DateTime.now()) + ' 00:00:00.000Z')];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('DaLo - TableCalendar'),
        ),
        body: Column(children: [
          TableCalendar(
            locale: 'ko-KR',
            firstDay: DateTime.utc(2022, 09, 01), //처음 보여줄 날짜
            lastDay: DateTime.utc(2030, 12, 31), //맨 마지막
            focusedDay: _focusedDay, // 첫 빌드시 보여지는 날
            eventLoader: _getEventsForDay, //이벤트 마커 표시

            //날짜 선택하기
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },

            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _selectedEvents = events[_selectedDay] ?? [];
                });
              }
            },
            // onPageChanged: (focusedDay) {
            //   // No need to call `setState()` here
            //   _focusedDay = focusedDay;
            // },

            headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: TextStyle(fontSize: 17.0, color: Colors.black)),
            calendarStyle: const CalendarStyle(
              markerDecoration: //이벤트마커
                  BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
              markerSize: 5,
              todayDecoration: //오늘 표시
                  BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
              defaultTextStyle: TextStyle(
                //평일날짜 색상
                color: Colors.black,
              ),
              weekendTextStyle: TextStyle(color: Colors.black), //주말날짜 색상
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: Colors.black), //월~금색상
              weekendStyle: TextStyle(color: Colors.black), //토일 색상
            ),
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
        ]));
  }
}
