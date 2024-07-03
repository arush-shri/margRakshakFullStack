import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart';

import '../presenter/HomePresenter.dart';

class PlaceInformation extends StatefulWidget {
  final Map<String, dynamic> locationDetails;
  const PlaceInformation({super.key, required this.locationDetails});

  @override
  State<PlaceInformation> createState() => _PlaceInformationState();
}

class _PlaceInformationState extends State<PlaceInformation> {

  final homePresenter = HomePresenter();
  List<Response>? imageResponseList;

  @override
  void initState() {
    super.initState();
    imageResponseList = [];
    for (Map<String, dynamic> item in widget.locationDetails["photos"]){
      getImage(item["photo_reference"]);
    }
  }
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(450,800),
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: Container(
                  height: double.infinity,
                  color: const Color(0xFF00233F),
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 80.h,),
                        Center(
                          child: Text(widget.locationDetails['name'],
                            style: TextStyle(fontSize: 32.sp, fontFamily: "Lexend",
                                fontWeight: FontWeight.w500, color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: 20.h,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width: 10.w,),
                            Text("RATING: ${widget.locationDetails["rating"].toString()}",
                              style: TextStyle(fontSize: 21.sp, fontFamily: "Lexend",
                                  fontWeight: FontWeight.w400, color: Colors.white),                             //total
                            ),
                            SizedBox(width: 4.w,),
                            const Icon(Icons.star, color: Color(0xFFFFD700),),
                            SizedBox(width: 8.w,),
                            Text("(${widget.locationDetails["user_ratings_total"].toString()})",
                              style: TextStyle(fontSize: 20.sp, fontFamily: "Lexend",
                                  fontWeight: FontWeight.w500, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h,),
                        Divider(
                          thickness: 2.h,
                          color: const Color(0xFFA8A8A8),
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 80.w,
                              height: 50.h,
                              child: Icon(Icons.location_on, color: Colors.indigoAccent,
                                  size: 40.h ,),
                            ),
                            Expanded(
                                child: Text("Address: ${widget.locationDetails["formatted_address"]}",
                                  style: TextStyle(fontSize: 21.sp, fontFamily: "Lexend",
                                      fontWeight: FontWeight.w400, color: Colors.white),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                )
                            ),
                          ],
                        ),
                        Divider(
                          thickness: 2.h,
                          color: const Color(0xFFA8A8A8),
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 80.w,
                              height: 50.h,
                              child: Icon(Icons.phone, color: Colors.indigoAccent,
                                  size: 34.h ,),
                            ),
                            Expanded(
                                child: Text("${widget.locationDetails["formatted_phone_number"]}",
                                  style: TextStyle(fontSize: 21.sp, fontFamily: "Lexend",
                                      fontWeight: FontWeight.w400, color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ),
                          ],
                        ),
                        Divider(
                          thickness: 2.h,
                          color: const Color(0xFFA8A8A8),
                        ),
                        widget.locationDetails.containsKey("opening_hours") && widget.locationDetails["opening_hours"]["open_now"]!=null?
                        Row(
                          children: [
                            SizedBox(
                              width: 80.w,
                              height: 50.h,
                              child: Icon(Icons.access_time_filled, color: Colors.indigoAccent,
                                  size: 34.h ,),
                            ),
                            Expanded(
                                child: Row(
                                  children: [
                                    Text( widget.locationDetails["opening_hours"]["open_now"]? "Open:": "Close:",
                                      style: TextStyle(fontSize: 21.sp, fontFamily: "Lexend",
                                          fontWeight: FontWeight.w400,
                                          color: widget.locationDetails["opening_hours"]["open_now"]? const Color(0xFF1FFF12) : Colors.red),
                                    ),
                                    Text( " ${getPlaceTiming()}",
                                      style: TextStyle(fontSize: 20.sp, fontFamily: "Lexend",
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white),
                                    ),
                                  ],
                                )
                            ),
                            PopupMenuButton(
                              position: PopupMenuPosition.under,
                              icon: Icon(Icons.keyboard_arrow_down_rounded, size: 34.h, color: Colors.orange,),
                              color: const Color(0xFF7116AF),
                              itemBuilder: (context) {
                                return List.generate(
                                    widget.locationDetails["opening_hours"]["weekday_text"].length, (index) {
                                  return PopupMenuItem(
                                      child: Text(widget.locationDetails["opening_hours"]["weekday_text"][index],
                                        style: TextStyle(fontSize: 21.sp, fontFamily: "Lexend",
                                            fontWeight: FontWeight.w400, color: Colors.white),
                                        overflow: TextOverflow.ellipsis, // Adjust the font size as needed
                                      )
                                  );
                                }
                                );
                              },
                            )
                          ],
                        ) : const SizedBox(),
                        Divider(
                          thickness: 2.h,
                          color: const Color(0xFFA8A8A8),
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 80.w,
                              height: 70.h,
                              child: Icon(Icons.photo_sharp, color: Colors.indigoAccent,
                                  size: 36.h ,),
                            ),
                            Text("Photos:",
                              style: TextStyle(fontSize: 26.sp, fontFamily: "Lexend",
                                  fontWeight: FontWeight.w500, color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        imageResponseList!.length == (widget.locationDetails["photos"]).length?SizedBox(
                          height: 250.h,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: imageResponseList?.length,
                            itemBuilder: (context, index) {
                              return SizedBox(
                                child: Image.memory(Uint8List.fromList(imageResponseList![index].bodyBytes),
                                    fit: BoxFit.fill),
                              );
                            },
                          ),
                        ) : const Center(
                          child: SizedBox(
                            child: CircularProgressIndicator(
                              color: Color(0xFF135ED0),
                            ),
                          ),
                        ),
                        SizedBox(height: 6.h,),
                        Divider(
                          thickness: 2.h,
                          color: const Color(0xFFA8A8A8),
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 80.w,
                              height: 50.h,
                              child: Icon(Icons.reviews_outlined, color: Colors.indigoAccent,
                                size: 34.h ,),
                            ),
                            Expanded(
                              child: Text("REVIEWS: ",
                                style: TextStyle(fontSize: 21.sp, fontFamily: "Lexend",
                                    fontWeight: FontWeight.w400, color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        for(int index=0; index<widget.locationDetails["reviews"].length; index++) showReview(index),
                      ],
                    ),
                  ),
                ),
          ),
        );
      },
    );
  }

  Widget showReview(int index){
    return SizedBox(
      width: 450.w,
      height: 180.h,
      child: Column(
        children: [
          Divider(
            thickness: 2.h,
            color: const Color(0xFFA8A8A8),
          ),
          SizedBox(height: 6.h,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  height: 32.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(400.w),
                  ),
                  child: Image.network(widget.locationDetails["reviews"][index]["profile_photo_url"],
                    fit: BoxFit.fill,)
              ),
              SizedBox(width: 13.w,),
              Text(widget.locationDetails["reviews"][index]["author_name"],
                style: TextStyle(fontSize: 19.sp, fontFamily: "Lexend",
                    fontWeight: FontWeight.w400,
                    color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 10.h,),
          Row(
            children: [
              Text("RATING: ${widget.locationDetails["reviews"][index]["rating"]}",
                style: TextStyle(fontSize: 20.sp, fontFamily: "Lexend",
                    fontWeight: FontWeight.w400, color: Colors.white),
              ),
              SizedBox(width: 4.w,),
              const Icon(Icons.star, color: Color(0xFFFFD700),),
              SizedBox(width: 6.w,),
              Text("(${widget.locationDetails["reviews"][index]["relative_time_description"]})",
                style: TextStyle(fontSize: 19.sp, fontFamily: "Lexend",
                    fontWeight: FontWeight.w400, color: Colors.grey),
              ),
            ],
          ),
          Text("${widget.locationDetails["reviews"][index]["text"]}",
            style: TextStyle(fontSize: 21.sp, fontFamily: "Lexend",
                fontWeight: FontWeight.w400, color: Colors.white),
            overflow: TextOverflow.ellipsis,maxLines: 4,
          ),
        ],
      ),
    );
  }
  Future<void> getImage(String reference) async {
    final response = await homePresenter.getPlaceImage(reference);
    setState(() {
      imageResponseList?.add(response);
    });
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

    if(!widget.locationDetails["opening_hours"]["open_now"]){
      dayNum = (dayNum % (widget.locationDetails["opening_hours"]["periods"].length)) as int;
      final openingDate = widget.locationDetails["opening_hours"]["periods"][dayNum];
      return "Opens ${dayMap[openingDate["open"]["day"]]!} at ${_convertTime(openingDate["open"]["time"])}";
    }
    final openingDate = widget.locationDetails["opening_hours"]["periods"][dayNum-1];
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
