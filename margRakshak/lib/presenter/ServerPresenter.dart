import 'package:http/http.dart';
import 'package:marg_rakshak/model/ServerModel.dart';

class ServerPresenter {

  ServerPresenter._privateConstructor();
  static final ServerPresenter _instance = ServerPresenter._privateConstructor();
  static final _serverModel = ServerModel();

  factory ServerPresenter(){
    _serverModel.checkUserExists();
    return _instance;
  }
  Future<Response> getHomeLocation() async {
    return await _serverModel.getHomeLocation();
  }
  Future<Response> setHouseLocation() async {
    return await _serverModel.setHomeLocation();
  }
  Future<Response> makeContribution(String collectionName, String? otherName) async {
    return await _serverModel.makeContribution(collectionName, otherName);
  }
  Future<Map<String, dynamic>> navigating(double lat, double lng, double speed) async {
    await _serverModel.navigating(lat, lng);
    final dangerList = await _serverModel.getDanger(speed);
    return dangerList;
  }

  Future<String> getWeather(double lat, double lng) async{
    return await _serverModel.getWeather(lat, lng);
  }

}