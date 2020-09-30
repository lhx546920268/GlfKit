
import 'package:flutter/cupertino.dart';
import 'package:GlfKit/base/collection/collection_utils.dart' as collection_utils;

class TextUtils {

  ///计算文字高度
  static double calcTextHeight(String text,
      BuildContext context,
      TextStyle style, {
        double maxWidth = double.infinity,
        int maxLines = 1,
      }) {
    
    assert(style != null);
    TextPainter painter = TextPainter(
      //AUTO：华为手机如果不指定locale的时候，该方法算出来的文字高度是比系统计算偏小的。
        locale: Localizations.localeOf(context, nullOk: true),
        maxLines: maxLines,
        textDirection: TextDirection.ltr,
        text: TextSpan(
            text: text,
            style: style
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

  ///给url添加参数
  static String addParams(String url, String params) {
    assert(params != null);
    if(TextUtils.isEmpty(url))
      return url;

    var uri = Uri.parse(url);
    if(uri == null)
      return url;

    if(uri.fragment != null && uri.fragment.contains('?')){
      uri = uri.replace(fragment: '${uri.fragment}&$params');
    }else{
      if(TextUtils.isEmpty(uri.query)){
        uri = uri.replace(query: params);
      }else{
        uri = uri.replace(query: '${uri.query}&$params');
      }
    }
    return uri.toString();
  }

  static String getQueryValue(String url, String key){
    assert(key != null);
    if(TextUtils.isEmpty(url))
      return null;

    var uri = Uri.parse(url);
    if(uri == null)
      return null;

    String value;
    if(uri.queryParameters != null){
      value = uri.queryParameters[key];
    }

    //有些参数可能在fragment那里
    var fragment = uri.fragment;
    if(value == null && !TextUtils.isEmpty(fragment)){
      int index = fragment.lastIndexOf('?');

      if(index != -1){
        var query = fragment.substring(index + 1);

        if(!TextUtils.isEmpty(query)){
          var params = query.split('&');

          if(!collection_utils.isEmpty(params)){
            for(var str in params){
              var list = str.split('=');
              if(list.length == 2){
                if(list[0] == key){
                  value = list[1];
                  break;
                }
              }
            }
          }
        }
      }
    }
    return value;
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