import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart'; //gps

import 'package:background_locator_2/auto_stop_handler.dart';
import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/callback_dispatcher.dart';
import 'package:background_locator_2/keys.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:background_locator_2/settings/android_settings.dart'
    as andSetting;
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart'
    as locAccuracy;
import 'package:background_locator_2/utils/settings_util.dart';

import 'package:dalo/screens/location_callback_handler.dart';
import 'package:dalo/screens/location_service_repository.dart';
import 'package:intl/intl.dart';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:dalo/db/db_helper.dart';
import 'package:dalo/db/db_model.dart';

class Loading extends StatefulWidget {
  @override
  LoadingState createState() => LoadingState();
}

class LoadingState extends State<Loading> {
  var currentPosition;

  @override
  initState() {
    super.initState();
    getCurrentLocation();
    startLocationService();
    // checkLocation(8, 8); 해당 날짜에, 앱이 정상적으로 작동하는지 확인하는 테스트코드
  }

  getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        currentPosition = position;
        print('현재 위치 : $currentPosition');
      });
    }).catchError((e) {
      print(e);
    });
    return currentPosition;
  }

  void changeDB() async {
    // save(currentPosition.latitude, currentPosition.longitude);
    // DBHeler().deleteAllDatas();

    // DBHeler().createData(Data(date: '2022-10-02', time: '16:00', loc: '우리 집'));
    // DBHeler().createData(Data(date: '2022-10-13', time: '12:00', loc: '학교'));
    // DBHeler().createData(Data(date: '2022-10-20', time: '20:00', loc: '공원'));
    // DBHeler().createData(Data(date: '2022-10-24', time: '11:00', loc: '마트'));
    // DBHeler().createData(Data(date: '2022-10-27', time: '10:00', loc: '직장'));
    // DBHeler().createData(Data(date: '2022-10-27', time: '12:00', loc: '학원'));
    // DBHeler().createData(Data(date: '2022-10-28', time: '16:00', loc: '우리 집'));
    // DBHeler().createData(Data(date: '2022-10-30', time: '15:36', loc: '친구 집'));

    // 데이터 추가
    // DBHeler().createData(Data(
    //     date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    //     time: DateFormat('HH:mm').format(DateTime.now()),
    //     loc: '우리 집'));

    // 특정 데이터 삭제
    // DBHeler().deleteData(DateFormat('yyyy-MM-dd').format(DateTime.now()),
    //     DateFormat('HH:mm').format(DateTime.now()));

    //특정 데이터 가져오기
    // var list = await DBHeler().getData(
    //     DateFormat('yyyy-MM-dd').format(DateTime.now()),
    //     DateFormat('HH:mm').format(DateTime.now()));

    // 모든 데이터 가져오기
    print('DB 확인');
    var list = await DBHeler().getAllDatas();
    for (var item in list) {
      print('${item.date} ${item.time} ${item.loc}');
    }
  }

  void startLocationService() {
    Map<String, dynamic> data = {'countInit': 1};
    BackgroundLocator.registerLocationUpdate(LocationCallbackHandler.callback,
        initCallback: LocationCallbackHandler.initCallback,
        initDataCallback: data,
        disposeCallback: LocationCallbackHandler.disposeCallback,
        autoStop: false,
        iosSettings: const IOSSettings(
          accuracy: locAccuracy.LocationAccuracy.NAVIGATION,
          distanceFilter: 0,
        ),
        androidSettings: const andSetting.AndroidSettings(
          accuracy: locAccuracy.LocationAccuracy.NAVIGATION,
          interval: 300,
          distanceFilter: 0,
          androidNotificationSettings: andSetting.AndroidNotificationSettings(
            notificationChannelName: 'Location tracking',
            notificationTitle: 'Start Location Tracking',
            notificationMsg: 'Track location in background',
            notificationBigMsg:
                'Background location is on to keep the app up-tp-date with your location. This is required for main features to work properly when the app is not running.',
            notificationIcon: '',
            notificationIconColor: Colors.grey,
            notificationTapCallback:
                LocationCallbackHandler.notificationCallback,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            changeDB();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black, // Background color
            foregroundColor: Colors.white, // Text Color (Foreground color)
          ),
          child: const Text('DB체크'),
        ),
        ElevatedButton(
          onPressed: () {
            getCurrentLocation();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black, // Background color
            foregroundColor: Colors.white, // Text Color (Foreground color)
          ),
          child: const Text('get my location'),
        ),
        ElevatedButton(
          onPressed: () {
            startLocationService();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black, // Background color
            foregroundColor: Colors.white, // Text Color (Foreground color)
          ),
          child: const Text('백그라운드 시작'),
        )
      ],
    ));
  }

  Future<void> save(dynamic lat, dynamic lot) async {
    DBHeler hp = DBHeler();
    var time = DateTime.now();
    var data = Data(
      date: DateFormat('yyyy-MM-dd').format(time),
      time: DateFormat('HH:mm').format(time),
      loc: ('$lat + $lot'),
    );
    await hp.createData(data);
  }
}
