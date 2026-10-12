import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

TextStyle getTextStyle({
  double? fontSize,
  FontWeight? fontWeight,
  double? lineHeight,
  TextAlign? textAlign,
  Color? color,
}) {
  return TextStyle(
    fontFamily: 'Lato',
    fontSize: (fontSize ?? 14.0).sp,
    fontWeight: fontWeight ?? FontWeight.w400,
    height: lineHeight != null && fontSize != null
        ? lineHeight / fontSize
        : 21.0 / 14.0,
    color: color ?? Colors.black,
  );
}
