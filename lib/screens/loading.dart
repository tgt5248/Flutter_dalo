import 'package:dalo/screens/calendar2.dart';
import 'package:dalo/screens/changeLoc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parse;
import 'dart:convert';

import 'package:dalo/screens/location_callback_handler.dart';
import 'package:dalo/screens/location_service_repository.dart';
import 'package:dalo/screens/changeLoc.dart';

import 'package:dalo/db/db_helper.dart';
import 'package:dalo/db/db_model.dart';

class Loading extends StatefulWidget {
  @override
  LoadingState createState() => LoadingState();
}

class LoadingState extends State<Loading> {
  Map<String, String> header = {
    //카카오
    "Authorization": "KakaoAK 8d164cb5cddceae289226f393bc13341"
  };

  @override
  initState() {
    super.initState();
    // getCurrentLocation();
    // startLocationService();
    // checkLocation(8, 8); 해당 날짜에, 앱이 정상적으로 작동하는지 확인하는 테스트코드
  }

  //현재 위도경도로 도로명주소 알아내서 그 위치에 있는 상가들 3개 불러오기
  //https://developers.kakao.com/docs/latest/ko/local/dev-guide#coord-to-address
  getCurrentLocation() async {
    print('*** 현재 위도 경도 확인 ***');
    LocationPermission permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    String lat = position.latitude.toString();
    String lon = position.longitude.toString();
    print('현재 위도는 : $lat, 경도는 : $lon');

    await DBHelper().getAll();
    return position;
  }

  void tostore() async {
    print('*** 현재 장소 3개까지 DB에 저장***');
    var position = await getCurrentLocation();
    String lat = position.latitude.toString();
    String lon = position.longitude.toString();
    //카카오 지오코딩
    Uri kakaoGeoUrl = Uri.parse(
        'https://dapi.kakao.com/v2/local/geo/coord2address.json?x=$lon&y=$lat&input_coord=WGS84');
    http.Response kakaoGeo = await http.get(kakaoGeoUrl, headers: header);
    String addr = kakaoGeo.body;
    var addrData = jsonDecode(addr);
    String road = addrData['documents'][0]['road_address']['address_name'];
    String building = addrData['documents'][0]['road_address']['building_name'];
    print('현재 위치는 $road');

    // 키워드 검색을 통해
    Uri kakaoSearchUrl = Uri.parse(
        "https://dapi.kakao.com/v2/local/search/keyword.json?query=$road");
    http.Response kakaoSearch = await http.get(kakaoSearchUrl, headers: header);
    String storeBody = kakaoSearch.body;
    var storeData = jsonDecode(storeBody);
    List stores = storeData['documents'];
    stores.removeRange(3, stores.length); //상위 3개까지만 저장
    String store3 = '';
    stores.forEach((element) {
      store3 += element['place_name'] + ',';
    });
    store3 = store3.substring(0, (store3.length - 1));
    print('이 위치에 있는 장소는 $store3');
    print('*** DB에 저장 완료 ***');

    return save(store3);
  }

  void ResetDB() async {
    print('*** DB 초기화 ***');
    DBHelper().deleteAllDatas();

    DBHelper()
        .createData(Data(date: '2022-10-02', time: '16:00', loc: '우리 집,906호'));
    DBHelper()
        .createData(Data(date: '2022-10-13', time: '12:00', loc: '학교,카페,지하철역'));
    DBHelper().createData(Data(date: '2022-10-20', time: '20:00', loc: '공원'));
    DBHelper().createData(Data(date: '2022-10-24', time: '11:00', loc: '마트'));
    DBHelper().createData(Data(date: '2022-10-27', time: '10:00', loc: '직장'));
    DBHelper().createData(Data(date: '2022-10-27', time: '12:00', loc: '학원'));
    DBHelper().createData(Data(date: '2022-10-28', time: '16:00', loc: '우리 집'));
    DBHelper().createData(Data(date: '2022-10-30', time: '15:36', loc: '친구 집'));
    print('초기화 완료');
  }

  void checkDB() async {
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
    print('*** DB 확인 ***');
    var list = await DBHelper().getAllDatas();
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
        appBar: AppBar(
          title: const Text('DaLo - FirstPage'),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
            child: Center(
                child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Calendar()));
              },
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20),
                minimumSize: Size(150, 50),
                backgroundColor: Colors.indigoAccent[200], // Background color
                foregroundColor: Colors.white,
                // Text Color (Foreground color)
              ),
              child: const Text('캘린더보기'),
            ),
            ElevatedButton(
              onPressed: () {
                checkDB();
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
                tostore();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Background color
                foregroundColor: Colors.white, // Text Color (Foreground color)
              ),
              child: const Text('현 위치 저장'),
            ),
            ElevatedButton(
              onPressed: () {
                ResetDB();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Background color
                foregroundColor: Colors.white, // Text Color (Foreground color)
              ),
              child: const Text('DB 초기화'),
            )
          ],
        ))));
  }

  Future<void> save(String store) async {
    DBHelper hp = DBHelper();
    var time = DateTime.now();
    var data = Data(
      date: DateFormat('yyyy-MM-dd').format(time),
      time: DateFormat('HH:mm').format(time),
      loc: store,
    );
    await hp.createData(data);
  }
}
