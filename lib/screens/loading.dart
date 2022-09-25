import 'dart:developer';

import 'package:flutter/material.dart';

// import 'package:geolocator/geolocator.dart'; //gps

import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';

import 'package:dalo/screens/location_callback_handler.dart';
import 'package:dalo/screens/location_service_repository.dart';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:dalo/db/db_helper.dart';
import 'package:dalo/db/db_model.dart';

// import 'package:background_locator_2/location_dto.dart';
// import 'package:background_locator_2/settings/android_settings.dart';
// import 'package:background_locator_2/settings/ios_settings.dart';
// import 'package:background_locator_2/settings/locator_settings.dart';
class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  // void getLocation() async {
  //   LocationPermission permission = await Geolocator.requestPermission();
  //   Position position = await Geolocator.getCurrentPosition(
  //       //lowest, low, medium, high, best, bestForNavigation
  //       desiredAccuracy: LocationAccuracy);
  //   print(position);
  // }
  void getLocation() async {
    // DBHeler().deleteAllDatas();
    // DBHeler().createData(
    //     Data(id: 1, date: '2022-09-10', time: '16:00', loc: '우리 집'));
    // DBHeler()
    //     .createData(Data(id: 2, date: '2022-09-13', time: '12:00', loc: '학교'));
    // DBHeler()
    //     .createData(Data(id: 3, date: '2022-09-20', time: '20:00', loc: '공원'));
    // DBHeler()
    //     .createData(Data(id: 4, date: '2022-09-24', time: '11:00', loc: '마트'));
    // DBHeler()
    //     .createData(Data(id: 5, date: '2022-09-28', time: '10:00', loc: '직장'));
    // DBHeler().createData(
    //     Data(id: 6, date: '2022-09-28', time: '16:00', loc: '우리 집'));

    var list = await DBHeler().getAllDatas();
    for (var item in list) {
      print('${item.id} ${item.date} ${item.time} ${item.loc}');
    }
  }

  Future<void> _startLocator() async {
    Map<String, dynamic> data = {'countInit': 1};
    return await BackgroundLocator.registerLocationUpdate(
        LocationCallbackHandler.callback,
        initCallback: LocationCallbackHandler.initCallback,
        initDataCallback: data,
        disposeCallback: LocationCallbackHandler.disposeCallback,
        iosSettings: const IOSSettings(
            accuracy: LocationAccuracy.NAVIGATION,
            distanceFilter: 0,
            stopWithTerminate: true),
        autoStop: false,
        androidSettings: const AndroidSettings(
            accuracy: LocationAccuracy.NAVIGATION,
            interval: 10,
            distanceFilter: 0,
            client: LocationClient.google,
            androidNotificationSettings: AndroidNotificationSettings(
                notificationChannelName: 'Location tracking',
                notificationTitle: 'Start Location Tracking',
                notificationMsg: 'Track location in background',
                notificationBigMsg:
                    'Background location is on to keep the app up-tp-date with your location. This is required for main features to work properly when the app is not running.',
                notificationIconColor: Colors.grey,
                notificationTapCallback:
                    LocationCallbackHandler.notificationCallback)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: ElevatedButton(
        onPressed: () {
          getLocation();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black, // Background color
          foregroundColor: Colors.white, // Text Color (Foreground color)
        ),
        child: const Text('get my location'),
      ),
    ));
  }

  Future<void> save(String loc) async {
    DBHeler hp = DBHeler();
    var time = DateTime.now();
    var data = Data(
      id: 1,
      date: time as String,
      time: time as String,
      loc: loc,
    );
    await hp.createData(data);
  }
}
