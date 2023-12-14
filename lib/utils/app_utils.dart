
import 'package:GlfKit/utils/text_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AppUtils {

  ///获取设备唯一标识符
  static Future<String> getUuid(BuildContext context) async {
    const key = "com.glfkit.uuid";
    final prefs = await SharedPreferences.getInstance();
    var uuid = prefs.getString(key);
    if (TextUtils.isEmpty(uuid)) {
      uuid = Uuid().toString();
      prefs.setString(key, uuid);
    }
    return uuid!;
  }

  ///关闭键盘
  static void unFocus(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  //获取状态栏高度
  static double getStatusBarHeight(BuildContext context) {
    return MediaQuery.of(context).viewPadding.top;
  }
}