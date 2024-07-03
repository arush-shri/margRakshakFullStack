import 'dart:ui';

import 'package:flutter/material.dart';

class RouteAnimator extends CustomPainter{
  final double progress;

  RouteAnimator({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {

    final paint = Paint()
        ..color = Colors.blue
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round;
    final srcPaint = Paint()
      ..color = const Color(0xFF1DD22F)
      ..style = PaintingStyle.fill;
    final destPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width*0.12, size.height*0.75), 14, srcPaint);
    canvas.drawCircle(Offset(size.width*0.9, size.height*0.4), 14, destPaint);

    if(progress<=0.2){
      var x = progress*5;
      lineDrawer(canvas, paint, Offset(size.width*0.16, size.height*0.75),
          Offset(((size.width*0.20*x) + (size.width*0.16)), size.height*0.75));
    }
    if(progress>0.2){
      lineDrawer(canvas, paint, Offset(size.width*0.16, size.height*0.75),
          Offset(size.width*0.355, size.height*0.75));
    }

    if(progress>=0.2 && progress<=0.4){
      var x = (progress - 0.2) * 5.0;
      lineDrawer(canvas, paint, Offset(size.width*0.355, size.height*0.75),
          Offset(size.width*0.355, ((size.height*0.75) - (size.height*0.15*x))));
    }
    if(progress>0.4){
      lineDrawer(canvas, paint, Offset(size.width*0.355, size.height*0.75),
          Offset(size.width*0.355, size.height*0.6));
    }

    if(progress>=0.4 && progress<=0.6){
      var x = (progress - 0.4) * 5.0;
      lineDrawer(canvas, paint, Offset(size.width*0.355, size.height*0.6),
          Offset(((size.width*0.225*x) + (size.width*0.355)), size.height*0.6));
    }
    if(progress>0.6){
      lineDrawer(canvas, paint, Offset(size.width*0.355, size.height*0.6),
          Offset(size.width*0.58, size.height*0.6));
    }

    if(progress>=0.6 && progress<=0.8){
      var x = (progress - 0.6) * 5.0;
      lineDrawer(canvas, paint, Offset(size.width*0.58, size.height*0.6),
          Offset(size.width*0.58, ((size.height*0.6) - (size.height*0.2*x))));
    }
    if(progress>0.8){
      lineDrawer(canvas, paint, Offset(size.width*0.58, size.height*0.6),
          Offset(size.width*0.58, size.height*0.4));
    }

    if(progress>=0.8 && progress<=1.0){
      var x = (progress - 0.8) * 5.0;
      lineDrawer(canvas, paint, Offset(size.width*0.58, size.height*0.4),
          Offset(((size.width*0.30*x) + (size.width*0.58)), size.height*0.4));
    }
    if(progress>1.0){
      lineDrawer(canvas, paint, Offset(size.width*0.58, size.height*0.4),
          Offset(size.width*0.86, size.height*0.4));
    }

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  void lineDrawer(Canvas canvas, Paint paint, Offset start, Offset end){
    canvas.drawLine(start, end, paint);
  }
}
