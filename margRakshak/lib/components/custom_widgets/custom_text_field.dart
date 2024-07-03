import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  const CustomTextField({super.key, required this.obscureText, required this.hintText,
    required this.controller, required this.validator});

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25.w),
      child: TextFormField(
        controller: widget.controller,
        decoration: InputDecoration(
          fillColor: Colors.white30,
            filled: true,
            hintText: widget.hintText,
            hintStyle: TextStyle(fontSize: 16.sp, fontFamily: GoogleFonts.poppins().fontFamily,
                color: Colors.black),
            isDense: true,
            contentPadding: EdgeInsets.fromLTRB(16.w, 32.h, 0, 0),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
            )
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        obscureText: widget.obscureText,
        validator: widget.validator,
      ),
    );
  }
}
