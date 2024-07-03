import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../presenter/ServerPresenter.dart';

class ContributionRow extends StatefulWidget {
  const ContributionRow({super.key, required this.screenWidth, required this.moving});
  final double screenWidth;
  final bool moving;

  @override
  State<ContributionRow> createState() => _ContributionRowState();
}

class _ContributionRowState extends State<ContributionRow> {

  final _serverPresenter = ServerPresenter();
  String? otherName;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: widget.moving? 450.w : 400.w
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            rowItem("assets/images/accident_icon.png", "Accident\nProne", widget.screenWidth, () {
              _serverPresenter.makeContribution("AccidentArea", otherName);
            }),
            rowItem("assets/images/rail_icon.png", "Railway\nCrossing", widget.screenWidth, () {
              _serverPresenter.makeContribution("RailwayCross", otherName);
            }),
            rowItem("assets/images/forest_icon.png", "Forest\nArea", widget.screenWidth, () {
              _serverPresenter.makeContribution("ForestArea", otherName);
            }),
            rowItem("assets/images/ghat_icon.png", "Ghat\nRoad", widget.screenWidth, () {
              _serverPresenter.makeContribution("GhatRegion", otherName);
            }),
            rowItem("assets/images/other_icon.png", "Other\nRegion", widget.screenWidth, () async {
              Fluttertoast.showToast(
                  msg: "Please speak name of the area",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 2,
                  backgroundColor: const Color(0xFF46009A),
                  textColor: Colors.white,
                  fontSize: 16.0
              );
              stt.SpeechToText speech = stt.SpeechToText();
              bool available = await speech.initialize();
              if ( available ) {
                speech.listen(
                    listenFor: const Duration(seconds: 5),
                    partialResults: false,
                    listenMode: stt.ListenMode.confirmation,
                    onResult:  (result){
                      setState(() {
                        otherName = result.recognizedWords;
                      });
                      _serverPresenter.makeContribution("OtherRegion", otherName);
                    });
              }
              else {
                print("The user has denied the use of speech recognition.");
              }
              speech.stop();
            }),
          ],
        ),
      ),
    );
  }
}

Widget rowItem(String imagePath, String text, double screenWidth, VoidCallback callback){
  return GestureDetector(
      onTap: callback,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 2.h,),
          SizedBox(
              width: screenWidth,
              child: Image.asset(imagePath, fit: BoxFit.fill,)
          ),
          Text(text,
            style: TextStyle(fontSize: screenWidth==0.w? 0.sp : 18.sp,
                fontFamily: "Lexend", fontWeight: FontWeight.w400, color: Colors.white ),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
}