import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class OutdoorAnimation extends StatefulWidget {
  final String condition;
  const OutdoorAnimation({super.key, required this.condition});

  @override
  State<OutdoorAnimation> createState() => _OutdoorAnimationState();
}

class _OutdoorAnimationState extends State<OutdoorAnimation> {

  late String imageAsset;
  late String displayText;
  late BoxFit boxFitType;

  @override
  Widget build(BuildContext context) {
    if(widget.condition == "Rain" || widget.condition == "Drizzle") {
      imageAsset = "assets/gifs/rain_anim.gif";
      displayText = "It's probably raining outside\nPlease drive with caution";
      boxFitType = BoxFit.fill;
    }
    else if(widget.condition == "sunset"){
      imageAsset = "assets/gifs/sunset_anim.gif";
      displayText = "It must be getting dark outside\nPlease drive carefully";
      boxFitType = BoxFit.contain;
    }
    else if(widget.condition == "sunrise"){
      imageAsset = "assets/gifs/sunrise_anim.gif";
      displayText = "Good Morning Rider";
      boxFitType = BoxFit.contain;
    }
    else if(widget.condition == "Snow"){
      imageAsset = "assets/gifs/snow_anim.gif";
      displayText = "It's probably snowing outside\nPlease drive with caution";
      boxFitType = BoxFit.fill;
    }
    else if(widget.condition == "Thunderstorm"){
      imageAsset = "assets/gifs/thunder_anim.gif";
      displayText = "Thunderstorms alert\nPlease stay in house or car";
      boxFitType = BoxFit.fill;
    }
    return Stack(
      children: [
        Image.asset(
          imageAsset, fit: boxFitType,
          height: 800.h,
          width: 450.w,
        ),
        Positioned(
            top: 500.h,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                displayText,
                style: TextStyle(
                    fontSize: 28.sp,
                    fontFamily: "Lexend",
                    fontWeight: FontWeight.w500,
                    color: Colors.white
                ),
                textAlign: TextAlign.center,
              ),
            )
        )
      ],
    );
  }
}


