import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DangerAlert extends StatefulWidget {
  final String dangerType;
  const DangerAlert({super.key, required this.dangerType});

  @override
  State<DangerAlert> createState() => _DangerAlertState();
}

class _DangerAlertState extends State<DangerAlert> {

  late String imageAsset;
  late String displayText;

  @override
  Widget build(BuildContext context) {

    if(widget.dangerType == "AccidentArea"){
      imageAsset = "assets/images/accident_icon.png";
      displayText = "CAREFUL!!!\n Accident Prone Area Up Ahead";
    }
    if(widget.dangerType == "RailwayCross"){
      imageAsset = "assets/images/rail_icon.png";
      displayText = "CAREFUL!!!\n Railway Crossing Up Ahead";
    }
    if(widget.dangerType == "ForestArea"){
      imageAsset = "assets/images/forest_icon.png";
      displayText = "CAREFUL!!!\n Forest Area Beginning\n Look Out For Wild Animals";
    }
    if(widget.dangerType == "GhatRegion"){
      imageAsset = "assets/images/ghat_icon.png";
      displayText = "CAREFUL!!!\n Ghat Region Starting";
    }
    if(widget.dangerType == "UserPosition"){
      imageAsset = "assets/images/user_icon.png";
      displayText = "CAREFUL!!!\n Our Another User Is Ahead";
    }
    else{
      displayText = "CAREFUL!!!\n ${widget.dangerType} Up Ahead";
    }
    return SizedBox(
      height: 800.w,
      width: 450.w,
      child: Center(
        child: Column(
          children: [
            SizedBox(height: 200.h,),
            SizedBox(
              width: 350.w,
              height: 300.h,
              child: Image.asset(imageAsset, fit: BoxFit.fill,),
            ),
            SizedBox(height: 30.h,),
            Text( displayText,
              style: TextStyle(fontSize: 26.sp, fontFamily: "Lexend",
                  fontWeight: FontWeight.w400, color: Colors.white),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
