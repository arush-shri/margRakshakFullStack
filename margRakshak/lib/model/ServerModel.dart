import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ServerModel{

  String _userEmail = "";
  dynamic _objectId = "";
  final _serverLink = dotenv.env['SERVERLINK'];
  final _weatherKey = dotenv.env['WEATHERAPI'];
  ServerModel(){
    User? user = FirebaseAuth.instance.currentUser;
    if(user != null){
      _userEmail = user.email!;
    }
  }

  Future<http.Response> createUser() async {
    return await http.get(Uri.parse("${_serverLink}user/createUser/$_userEmail"));
  }

  Future<void> checkUserExists() async {
    final response = await http.get(Uri.parse("${_serverLink}user/userExists/$_userEmail"));
    if(response.statusCode == 402){
      createUser();
    }
  }

  Future<http.Response> getHomeLocation() async {
    return await http.get(Uri.parse("${_serverLink}user/getHomeLocation/$_userEmail"));
  }

  Future<http.Response> setHomeLocation() async {

    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return await http.post(Uri.parse("${_serverLink}user/updateHomeLocation/$_userEmail"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'latitude': "${position.latitude}",
          'longitude': "${position.longitude}"
        })
    );
  }

  Future<http.Response> makeContribution(String collectionName, String? otherName) async {
    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print(position);
    return await http.post(Uri.parse("${_serverLink}contribute/makeContribution"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'collectionName': collectionName,
      'latitude': "${position.latitude}",
      'longitude': "${position.longitude}",
      'name': "$otherName"
    }));
  }

  Future<void> navigating(double lat, double lng) async {
    final setResponse = await http.post(
          Uri.parse("${_serverLink}navigation/myLocation"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            "email": _userEmail,
            "latitude": "$lat",
            "longitude": "$lng",
            "objectId": _objectId
          })
        );
    if(setResponse.body.isNotEmpty){
      _objectId = setResponse.body;
    }
  }

  Future<dynamic> getDanger(double speed) async {
    final getDangerRes = await http.get(Uri.parse("${_serverLink}navigation/getDangers/${speed * 35}"));
    var decodedRes = json.decode(getDangerRes.body);
    if(decodedRes["OtherRegion"].isNotEmpty){
      await Future.forEach(decodedRes["OtherRegion"], (item) async {
        item = item as Map<String, dynamic>;
        final result = json.decode((await http.post(Uri.parse("${_serverLink}contribute/getOtherName"),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              "latitude": "${item["location"]["coordinates"][1]}",
              "longitude": "${item["location"]["coordinates"][0]}"
            })
        )).body);
        decodedRes["${result["areaName"]}"] = [];
        decodedRes["${result["areaName"]}"].add(item);
      });
      decodedRes.remove("OtherRegion");
    }
    print(decodedRes);
    return decodedRes;
  }

  Future<String> getWeather(double lat, double lng) async {
    final baseURL = "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lng&appid=$_weatherKey";
    final response = json.decode((await http.get(Uri.parse(baseURL))).body);
    return response["weather"]["main"];
  }
}