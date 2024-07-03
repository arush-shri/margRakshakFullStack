import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/custom_widgets/check_mark.dart';

class RoadSideHelpScreen extends StatefulWidget {
  const RoadSideHelpScreen({super.key});

  @override
  State<RoadSideHelpScreen> createState() => _RoadSideHelpScreenState();
}

class _RoadSideHelpScreenState extends State<RoadSideHelpScreen> {

  final TextEditingController userName = TextEditingController();
  final TextEditingController phoneNum = TextEditingController();
  final TextEditingController vehicleDetails = TextEditingController();
  final TextEditingController vehicleNum = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(450, 800),
      builder: (context, child){
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            resizeToAvoidBottomInset: false,
            body: Container(
              width: 450.w,
              height: 800.h,
              color: const Color(0xFF00233F),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 80.h, left: 20.w,),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.car_crash_outlined, size: 120.w,
                          color: Colors.blue,),
                        SizedBox(width: 20.w,),
                        Expanded(
                          child: Text("Roadside Help Assist",
                              style: TextStyle(fontSize: 38.sp, fontFamily: "Lexend",
                                  fontWeight: FontWeight.w500, color: Colors.white,),
                            overflow: TextOverflow.visible,
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 50.w, vertical: 40.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        textInputField("Your Name", userName),
                        SizedBox(height: 40.h,),
                        textInputField("Phone Number", phoneNum),
                        SizedBox(height: 40.h,),
                        textInputField("Vehicle Details", vehicleDetails),
                        SizedBox(height: 40.h,),
                        textInputField("Vehicle Number", vehicleNum),
                      ],
                    )
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                      child: Text("We’ll be sharing your current location and details with authorities to help them locate you",
                        style: TextStyle(fontSize: 22.sp, fontFamily: "Lexend",
                            fontWeight: FontWeight.w400, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                  ),
                  SizedBox(height: 20.h,),
                  ElevatedButton(
                      onPressed: ()=>{
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) => const CheckMark(checkMark: true))
                        )
                      },
                      style: ButtonStyle(
                          fixedSize: MaterialStatePropertyAll(Size(200.w, 40.h))
                      ),
                      child: Text("GET HELP",
                        style: TextStyle(fontSize: 20.sp, fontFamily: "Lexend",
                            fontWeight: FontWeight.w700, color: Colors.white),
                      )
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget textInputField(String hintText, TextEditingController controller){
    return TextFormField(
      controller: controller,
      style: TextStyle(fontSize: 22.sp, fontFamily: "Lexend",
          fontWeight: FontWeight.w400, color: Colors.white),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(10.w),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.deepPurpleAccent)),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.deepPurpleAccent)),
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 18.sp, fontFamily: GoogleFonts.poppins().fontFamily,
            color: Colors.grey),
      ),
    );
  }
}
