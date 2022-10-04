import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parse;
import 'dart:convert';
import 'package:geolocator/geolocator.dart'; //gps

import 'package:dalo/screens/loading.dart';

//https://api.ncloud-docs.com/docs/ai-naver-mapsreversegeocoding-gc#%EC%9A%94%EC%B2%AD-%EC%98%88%EC%8B%9C
//https://developers.kakao.com/docs/latest/ko/local/dev-guide#coord-to-address

Map<String, String> test = {
  //네이버
  "X-NCP-APIGW-API-KEY-ID": "g1yovx6cpm",
  "X-NCP-APIGW-API-KEY": "RoJKUknc1ORii4OA4n2NZqZ11erdbaUINqbO2kCc"
};

Map<String, String> header = {
  //카카오
  "Authorization": "KakaoAK 8d164cb5cddceae289226f393bc13341"
};

class Scraping extends StatefulWidget {
  @override
  State<Scraping> createState() => _ScrapingState();
}

class _ScrapingState extends State<Scraping> {
  //현재 위도경도로 도로명주소 알아내서 그 위치에 있는 상가들 3개 불러오기
  void scarp() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    String lat = position.latitude.toString();
    String lon = position.longitude.toString();
    print(lat);
    print(lon);

    //카카오 지오코딩
    Uri kakaoGeoUrl = Uri.parse(
        'https://dapi.kakao.com/v2/local/geo/coord2address.json?x=$lon&y=$lat&input_coord=WGS84');
    http.Response kakaoGeo = await http.get(kakaoGeoUrl, headers: header);
    String addr = kakaoGeo.body;
    var addrData = jsonDecode(addr);
    String road = addrData['documents'][0]['road_address']['address_name'];
    String building = addrData['documents'][0]['road_address']['building_name'];
    print(road);
    Uri kakaoSearchUrl = Uri.parse(
        "https://dapi.kakao.com/v2/local/search/keyword.json?query={길주남로 143}");
    http.Response kakaoSearch = await http.get(kakaoSearchUrl, headers: header);
    String store = kakaoSearch.body;
    var storeData = jsonDecode(store);
    print(storeData["documents"]);
    // //네이버 지오코딩
    // http.Response naverapi = await http.get(
    //     Uri.parse(
    //         "https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc?request=coordsToaddr&coords=$lon,$lat&sourcecrs=epsg:4326&output=json&orders=roadaddr"),
    //     headers: test);
    // String jsonData = naverapi.body;
    // // 도로명, 건물이름
    // String doro = jsonDecode(jsonData)["results"][0]['land']['name'];
    // String num = jsonDecode(jsonData)["results"][0]['land']['number1'];
    // String building =
    //     jsonDecode(jsonData)["results"][0]['land']['addition0']['value'];
    // // print(jsonDecode(jsonData)["results"][0]['land']['name']); //도로명
    // // print(jsonDecode(jsonData)["results"][0]['land']['number1']); //상세주소
    // // print(
    // //     jsonDecode(jsonData)["results"][0]['land']['addition0']['value']); //건물명

    // print(doro + " " + num);
    // print(building);

    // http.Response webResponse = await http
    //     .get(Uri.parse('https://map.naver.com/v5/search/$doro%20$num/'));

    // String document = utf8.decode(webResponse.bodyBytes);
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
              scarp();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black, // Background color
              foregroundColor: Colors.white, // Text Color (Foreground color)
            ),
            child: const Text('스크랩 확인'),
          )
        ]));
  }
}
