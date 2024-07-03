import 'package:http/http.dart';
import 'package:marg_rakshak/model/GMapsQueryModel.dart';


class HomePresenter {

  final googleMapQuery = GoogleMapsQuery();

  Future<List<dynamic>> getPlaces(String inputText, String sessionToken) async {
    return await googleMapQuery.getPlaces(inputText, sessionToken);
  }

  Future<Response> getPlaceDetails(String placeName) async {
    return await googleMapQuery.getLocationDetail(placeName);
  }

  Future<Response> getPlaceImage(String photoRefer) async {
    return await googleMapQuery.getPlaceImage(photoRefer);
  }

  Future<dynamic> getDirection(double destLat, double destLon, double myLat, double myLon) async {
    return await googleMapQuery.getDirection(destLat, destLon, myLat, myLon);
  }
}