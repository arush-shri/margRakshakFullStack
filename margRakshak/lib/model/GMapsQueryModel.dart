import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GoogleMapsQuery{

  final String? _apiKey = dotenv.env['GMAPSAPI'];

  Future<List<dynamic>> getPlaces(String inputText, String sessionToken) async {
    List<dynamic> responseList = [];
    String baseURL1 = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$_apiKey&sessiontoken=$sessionToken";
    final response1=  await http.get(Uri.parse(baseURL1));
    for (var element in (jsonDecode(response1.body)["predictions"])) {
      responseList.add(element);
    }
    if(inputText.length>=2){
      String baseURL2 = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${inputText.substring(0, inputText.length-1)}&key=$_apiKey&sessiontoken=$sessionToken";
      final response2 =  await http.get(Uri.parse(baseURL2));
      for (var element in (jsonDecode(response2.body) ["predictions"])) {
        responseList.add(element);
      }
    }
    return responseList;
  }

  Future<http.Response> getLocationDetail(String placeName) async {
    String baseUrl = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=$placeName&key=$_apiKey";
    final response = await http.get(Uri.parse(baseUrl));
    String placeDetailUrl = "https://maps.googleapis.com/maps/api/place/details/json?place_id=${json.decode(response.body)['results'][0]['place_id']}&key=$_apiKey";
    return await http.get(Uri.parse(placeDetailUrl));
  }

  Future<http.Response> getPlaceImage(String photoRefer) async {
    String baseUrl = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=$photoRefer&key=$_apiKey";
    return await http.get(Uri.parse(baseUrl));
  }

  Future<dynamic> getDirection(double destLat, double destLon, double myLat, double myLon) async {
    String baseUrl = "https://maps.googleapis.com/maps/api/directions/json?destination=$destLat,$destLon&origin=$myLat,$myLon&units=metric&key=$_apiKey";
    final response = await http.get(Uri.parse(baseUrl));
    var directionsList = json.decode(response.body);
    if(directionsList["status"] == "ZERO_RESULTS")
    {
      directionsList = [];
    }
    else{
      directionsList = directionsList["routes"];
    }
    if(directionsList.length > 1){
      directionsList.sort((a,b) => a["legs"]["duration"]["value"].compareTo(b["legs"]["duration"]["value"]));
    }
    return directionsList[0];
  }
}