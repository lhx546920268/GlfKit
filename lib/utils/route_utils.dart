
import 'package:flutter/cupertino.dart';

class RouteUtils {

  static Future<T> push<T>(BuildContext context, Widget widget) {
    return Navigator.of(context).push(CupertinoPageRoute(builder: (_) => widget));
  }
}