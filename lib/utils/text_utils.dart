import 'dart:io';

import 'package:flutter/cupertino.dart';

class TextUtils {

  ///计算文字高度
  static double calcTextHeight(String text,
      BuildContext context,
      double fontSize, {
        FontWeight fontWeight,
        double maxWidth,
        int maxLines
      }) {
    TextPainter painter = TextPainter(
      //AUTO：华为手机如果不指定locale的时候，该方法算出来的文字高度是比系统计算偏小的。
        locale: Localizations.localeOf(context, nullOk: true),
        maxLines: maxLines,
        textDirection: TextDirection.ltr,
        text: TextSpan(
            text: text,
            style: TextStyle(
              fontWeight: fontWeight,
              fontSize: fontSize,
            )
        ));
    painter.layout(maxWidth: maxWidth);
    //文字的宽度:painter.width
    return painter.height;
  }

  ///判断是否为空
  static bool isEmpty(String str, {bool replaceSpace = true}) {
    if (str == null || str is! String || str.isEmpty) return true;
    if (replaceSpace && str
        .replaceAll(RegExp('\s'), '')
        .isEmpty) return true;

    return false;
  }
}

extension StringUtils on String {

  int get intValue {
    var value = int.tryParse(this);
    return value == null ? 0 : value;
  }

  double get doubleValue {
    var value = double.tryParse(this);
    return value == null ? 0 : value;
  }

  bool get boolValue {
    var lower = toLowerCase();
    if (lower == 'true' || lower == 'yes') {
      return true;
    } else if (lower == 'false' || lower == 'no') {
      return false;
    } else {
      int value = this.intValue;
      return value > 0;
    }
  }
}