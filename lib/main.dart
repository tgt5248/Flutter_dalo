import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; //local 설정
import 'package:dalo/screens/loading.dart';
import 'package:dalo/screens/calendar2.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(const MyApp()));
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
      home: const Calendar(),
      // home: Loading(),
    );
  }
}
