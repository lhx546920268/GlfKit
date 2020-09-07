
import 'package:GlfKit/utils/text_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

///大写的Y会导致时间多出一年

const String dateFormatYMdHms = "yyyy-MM-dd HH:mm:ss";

const String dateFormatYMdHm = "yyyy-MM-dd HH:mm";

const String dateFormatYMd = "yyyy-MM-dd";

class DateUtils {

  ///格式化时间戳
  static String formatTimeStamp(int timeStamp, String format){
    assert(format != null);

    if(timeStamp == null){
      timeStamp = 0;
    }

    var dateFormat = DateFormat(format);
    try {
      if(timeStamp.toString().length >= 13){
        return dateFormat.format(DateTime.fromMicrosecondsSinceEpoch(timeStamp));
      }else{
        return dateFormat.format(DateTime.fromMillisecondsSinceEpoch(timeStamp));
      }
    }catch(_){
      return null;
    }
  }

  ///获取时间戳
  static int timeStampFromTime(String time, String format){
    assert(format != null);

    DateTime dateTime;
    if(!TextUtils.isEmpty(time)){
      try{
        var dateFormat = DateFormat(format);
        dateTime = dateFormat.parse(time);
      }catch (_){

      }
    }

    if(dateTime != null){
      return dateTime.millisecondsSinceEpoch;
    }

    return 0;
  }

  ///转换时间格式
  static String convertTimeToFormat(String time, {String fromFormat = dateFormatYMdHms, @required String toFormat}){
    assert(fromFormat != null && toFormat != null);

    if(!TextUtils.isEmpty(time)){
      try {
        var dateFormat = DateFormat(fromFormat);
        var dateTime = dateFormat.parse(time);
        if(dateTime != null){
          dateFormat = DateFormat(toFormat);
          return dateFormat.format(dateTime);
        }
      }catch(_){

      }
    }

    return time;
  }
}