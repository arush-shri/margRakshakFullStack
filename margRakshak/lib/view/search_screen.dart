import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marg_rakshak/components/custom_widgets/RouteAnimator.dart';
import 'package:marg_rakshak/presenter/HomePresenter.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class SearchScreen extends StatefulWidget {
  final VoidCallback callback;
  final bool searchBoxOpen;
  final void Function(String) locationSearched;
  const SearchScreen({super.key, required this.searchBoxOpen, required this.callback, required this.locationSearched});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with TickerProviderStateMixin {
  final TextEditingController _searchText = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _animation;
  bool toastShown = false;
  bool showProgress = false;
  String transportMedium = "";
  final List<dynamic> _placesList = [];
  var uuid = const Uuid();
  String sessionToken = '124578';
  final homePresenter = HomePresenter();

  @override
  void initState() {
    _searchText.addListener(() {
      onChange();
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _animation = Tween<double>(begin: 0, end: 1.2).animate(_controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if(status == AnimationStatus.completed){
          _controller.reset();
          _controller.forward();
        }
      });

    _controller.forward();
    super.initState();
  }

  void onChange(){
    if(sessionToken == null){
      setState(() {
        sessionToken = uuid.v4();
      });
    }

    getPlaces(_searchText.text);
  }

  void getPlaces(String inputText) async{
    if(inputText.isNotEmpty){
      final response = await homePresenter.getPlaces(inputText, sessionToken);
      _placesList.clear();
      if(response.isNotEmpty){
        setState(() {
          for (var element in response) {
            _placesList.add(element);
          }
        });
        response.clear();
      }
      else{
        Fluttertoast.showToast(
            msg: "Please restart app or check you internet connection",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            backgroundColor: const Color(0xFF46009A),
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.searchBoxOpen? searchOpened(context) : searchClosed();
  }

  Widget searchClosed(){
    _controller.reset();
    toastShown = false;
    _searchText.text = "";
    setState(() {
      showProgress = false;
    });
    return Container(
      height: 45.h,
      width: 380.w,
      decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.all(Radius.circular(400.w))
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.search_rounded, size: 35.h,),
            Text("Search",
              style: TextStyle(fontSize: 18.sp, fontFamily: GoogleFonts.poppins().fontFamily,
                  fontWeight: FontWeight.bold , color: Colors.black),),
          ],
        ),
      ),
    );
  }

  Widget searchOpened(BuildContext context){
    if (!toastShown){
      _controller.forward();
      toastShown = true;
      Fluttertoast.showToast(
          msg: "Please select your transportation medium",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: const Color(0xFF46009A),
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
    return Container(
        width: 450.w,
        height: 800.h,
        decoration: const BoxDecoration(color: Color(0xFF031434)),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(30.w, 70.w, 30.w, 25.w),
              child: TextField(
                controller: _searchText,
                cursorColor: Colors.deepPurpleAccent,
                decoration: InputDecoration(
                  labelText: 'Search',
                  fillColor: Colors.transparent,
                  labelStyle: TextStyle(fontSize: 20.sp, fontFamily: GoogleFonts.poppins().fontFamily,
                      color: Colors.deepPurpleAccent),
                  filled: true,
                  isDense: true,
                  border: const UnderlineInputBorder(),
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.deepPurpleAccent)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.deepPurpleAccent)),
                  contentPadding: EdgeInsets.zero,
                ),
                style: TextStyle(color: Colors.white, fontSize: 23.sp,
                    fontFamily: "Lexend", fontWeight: FontWeight.w400),
              ),
            ),
            ChangeNotifierProvider(
              create: (context) => ButtonHighlighter(),
              child: Consumer<ButtonHighlighter>(
                builder: (context, provider, child) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    rowItem( context, "car", Icons.directions_car_filled_outlined, ()=>transportMedium = "car"),
                    rowItem( context, "bus", Icons.directions_bus_filled_outlined, ()=>transportMedium = "bus"),
                    rowItem( context, "bike", Icons.motorcycle_sharp, ()=>transportMedium = "bike"),
                    rowItem( context, "walk", Icons.directions_walk_outlined, ()=>transportMedium = "walk"),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h,),
            Divider(
              height: 1.h,
              thickness: 1.5.h,
              color: const Color(0xFFABABAB),
            ),
            showProgress? progressShow() : Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(top: 20.h),
                shrinkWrap: true,
                itemCount: _placesList.length,
                itemBuilder: (context, index){
                  return GestureDetector(
                    onTap: () async {
                      widget.locationSearched(_placesList[index]['description']);
                      _searchText.text = "";
                      setState(() {
                        _placesList.clear();
                        showProgress = true;
                      });
                    },
                    child: Container(
                      height: 56.h,
                      width: 450.w,
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 30.w,
                                color: Colors.indigoAccent,
                              ),
                              SizedBox(width: 10.w,),
                              SizedBox(
                                width: 390.w,
                                height: 45.w,
                                child: Text(
                                  _placesList[index]['description'],
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 22.sp, fontFamily: "Lexend",
                                      fontWeight: FontWeight.w400 , color: Colors.white),
                                ),
                              )
                            ],
                          ),
                          Divider(
                            height: 1.h,
                            thickness: 1.5.h,
                            indent: 10.w,
                            endIndent: 10.w,
                            color: const Color(0xFFD3CCCC),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  Widget progressShow(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 450.w,
          height: 550.h,
          child: CustomPaint(
            painter: RouteAnimator(progress: _animation.value),
          ),
        ),
        Text(
          "Finding best route for you",
          style: TextStyle(fontSize: 28.sp, fontFamily: "Lexend",
              fontWeight: FontWeight.w400 , color: Colors.white),
        ),
      ],
    );
  }
}

Widget rowItem(BuildContext context, String name, IconData icon,VoidCallback callback){
  final colorChange = Provider.of<ButtonHighlighter>(context,listen: true);
  bool colorBool = colorChange.getValue(name);
  return GestureDetector(
    onTap: (){
      callback;
      colorChange.setValue(name);
    },
    child: Container(
      width: 80.w,
      height: 40.h,
      decoration: BoxDecoration(
          color: colorBool? const Color(0xFF3479E1): Colors.transparent,
      borderRadius: BorderRadius.all(Radius.circular(400.w))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,color: colorBool? Colors.white : const Color(0xFF989898), size: 36.w,)
        ],
      ),
    ),
  );
}

class ButtonHighlighter extends ChangeNotifier{
  bool carIcon = true;
  bool busIcon = false;
  bool bikeIcon = false;
  bool walkIcon = false;

  bool getValue(String name){
    if(name == "car") {
      return carIcon;
    } else if(name == "bus") {
      return busIcon;
    } else if(name == "bike") {
      return bikeIcon;
    }
    return walkIcon;
  }

  void setValue(String name){
    if(name == "car" && !carIcon) {
      busIcon = bikeIcon = walkIcon = false;
      carIcon = true;
    }
    else if(name == "bus" && !busIcon) {
      carIcon = bikeIcon = walkIcon = false;
      busIcon = true;
    }
    else if(name == "bike" && !bikeIcon) {
      carIcon = busIcon = walkIcon = false;
      bikeIcon = true;
    }
    else if(name == "walk" && !walkIcon) {
      carIcon = busIcon = bikeIcon = false;
      walkIcon = true;
    }
    notifyListeners();
  }
}