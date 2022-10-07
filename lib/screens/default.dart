import 'package:flutter/material.dart';

class Name extends StatefulWidget {
  @override
  State<Name> createState() => _NameState();
}

class _NameState extends State<Name> {
  //사용할 함수적기
  void func() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black, // Background color
              foregroundColor: Colors.white, // Text Color (Foreground color)
            ),
            child: const Text('이런식으로 넣기'),
          )
        ]))));
  }
}
