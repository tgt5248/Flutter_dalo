import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; //gps

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  void getLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print(position);
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
}
