import 'package:dalo/db/db_helper.dart';
import 'package:flutter/material.dart';
import 'package:dalo/screens/calendar2.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChangeLoc extends StatefulWidget {
  final String date;
  final String time;
  ChangeLoc({required this.date, required this.time});
  @override
  State<ChangeLoc> createState() => _ChangeLocState();
}

class _ChangeLocState extends State<ChangeLoc> {
  List all = [];
  List<String> listLoc = [];
  List newList = [];

  late Future<List<String>> _future;

  // 해당 날짜/시간 장소가져오기
  @override
  void initState() {
    super.initState();
    _future = getSelectedEvent();
  }

  // 장소 리스트로 띄우기
  Future<List<String>> getSelectedEvent() async {
    all = await DBHelper().getData(widget.date, widget.time);
    listLoc = all[0].loc.split(',');
    return listLoc;
  }

  //새로운 장소 입력 다이얼로그
  void setNewDialog() {
    String inputText = '';
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Column(
              children: const <Widget>[
                Text("새로운 장소 입력"),
              ],
            ),
            //
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                //콤마 입력 안되게 하기
                TextField(
                  onChanged: (text) {
                    setState(() {
                      inputText = text;
                    });
                  },
                ),
              ],
            ),
            //
            actions: <Widget>[
              ElevatedButton(
                child: const Text("취소"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              ElevatedButton(
                child: const Text("확인"),
                onPressed: () {
                  updateLoc(inputText);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Calendar()));
                },
              ),
            ],
          );
        });
  }

  // 장소 업데이트
  void updateLoc(String loc) async {
    newList = await getSelectedEvent();
    if (newList.contains(loc) == true) {
      newList.remove(loc);
    }
    newList.insert(0, loc);
    String newStr = '';
    newList.forEach((element) {
      newStr += element + ',';
    });
    newStr = newStr.substring(0, (newStr.length - 1));

    DBHelper().updateData(widget.date, widget.time, newStr);
  }

  //장소 삭제
  void deleteLoc(String loc) async {
    newList = await getSelectedEvent();
    newList.remove(loc);
    String newStr = '';
    newList.forEach((element) {
      newStr += element + ',';
    });
    newStr = newStr.substring(0, (newStr.length - 1));

    DBHelper().updateData(widget.date, widget.time, newStr);
  }

// 장소 삭제 다이얼로그
  void setDeleteDialog(String event) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Column(
              children: <Widget>[
                Text(event),
              ],
            ),
            //

            actions: <Widget>[
              ElevatedButton(
                child: const Text("취소"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              ElevatedButton(
                child: const Text("삭제"),
                onPressed: () {
                  deleteLoc(event);
                  flutterToast(event, "삭제");
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ChangeLoc(date: widget.date, time: widget.time)));
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('DaLo - ChangeLoc'),
          leading: IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Calendar())); //뒤로가기
              },
              icon: Icon(Icons.arrow_back)),
        ),
        body: SafeArea(
            child: Center(
                child: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            return Column(
              children: [
                Text(widget.date + ' ' + widget.time),
                Text(listLoc.length > 0 ? '현재 선택된 장소 : ${listLoc[0]}' : ''),
                Text('장소를 수정하려면 클릭'),
                ListView(
                  shrinkWrap: true,
                  children: listLoc
                      .map((event) => Container(
                            decoration: BoxDecoration(
                              border: Border.all(width: 0.8),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            child: ListTile(
                              title: Text(event),
                              onTap: () {
                                updateLoc(event);
                                flutterToast(event, "변경");
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const Calendar()));
                              },
                              onLongPress: () {
                                setDeleteDialog(event);
                              },
                            ),
                          ))
                      .toList(),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 0.8),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: ListTile(
                    title: Text("+ 장소 추가"),
                    onTap: () {
                      setNewDialog();
                    },
                  ),
                ),
              ],
            );
          },
        ))));
  }
}

void flutterToast(String event, String code) {
  Fluttertoast.showToast(
      msg: code == '변경' ? '$event로 변경 완료' : '$event 삭제 완료',
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey,
      fontSize: 14.0,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT);
}
