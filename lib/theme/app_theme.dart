
import 'package:GlfKit/theme/color_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {

  ///导航栏高度
  static double navigationBarHeight = 44;

  ///分割线大小
  static double dividerHeight = 0.5;

  ///导航栏标题样式
  static TextStyle navigationBarTitleStyle = TextStyle(fontSize: 18, color: ColorTheme.themeTintColor, fontWeight: FontWeight.normal);

  ///导航栏按钮样式
  static TextStyle navigationBarItemStyle = TextStyle(fontSize: 14, color: ColorTheme.themeTintColor, fontWeight: FontWeight.normal);

  ///状态栏样式
  static SystemUiOverlayStyle statusBarStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light);
}