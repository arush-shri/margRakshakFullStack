import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CheckMark extends StatelessWidget {
  final bool checkMark;
  const CheckMark({super.key, required this.checkMark});

  @override
  Widget build(BuildContext context) {
    final String thank = checkMark? "Help will soon arrive" : "Thank you for reporting";
    Future.delayed(const Duration(milliseconds: 3200), () {
      Navigator.pop(context);
    });
    return ScreenUtilInit(
      designSize: const Size(450, 800),
      builder: (context, child){
        return Scaffold(
          body: Container(
            width: 450.w,
            height: 800.h,
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              children: [
                SizedBox(height: 200.h,),
                checkMark? Text("Local Authorities \nhave been informed",
                  style: TextStyle(fontSize: 40.sp, fontFamily: "Lexend",
                      fontWeight: FontWeight.w500, color: Colors.black), textAlign: TextAlign.center,
                ) : const SizedBox(),
                SizedBox(height: 50.h,),
                SizedBox(
                  width: 450.w,
                  height: 250.h,
                  child: Image.asset("assets/gifs/check.gif", fit: BoxFit.contain,),
                ),
                SizedBox(height: 50.h,),
                Text(thank,
                  style: TextStyle(fontSize: 40.sp, fontFamily: "Lexend",
                      fontWeight: FontWeight.w500, color: Colors.black), textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

