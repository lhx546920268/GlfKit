
import 'package:flutter/cupertino.dart';

///tabBar 按钮数据
class TabItem {

  ///标题
  final Widget title;

  ///间距
  final double padding;

  ///图标
  final Widget icon;

  ///选中的图标
  final Widget activeIcon;

  ///角标
  Widget badgeValue;

  TabItem({
    @required this.title,
    double padding,
    @required this.icon,
    @required this.activeIcon,
    this.badgeValue
  }): this.padding = padding ?? 3, assert(title != null || icon != null || activeIcon != null);
}