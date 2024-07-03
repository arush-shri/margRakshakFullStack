import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:marg_rakshak/components/static/validator.dart';
import 'package:marg_rakshak/presenter/AuthPresenter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:marg_rakshak/view/signup.dart';
import '../components/custom_widgets/custom_text_field.dart';
import 'home.dart';


class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final validator = Validator();
  double topHeight = 80.h;
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
                      padding: EdgeInsets.fromLTRB(5.w, 120.h, 5.w, 0.h),
                      child: Column(
                        children: <Widget>[
                          Text("Welcome to Marg Rakshak",
                            style: TextStyle(fontSize: 32.sp, fontFamily: "Lexend", fontWeight: FontWeight.w400),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            "Please log in to embark on a safe and secure journey with us.",
                            style: TextStyle(fontSize:24.sp, fontFamily: "Lexend", fontWeight: FontWeight.w400, color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: topHeight,),
                          CustomTextField(obscureText: false, hintText: "Enter username", controller: _usernameController,
                            validator: (String? value){
                              if (value == null || value.isEmpty) {
                                topHeight=70.h;
                                return 'Please enter your email address';
                              }
                              if(!validator.isEmailValid(value)){
                                topHeight=70.h;
                                return "Enter a valid email address";
                              }
                            },),
                          SizedBox(height: 25.h,),
                          CustomTextField(obscureText: true, hintText: "Enter password", controller: _passwordController,
                            validator: (String? value){
                              if (value == null || value.isEmpty) {
                                topHeight=50.h;
                                return 'Please enter your password';
                              }
                              if ( validator.isPasswordValid(value) ){
                                topHeight=50.h;
                                return "Password should be of length 8 or greater";
                              }
                            },),
                          SizedBox(height: 40.h,),
                          ElevatedButton(
                              onPressed: () async{
                                try{
                                  auth.signIn(mail: _usernameController.text, passwd: _passwordController.text)
                                      .then((status) {
                                    Navigator.pushReplacement(context,
                                        MaterialPageRoute(builder: (context) => const HomePage()));
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
                              child: Text("Sign In",
                                style: TextStyle(fontSize: 24.sp, fontFamily: "Lexend", fontWeight: FontWeight.w700, color: Colors.white),
                              )
                          ),
                          SizedBox(height: 40.h,),
                          SizedBox(
                            height: 170.h,
                            width: 350.w,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      height: 2.h,
                                      width: 82.w,
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            Color(0xFF646464),
                                          ],
                                          stops: [0.0, 0.9],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                      ),
                                    ),
                                    Text("Or continue with",
                                      style: TextStyle(fontSize: 19.sp, fontFamily: "Lexend", fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Container(
                                      height: 2.h,
                                      width: 82.w,
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            Color(0xFF646464),
                                          ],
                                          stops: [0.0, 0.9],
                                          begin: Alignment.centerRight,
                                          end: Alignment.centerLeft,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 35.h,),
                                GestureDetector(
                                  onTap: () async {
                                    try{
                                      auth.googleSignIn().then((status) {
                                        Navigator.pop(context);
                                        Navigator.pushReplacement(context,
                                            MaterialPageRoute(builder: (context) => const HomePage()));
                                      });
                                    }catch(e){print(e);}
                                  },
                                  child: Container(
                                    width: 110.w,
                                    height: 60.h,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(9),
                                        border: Border.all(color: Colors.white, width: 2)
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(5.h),
                                      child: Image.asset('assets/images/google_logo.png'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Not a member? ",
                                  style: TextStyle(
                                    fontSize: 19.sp,
                                    fontFamily: "Lexend", fontWeight: FontWeight.w400,
                                    color: Colors.black87,
                                  ),
                                ),
                                TextSpan(
                                  text: "SignUp",
                                  style: TextStyle(
                                    fontSize: 19.sp,
                                    fontFamily: "Lexend", fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0762EC),
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) => const RegistrationPage()));
                                    },
                                ),
                                TextSpan(
                                  text: " now",
                                  style: TextStyle(
                                    fontSize: 19.sp,
                                    fontFamily: "Lexend", fontWeight: FontWeight.w400,
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
