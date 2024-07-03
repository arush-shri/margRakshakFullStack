import 'dart:async';
import 'dart:convert';

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:marg_rakshak/components/custom_widgets/contribution_row.dart';
import 'package:marg_rakshak/view/danger_alert.dart';
import 'package:marg_rakshak/view/outdoor_animator.dart';
import 'package:marg_rakshak/components/custom_widgets/custom_bottom_row.dart';
import 'package:marg_rakshak/view/placeInfo.dart';
import 'package:marg_rakshak/view/search_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../presenter/HomePresenter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import '../presenter/ServerPresenter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GoogleMapController _controller;
  bool _showSearchScreen = false;
  bool _showContributionScreen = false;
  bool _navScreen = false;
  bool _navigating = false;
  MapType mapStyle = MapType.hybrid;
  double containerHeight = 0.0.h;
  double containerWidth = 0.0.h;
  double contributionHeight = 0.0.h;
  double contributionWidth = 0.0.h;
  double terrainRadius = 0.0.h;
  String outdoorCondition = "";
  String dangerType = "";
  double screenWidth = 0.0.w;
  Position? position;
  late Response placePic;
  late Map<String, dynamic> _locationDetails;
  final homePresenter = HomePresenter();
  late StreamSubscription<Position> positionStream;
  final Set<Polyline> _directionLine = {};
  final _serverPresenter = ServerPresenter();
  final Map<String, String> destDisTime= {
    "distance": "NOT REACHABLE",
    "duration": "",
    "url": ""
  };
  Set<Marker> markersList = {};
  String userSpeed = "";

  Future<void> initLocation() async {
    final hasPermission = await _handleLocationPermission(context);
    if(hasPermission){
        position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    }
  }
  @override
  void initState() {
    initLocation();
    listenForPermissions();
    super.initState();
  }

  @override
  void dispose() {
    positionStream.cancel();
    super.dispose();
  }

  void _toggleContainer() {
    setState(() {
      containerHeight = containerHeight == 0.0.h ? 60.0.h : 0.0.h;
      containerWidth = containerWidth == 0.0.h ? 223.0.w : 0.0.w;
      terrainRadius = terrainRadius == 0.0.h ? 21.0.h : 0.0.h;
    });
  }

  void _toggleContribute(){
    setState(() {
      contributionHeight = contributionHeight == 0.0.h ? 84.h : 0.0.h;
      contributionWidth = contributionWidth == 0.0.w ? 410.0.w : 0.0.w;
      _showContributionScreen = !_showContributionScreen;
      screenWidth = screenWidth == 0.0.w? 46.w : 0.0.w;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    _centerCamera();
  }

  Future<void> showDan() async {
    await Future.delayed(const Duration(seconds: 40));
    _navScreen = false;
  }

  Future<void> getWeather() async{
    Timer.periodic(const Duration(minutes: 30), (Timer timer) async {
      String condition = await _serverPresenter.getWeather(position!.latitude, position!.longitude);
      setState(() {
        outdoorCondition = condition;
      });
      await Future.delayed(const Duration(milliseconds: 1300));
      setState(() {
        outdoorCondition = "";
      });
    });
  }

  Future<void> navigating(double lat, double lng, double speed) async {
    Map<String, dynamic> dangerAhead = await _serverPresenter.navigating(lat, lng, speed);
    setState(() {
      markersList.clear();
      dangerAhead.forEach((key, value) async {
        if(value.isNotEmpty && !_navScreen){
          setState(() {
            dangerType = key;
            _navScreen = true;
          });
          await Future.delayed(const Duration(milliseconds: 1300));
          setState(() {
            dangerType = "";
            showDan();
          });
        }

        String imageAsset = "assets/images/danger_icon.png";
        if(key == "AccidentArea"){
          imageAsset = "assets/images/accident_icon.png";
        }
        else if(key == "RailwayCross"){
          imageAsset = "assets/images/rail_icon.png";
        }
        else if(key == "ForestArea"){
          imageAsset = "assets/images/forest_icon.png";
        }
        else if(key == "GhatRegion"){
          imageAsset = "assets/images/ghat_icon.png";
        }
        else if(key == "UserPosition"){
          imageAsset = "assets/images/user_icon.png";
        }

        await Future.forEach(value, (item) async {
          item = item as Map<String, dynamic>;
          final pos = LatLng(item["location"]["coordinates"][1], item["location"]["coordinates"][0]);
          markersList.add(
              Marker(
                markerId: MarkerId(item["_id"].toString()),
                position: pos,
                icon: await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(9.h, 9.h)),
                    imageAsset),
                infoWindow: InfoWindow(title: key),
              )
          );
        });
      });
    });

  }

  Future<void> locationSearched(String placeName) async {
    final response = await homePresenter.getPlaceDetails(placeName);
    _locationDetails = json.decode(response.body)['result'];
    final directionResponse = await homePresenter.getDirection(
        _locationDetails["geometry"]["location"]["lat"],
        _locationDetails["geometry"]["location"]["lng"],
        position!.latitude,
        position!.longitude
    );
    placePic = await homePresenter.getPlaceImage(_locationDetails['photos'][0]["photo_reference"]);
    final pos = LatLng(_locationDetails["geometry"]["location"]["lat"], _locationDetails["geometry"]["location"]["lng"]);
    setState(() {
      if(directionResponse.length!=0){
        List<PointLatLng> polyList = PolylinePoints().decodePolyline(directionResponse["overview_polyline"]["points"]);
        List<LatLng> latLngList = polyList.map((point) => LatLng(point.latitude, point.longitude)).toList();
        _directionLine.add(Polyline(
            polylineId: const PolylineId('directions'),
            points: latLngList,
            color: Colors.blue,
            width: 5
        ));
        destDisTime["distance"] = directionResponse["legs"][0]["distance"]["text"];
        destDisTime["duration"] = directionResponse["legs"][0]["duration"]["text"];
        destDisTime["url"] = _locationDetails["url"];
      }
      _showSearchScreen = false;
      _navScreen = true;
      final placeMark = Marker(
        markerId: const MarkerId('place marker'),
        position: pos,
        infoWindow: InfoWindow(title: _locationDetails["name"]),
      );
      markersList.add(placeMark);
      _controller.animateCamera(
        CameraUpdate.newLatLng(
          pos,
        ),
      );
    });
  }

  void _centerCamera() async {
    while (position == null) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    if(_navigating){
      _controller.animateCamera(
          CameraUpdate.newCameraPosition(
              CameraPosition(
                  target: LatLng(position!.latitude, position!.longitude),
                  tilt: 55.0,
                  zoom: 17.9,
                  bearing: position!.heading
              )
          )
      );
    }
    else{
      _controller.animateCamera(
          CameraUpdate.newCameraPosition(
              CameraPosition(
                  target: LatLng(position!.latitude, position!.longitude),
                  tilt: 0,
                  zoom: 17,
              )
          )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if(_showSearchScreen){
          setState(() {
            _showSearchScreen = false;
          });
          return false;
        }
        if(markersList.isNotEmpty){
          setState(() {
            if(_directionLine.isNotEmpty){
              _directionLine.clear();
            }
            if(_navigating){
              _navigating = false;
              positionStream.cancel();
            }
            markersList.clear();
            _navScreen = false;
          });
          _centerCamera();
          return false;
        }
        return true;
      },
      child: ScreenUtilInit(
        designSize: const Size(450, 800),
        builder: (context, child){
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              resizeToAvoidBottomInset: false,
              body: Column(
                children: [
                  SizedBox(
                    width: 450.w,
                    height: 800.h,
                    child: Stack(
                      children: [
                        GoogleMap(
                          onMapCreated: _onMapCreated,
                          scrollGesturesEnabled: true,
                          myLocationButtonEnabled: false,
                          myLocationEnabled: true,
                          zoomGesturesEnabled: true,
                          zoomControlsEnabled: false,
                          tiltGesturesEnabled: true,
                          rotateGesturesEnabled: true,
                          mapType: mapStyle,
                          initialCameraPosition: const CameraPosition(
                            target: LatLng(0,0),
                            zoom: 15.0,
                          ),
                          markers: markersList,
                          polylines: _directionLine,
                        ),
                        AnimatedPositioned(
                            top:  _showSearchScreen? 0.h : 70.h,
                            left: _showSearchScreen? 0.h : 35.w,
                            right: _showSearchScreen? 0.h : 35.w,
                            duration: const Duration(milliseconds: 200),
                            child: GestureDetector(
                              onTap: (){
                                setState(() {
                                  _showSearchScreen = true;
                                });
                              },
                              child: _navigating? const SizedBox() : SearchScreen(searchBoxOpen: _showSearchScreen, callback: () {
                                setState(() {
                                  _showSearchScreen = false;
                                });
                              }, locationSearched: (String placeName) { locationSearched(placeName); },)
                            )
                        ),
                        outdoorCondition == "" ? Container() : Positioned(
                          child: Container(
                            width: 450.w,
                            height: 800.h,
                            color: const Color(0xFF2C2C2C).withOpacity(0.7),
                            child: OutdoorAnimation(condition: outdoorCondition),
                          ),
                        ),
                        dangerType == ""? const SizedBox() : Positioned(
                          child: Container(
                            width: 450.w,
                            height: 800.h,
                            color: const Color(0xFF2C2C2C).withOpacity(0.7),
                            child: DangerAlert(dangerType: dangerType,),
                          ),
                        ),
                        Positioned(
                            bottom: 150.h,
                            left: 34.w,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.fastOutSlowIn,
                              height: containerHeight,
                              width: containerWidth,
                              padding: EdgeInsets.symmetric(horizontal: 13.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(20.h)),
                                color: Colors.white.withOpacity(0.9)
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    terrainIcon('assets/images/sat_pic.png', () {
                                      setState(() {
                                        mapStyle = MapType.hybrid;
                                      });
                                      _toggleContainer;
                                    }),
                                    SizedBox(width: 26.w,),
                                    terrainIcon('assets/images/def_pic.png', () {
                                      setState(() {
                                        mapStyle = MapType.normal;
                                      });
                                      _toggleContainer;
                                    }),
                                    SizedBox(width: 26.w,),
                                    terrainIcon('assets/images/ter_pic.png', () {
                                      setState(() {
                                        mapStyle = MapType.terrain;
                                      });
                                      _toggleContainer;
                                    }),
                                  ],
                                ),
                              ),
                            )
                        ),
                        Positioned(
                            top: 600.h,
                            left: 10.w,
                            child: !_navigating? const SizedBox() : CircleAvatar(
                              radius: 23.h,
                              backgroundColor: Colors.white,
                              child: Text(
                                userSpeed,
                                style: TextStyle(fontSize: 20.sp,
                                    fontFamily: "Lexend", fontWeight: FontWeight.w400, color: Colors.black ),
                              ),
                            )
                        ),
                        Positioned(
                          top: 660.h,
                          left: 10.w,
                          child: GestureDetector(
                            onTap: _toggleContainer,
                            child: _showSearchScreen? const SizedBox() : CircleAvatar(
                              radius: 20.h,
                              backgroundColor: Colors.white70,
                              child: Icon(Icons.layers_rounded, size: 28.h, color: Colors.black,),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 660.h,
                          right: 10.w,
                          child: GestureDetector(
                            onTap: _centerCamera,
                            child: _showSearchScreen? const SizedBox() : CircleAvatar(
                              radius: 20.h,
                              backgroundColor: Colors.white70,
                              child: Icon(Icons.gps_fixed_rounded, size: 29.h,
                                color: const Color(0xFF3263FF),),
                            ),
                          ),
                        ),
                        AnimatedPositioned(
                            bottom: 100.h,
                            left: _showContributionScreen? 10.w : 300.w,
                            right: _showContributionScreen? 30.w : 180.w,
                            duration: const Duration(milliseconds: 250),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                              height: contributionHeight,
                              width: contributionWidth,
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(20.h)),
                                  color: const Color(0xFF44056C).withOpacity(0.9)
                              ),
                              child: SingleChildScrollView(
                                child: ContributionRow(screenWidth: screenWidth, moving: false),
                              )
                            )
                        ),
                        _navScreen? Positioned(
                            bottom: 0.h,
                            left: 0.w,
                            right: 0.w,
                            child: _showSearchScreen? const SizedBox() : _navigating? Container(
                              width: 450.w,
                              height: 84.h,
                              color: const Color(0xFF44056C).withOpacity(0.9),
                              child: SingleChildScrollView(
                                child: ContributionRow(screenWidth: 46.w, moving: true),
                              ),
                            ) : locationInfo()
                        ) : Positioned(
                            top: 710.h,
                            left: 10.w,
                            child: _showSearchScreen? const SizedBox() : Container(
                              width: 430.w,
                              height: 65.h,
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.75),
                                  borderRadius: BorderRadius.all(Radius.circular(20.w))
                              ),
                              child: BottomHomeRow(
                                toggleContribute: _toggleContribute,
                                navHome: (lat, lng ) async {
                                  final directionResponse = await homePresenter.getDirection(
                                      lat, lng,
                                      position!.latitude,
                                      position!.longitude
                                    );
                                  setState(() {
                                    if(directionResponse.length!=0){
                                      List<PointLatLng> polyList = PolylinePoints().decodePolyline(directionResponse["overview_polyline"]["points"]);
                                      List<LatLng> latLngList = polyList.map((point) => LatLng(point.latitude, point.longitude)).toList();
                                      _directionLine.add(Polyline(
                                          polylineId: const PolylineId('directions'),
                                          points: latLngList,
                                          color: Colors.blue,
                                          width: 5
                                        ));
                                    }
                                    _showSearchScreen = false;
                                    _navScreen = true;
                                    final placeMark = Marker(
                                      markerId: const MarkerId('place marker'),
                                      position: LatLng(lat, lng),
                                      infoWindow: InfoWindow(title: _locationDetails["name"]),
                                    );
                                    markersList.add(placeMark);
                                    _controller.animateCamera(
                                      CameraUpdate.newLatLng(
                                        LatLng(lat, lng),
                                      ),
                                    );
                                  });
                            },),
                            )
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget terrainIcon(String picPath, VoidCallback callback){
    return GestureDetector(
      onTap: callback,
      child: CircleAvatar(
        radius: terrainRadius,
        backgroundColor: Colors.transparent,
        backgroundImage: AssetImage(picPath),
      ),
    );
  }

  Widget locationInfo(){
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        color: Colors.white,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 450.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(_locationDetails['name'],
                            style: TextStyle(fontSize: 26.sp, fontFamily: "Lexend",
                                fontWeight: FontWeight.w500, color: Colors.black),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 5.h,),
                          Text("${destDisTime["distance"]} (${destDisTime["duration"]})",
                              style: TextStyle(fontSize: 19.sp, fontFamily: "Lexend",
                                  fontWeight: FontWeight.w400, color: Colors.black ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 5.h,),
                          _locationDetails.containsKey("opening_hours") && _locationDetails["opening_hours"]["open_now"]!=null?
                          Row(
                            children: [
                              Text( _locationDetails["opening_hours"]["open_now"]? "Open": "Close",
                                style: TextStyle(fontSize: 19.sp, fontFamily: "Lexend",
                                    fontWeight: FontWeight.w400,
                                    color: _locationDetails["opening_hours"]["open_now"]? const Color(0xFF1FFF12) : Colors.red),
                              ),
                              Text( ": ${getPlaceTiming()}",
                                style: TextStyle(fontSize: 19.sp, fontFamily: "Lexend",
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black),
                              ),
                            ],
                          ) : const SizedBox(),
                          SizedBox(height: 5.h,),
                          _locationDetails.containsKey("rating")?
                          Row(
                            children: [
                              Text("RATING: ${_locationDetails["rating"].toString()}",
                                style: TextStyle(fontSize: 17.sp, fontFamily: "Lexend",
                                    fontWeight: FontWeight.w400, color: Colors.black),                             //total
                              ),
                              const Icon(Icons.star, color: Color(0xFFFFD700),),
                              Text("(${_locationDetails["user_ratings_total"].toString()})",
                                style: TextStyle(fontSize: 17.sp, fontFamily: "Lexend",
                                    fontWeight: FontWeight.w500, color: Colors.blueGrey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ) : const SizedBox(),
                          GestureDetector(
                              onTap: (){
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) => PlaceInformation(locationDetails: _locationDetails)));
                              },
                              child: Text("Show more details",
                                style: TextStyle(fontSize: 20.sp, fontFamily: "Lexend",
                                    fontWeight: FontWeight.w500, color: Colors.blue,
                                    decoration: TextDecoration.underline),
                                overflow: TextOverflow.ellipsis,
                              )
                          ),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  getWeather();
                                  setState(() {
                                    positionStream = Geolocator.getPositionStream(
                                        locationSettings: const LocationSettings(accuracy: LocationAccuracy.bestForNavigation,distanceFilter: 1)
                                    ).listen((Position newPosition) {
                                      setState(() {
                                        userSpeed = (newPosition.speed * 3.6).toStringAsPrecision(2);
                                        position = newPosition;
                                        navigating(position!.latitude, position!.longitude, newPosition.speed);
                                        _centerCamera();
                                      });
                                    });
                                    _navigating = true;
                                  });
                                  Fluttertoast.showToast(
                                    msg: "Please provide information through\nbottom bar to help us know about roads",
                                    toastLength: Toast.LENGTH_LONG,
                                    timeInSecForIosWeb: 3,
                                    gravity: ToastGravity.CENTER,
                                    backgroundColor: const Color(0xFF00A6FF),
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(400.w))
                                  )
                                ),
                                child: Text(
                                    "START",
                                    style: TextStyle(fontSize: 18.sp, fontFamily: "Lexend",
                                        fontWeight: FontWeight.w400, color: Colors.white),
                                  ),
                              ),
                              SizedBox(width: 22.w,),
                              ElevatedButton(
                                onPressed: (){
                                  Share.share(destDisTime["url"]!);
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurpleAccent,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(400.w))
                                    )
                                ),
                                child: Text(
                                  "SHARE",
                                  style: TextStyle(fontSize: 18.sp, fontFamily: "Lexend",
                                      fontWeight: FontWeight.w400, color: Colors.white),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        width: 195.w,
                        height: 115.h,
                        child: Image.memory(Uint8List.fromList(placePic.bodyBytes),
                            fit: BoxFit.fill,),
                      )
                    ],
                  ),
              ],
            ),
          ),
        ),
      );
  }
  String getPlaceTiming(){
    Map<int, String> dayMap = {
      1: 'Mon',
      2: 'Tue',
      3: 'Wed',
      4: 'Thu',
      5: 'Fri',
      6: 'Sat',
      7: 'Sun',
    };
    DateTime date = DateTime.now();
    int dayNum = date.weekday;

    if(!_locationDetails["opening_hours"]["open_now"]){
      dayNum = (dayNum % (_locationDetails["opening_hours"]["periods"].length)) as int;
      final openingDate = _locationDetails["opening_hours"]["periods"][dayNum];
      return "Opens ${dayMap[openingDate["open"]["day"]]!} at ${_convertTime(openingDate["open"]["time"])}";
    }
    final openingDate = _locationDetails["opening_hours"]["periods"][dayNum-1];
    return"Closes at ${_convertTime(openingDate["close"]["time"])}";
  }

  String _convertTime(String time){
    int hour = int.parse(time.substring(0,2));
    int min = int.parse(time.substring(2,4));
    String amPm = hour>=12? "PM" : "AM";
    if(hour==00){
      hour=12;
    }
    else{
      hour = hour%12;
    }
    return "$hour:$min $amPm";
  }
}
Future<bool> _handleLocationPermission(BuildContext context) async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Location services are disabled. Please enable the services')));
    return false;
  }
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')));
      return false;
    }
  }
  if (permission == LocationPermission.deniedForever) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Location permissions are permanently denied, we cannot request permissions.')));
    return false;
  }
  return true;
}
void listenForPermissions() async {
  final status = await Permission.microphone.status;
  switch (status) {
    case PermissionStatus.denied:
      requestForPermission();
      break;
    case PermissionStatus.granted:
      break;
    case PermissionStatus.limited:
      break;
    case PermissionStatus.permanentlyDenied:
      break;
    case PermissionStatus.restricted:
      break;
    case PermissionStatus.provisional:
      break;
  }
}
Future<void> requestForPermission() async {
  await Permission.microphone.request();
}
