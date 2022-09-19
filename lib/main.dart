import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart'; //local 설정

void main() {
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DaLo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Calendar2(),
    );
  }
}

class Calendar2 extends StatefulWidget {
  const Calendar2({Key? key}) : super(key: key);
  @override
  _Calendar2State createState() => _Calendar2State();
}

class _Calendar2State extends State<Calendar2> {
  //이벤트는 이런식으로 넣기
  Map<DateTime, List<Event>> events = {
    DateTime.utc(2022, 9, 13): [Event('우리집', '10:00'), Event('학교', '17:00')],
    DateTime.utc(2022, 9, 20): [Event('집', '19:00')],
    DateTime.utc(2022, 9, 28): [Event('집', '12:00')],
    DateTime.utc(2022, 10, 20): [Event('집', '29:00')],
  };

  List<Event> _getEventsForDay(DateTime day) {
    return events[day] ?? [];
  }

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
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
            calendarFormat: _calendarFormat,
            eventLoader: _getEventsForDay,

            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                // Call `setState()` when updating calendar format
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                // Call `setState()` when updating the selected day
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _getEventsForDay(selectedDay);
              }
            },
            onPageChanged: (focusedDay) {
              // No need to call `setState()` here
              _focusedDay = focusedDay;
            },

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
            children: (_getEventsForDay(_focusedDay!)
                .map((event) => ListTile(
                      title: Text(event.toString()),
                    ))
                .toList()),
          )
        ]));
  }
}

class Event {
  String location;
  String time;
  Event(this.location, this.time);
  @override
  String toString() => '${time}  ${location}';
}
