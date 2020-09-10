

import 'package:GlfKit/theme/app_theme.dart';
import 'package:GlfKit/theme/color_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class NavigationBar extends StatefulWidget implements ObstructingPreferredSizeWidget{

  final NavigationBarController controller;

  NavigationBar({
    Key key,
    NavigationBarController controller,
  }): this.controller = controller ?? NavigationBarController(), super(key: key);

  @override
  bool shouldFullyObstruct(BuildContext context) {
    return true;
  }

  @override
  State<StatefulWidget> createState() {
    return _NavigationBarState();
  }

  @override
  Size get preferredSize {
    return Size.fromHeight(AppTheme.navigationBarHeight);
  }
}

///导航栏控制器
class NavigationBarController extends ChangeNotifier {

  SystemUiOverlayStyle get statusBarStyle => _statusBarStyle ?? AppTheme.statusBarStyle;
  set statusBarStyle(SystemUiOverlayStyle style){
    if(_statusBarStyle != style){
      _statusBarStyle = style;
      notifyListeners();
    }
  }
  SystemUiOverlayStyle _statusBarStyle;

  ///背景颜色
  Color get backgroundColor => _backgroundColor ?? ColorTheme.navigationBarBackgroundColor;
  set backgroundColor(Color color){
    if(color != _backgroundColor){
      _backgroundColor = color;
      notifyListeners();
    }
  }
  Color _backgroundColor;

  ///阴影颜色
  Color get shadowColor => _shadowColor ?? ColorTheme.navigationBarShadowColor;
  set shadowColor(Color color){
    if(color != _shadowColor){
      _shadowColor = color;
      notifyListeners();
    }
  }
  Color _shadowColor;

  ///间距
  double get padding => _padding ?? 15;
  set padding(double padding){
    if(padding != _padding){
      _padding = padding;
      notifyListeners();
    }
  }
  double _padding = 12;

  ///标题 样式
  TextStyle get titleStyle => _titleStyle ?? AppTheme.navigationBarTitleStyle;
  set titleStyle(TextStyle style){
    if(_titleStyle != titleStyle){
      _titleStyle = titleStyle;
      notifyListeners();
    }
  }
  TextStyle _titleStyle;

  ///标题
  String get title => _title;
  set title(String title){
    if(_title != title){
      _title = title;
      notifyListeners();
    }
  }
  String _title;

  ///中间组件
  Widget get middle {
    if(_middle != null)
      return _middle;

    if(title != null){
      _middle = Text(title, style: titleStyle,);
    }

    return _middle;
  }
  set middle(Widget widget){
    if(_middle != widget){
      _middle = widget;
      notifyListeners();
    }
  }
  Widget _middle;

  ///左边组件 优先使用
  Widget get leading {
    if(_leading != null)
      return _leading;

    if(leadingItem != null){
      return leadingItem.getWidget(padding);
    }

    return _leading;
  }
  set leading(Widget widget){
    if(_leading != widget){
      _leading = widget;
      notifyListeners();
    }
  }
  Widget _leading;

  ///左边按钮
  NavigationBarItem get leadingItem {
    if(_leadingItem != null)
      return _leadingItem;

    return _leadingItem;
  }
  set leadingItem(NavigationBarItem item){
    if(_leadingItem != item){
      _leadingItem = item;
      notifyListeners();
    }
  }
  NavigationBarItem _leadingItem;

  ///右边组件 优先使用
  Widget get trailing {
    if(_trailing != null)
      return _trailing;

    if(trailingItem != null){
      return trailingItem.getWidget(padding);
    }

    return _trailing;
  }
  set trailing(Widget widget){
    if(_trailing != widget){
      _trailing = widget;
      notifyListeners();
    }
  }
  Widget _trailing;

  ///左边按钮
  NavigationBarItem get trailingItem {
    if(_trailingItem != null)
      return _trailingItem;

    return _trailingItem;
  }
  set trailingItem(NavigationBarItem item){
    if(_trailingItem != item){
      _trailingItem = item;
      notifyListeners();
    }
  }
  NavigationBarItem _trailingItem;

  NavigationBarController({
    SystemUiOverlayStyle statusBarStyle,
    Color backgroundColor,
    Color shadowColor,
    double padding,
    TextStyle titleStyle,
    String title,
    Widget middle,
    Widget leading,
    NavigationBarItem leadingItem,
    Widget trailing,
    NavigationBarItem trailingItem
  }) {
    _statusBarStyle = statusBarStyle;
    _backgroundColor = backgroundColor;
    _shadowColor = shadowColor;
    _padding = padding;
    _titleStyle = titleStyle;
    _title = title;
    _middle = middle;
    _leading = leading;
    _leadingItem = leadingItem;
    _trailing = trailing;
    _trailingItem = trailingItem;
  }
}

///导航栏按钮
class NavigationBarItem {

  final String title;
  final Widget child;
  final VoidCallback onPressed;

  NavigationBarItem({
    this.title,
    this.child,
    this.onPressed,
  }){
   assert(title != null || child != null);
  }

  Widget getWidget(double padding){
    return CupertinoButton(
      padding: EdgeInsets.only(left: padding, right: padding),
      child: child ?? Text(title, style: AppTheme.navigationBarItemStyle,),
      disabledColor: Colors.transparent,
      borderRadius: null,
      onPressed: onPressed,
      minSize: 0,
    );
  }
}

class _NavigationBarState extends State<NavigationBar> {

  @override
  Widget build(BuildContext context) {

    List<Widget> children = [];
    var leading = widget.controller.leading;
    var middle = widget.controller.middle;
    var trailing = widget.controller.trailing;

    var route = ModalRoute.of(context);
    if(leading == null && route != null){
      if(route.canPop){
        leading =  NavigationBarItem(
            child: Icon(
                CupertinoIcons.back,
                color: ColorTheme.navigationBarTintColor,
                size: 30
            ),
            onPressed: () {
              Navigator.of(context).pop();
            }
        ).getWidget(5);
      }
    }

    if(leading != null){
      children.add(leading);
    }

    if(middle != null){
      if(leading == null || trailing == null) {
        middle = Padding(
          padding: EdgeInsets.only(left: leading == null ? widget.controller.padding : 0, right: trailing == null ? widget.controller.padding : 0),
          child: middle,
        );
      }
      children.add(Flexible(
        fit: FlexFit.loose,
        child: middle,
      ));
    }

    if(trailing != null){
      children.add(trailing);
    }

    Border border = widget.controller.shadowColor != null ? Border(bottom: BorderSide(color: widget.controller.shadowColor, width: 0.5)) : null;

    var top = MediaQuery.of(context).padding.top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: widget.controller.statusBarStyle,
        sized: true,
        child: Container(
          decoration: BoxDecoration(color: widget.controller.backgroundColor, border: border),
          height: top + AppTheme.navigationBarHeight,
          padding: EdgeInsets.only(top: top),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: children,
          ),
        ));
  }
}