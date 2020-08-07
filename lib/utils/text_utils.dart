
import 'package:flutter/cupertino.dart';

class TextUtils {

  ///计算文字高度
  static double calcTextHeight({
    String text,
    BuildContext context,
    double fontSize,
    FontWeight fontWeight,
    double maxWidth,
    int maxLines
  }){

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
}