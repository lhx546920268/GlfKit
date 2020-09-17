
import 'package:flutter/cupertino.dart';

class RouteUtils {

  static Future<T> push<T>(BuildContext context, Widget widget, {bool fullscreenDialog = false}) {
    return Navigator.of(context).push(CupertinoPageRoute(
        fullscreenDialog: fullscreenDialog,
        builder: (_) => widget)
    );
  }
}