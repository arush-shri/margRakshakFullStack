import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marg_rakshak/components/static/validator.dart';
import 'package:marg_rakshak/view/login.dart';
import '../components/custom_widgets/custom_text_field.dart';
import '../presenter/AuthPresenter.dart';
import 'home.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController rePasswordController = TextEditingController();
  final validator = Validator();
  final auth = AuthPresenter();

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(450,800),
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(useMaterial3: true),
            home: Scaffold(
              body: SingleChildScrollView(
                  child: Container(
                    width: 450.w,
                    height: 800.h,
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("assets/images/map_bg.png"),
                            fit: BoxFit.fill
                        )
                    ),
                    child: GlassContainer.frostedGlass(
                      width: ScreenUtil().setWidth(450),
                      height: ScreenUtil().setHeight(800),
                      blur: 8,
                      padding: EdgeInsets.fromLTRB(5.w, 110.h, 5.w, 0.h),
                      child: Column(
                        children: <Widget>[
                          Text("Hello there!",
                            style: TextStyle(fontSize: 38.sp, fontFamily: "Lexend", fontWeight: FontWeight.w400),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            "Join Marg Rakshak and take control of your road safety!",
                            style: TextStyle(fontSize:24.sp, fontFamily: "Lexend", fontWeight: FontWeight.w400, color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 80.h,),
                          CustomTextField(controller: usernameController, hintText: "Enter username", obscureText: false,
                            validator: (String? value){
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email address';
                              }
                              if(!validator.isEmailValid(value)){
                                return "Enter a valid email address";
                              }
                            },),
                          SizedBox(height: 25.h,),
                          CustomTextField(controller: passwordController, hintText: "Enter password", obscureText: true,
                            validator: (String? value){
                              if (value == null || value.isEmpty) {
                                return 'Please enter you password';
                              }
                              if ( validator.isPasswordValid(value) ){
                                return "Password should be of length 8 or greater";
                              }
                            },),
                          SizedBox(height: 25.h,),
                          CustomTextField(controller: rePasswordController, hintText: "Re-enter password", obscureText: true,
                            validator: (String? value){
                              if (value == null || value.isEmpty) {
                                return 'Please enter you password';
                              }
                              if (rePasswordController.value != passwordController.value){
                                return "Passwords don't match";
                              }
                            },),
                          SizedBox(height: 33.h,),
                          ElevatedButton(
                              onPressed: (){
                                try{
                                  auth.mailSignUp(mail: usernameController.text, passwd: passwordController.text)
                                      .then((status) {
                                    Navigator.pop(context);
                                    Navigator.pushAndRemoveUntil(context,
                                        MaterialPageRoute(builder: (context) => const HomePage()),
                                            (Route route) => false);
                                  });
                                }catch(e){
                                  Fluttertoast.showToast(
                                      msg: e.toString(),
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 2,
                                      backgroundColor: Colors.amberAccent,
                                      textColor: Colors.white,
                                      fontSize: 16.0
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  fixedSize: Size(200.w, 50.h),
                                  backgroundColor: const Color(0xFFA52FF3),
                                  elevation: 8
                              ),
                              child: Text("Register",
                                style: TextStyle(fontSize: 26.sp, fontFamily: "Lexend",
                                    fontWeight: FontWeight.w700, color: Colors.white),
                              )
                          ),
                          SizedBox(height: 100.h,),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Already a member? ",
                                  style: TextStyle(
                                    fontSize: 19.sp,
                                    fontFamily: GoogleFonts.aBeeZee().fontFamily,
                                    color: Colors.black87,
                                  ),
                                ),
                                TextSpan(
                                  text: "SignIn",
                                  style: TextStyle(
                                    fontSize: 19.sp,
                                    fontFamily: GoogleFonts.aBeeZee().fontFamily,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0762EC),
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.pop(context);
                                    },
                                ),
                                TextSpan(
                                  text: " now",
                                  style: TextStyle(
                                    fontSize: 19.sp,
                                    fontFamily: GoogleFonts.aBeeZee().fontFamily,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
              ),
            ),
          );
        }
    );
  }
}