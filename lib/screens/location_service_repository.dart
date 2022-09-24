import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:background_locator_2/location_dto.dart';
import 'package:dalo/screens/loading.dart';
import 'package:dalo/db/db_helper.dart';

class LocationServiceRepository {
  static LocationServiceRepository _instance = LocationServiceRepository._();

  LocationServiceRepository._();

  factory LocationServiceRepository() {
    return _instance;
  }

  Future<void> init() async {
    //TODO change logs
    print("***********Init callback handler");
  }

  Future<void> dispose() async {}

  Future<void> callback(LocationDto locationDto) async {
    print('location in dart: ${locationDto.toString()}');
    await setLogPosition(locationDto);
    print('callback ok');
  }

  static Future<void> setLogPosition(LocationDto data) async {
    final date = DateTime.now();
    // await Loading().save(data.loc);
  }
}
