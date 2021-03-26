
import 'package:GlfKit/utils/text_utils.dart';
import 'package:intl/intl.dart';

///大写的Y会导致时间多出一年

const String dateFormatYMdHms = "yyyy-MM-dd HH:mm:ss";

const String dateFormatYMdHm = "yyyy-MM-dd HH:mm";

const String dateFormatYMd = "yyyy-MM-dd";

class DateUtils {

  ///格式化时间戳
  static String? formatTimeStamp(int? timeStamp, String format){
    if(timeStamp == null){
      timeStamp = 0;
    }
    
    try {
      var dateFormat = DateFormat(format);
      if(timeStamp.toString().length >= 13){
        return dateFormat.format(DateTime.fromMicrosecondsSinceEpoch(timeStamp));
      }else{
        return dateFormat.format(DateTime.fromMillisecondsSinceEpoch(timeStamp));
      }
    }catch(_){
      return null;
    }
  }
  
  ///格式化dart时间对象
  static String? formatDateTime(DateTime dateTime, {String fromFormat = dateFormatYMdHms}) {
    try {
      var dateFormat = DateFormat(fromFormat);
      return dateFormat.format(dateTime);
    }catch(_){

    }
    
    return null;
  }

  ///获取时间戳
  static int timeStampFromTime(String time, String format){
    DateTime? dateTime;
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
  static String convertTimeToFormat(String time, {String fromFormat = dateFormatYMdHms, required String toFormat}){

    if(!TextUtils.isEmpty(time)){
      try {
        var dateFormat = DateFormat(fromFormat);
        var dateTime = dateFormat.parse(time);
        dateFormat = DateFormat(toFormat);
        return dateFormat.format(dateTime);
      }catch(_){

      }
    }

    return time;
  }
  
  ///获取dart 时间对象
  static DateTime? dateTimeFromTme(String time, {String fromFormat = dateFormatYMdHms}){
    if(!TextUtils.isEmpty(time)){
      try {
        var dateFormat = DateFormat(fromFormat);
        return dateFormat.parse(time);
      }catch(_){

      }
    }
    return null;
  }
}