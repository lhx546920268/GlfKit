import 'package:GlfKit/theme/app_theme.dart';
import 'package:GlfKit/theme/color_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

///导航栏
class NavigationBar extends StatefulWidget
    implements ObstructingPreferredSizeWidget {

  final NavigationBarController controller;
  final VoidCallback goBack;

  NavigationBar({
    Key key,
    NavigationBarController controller,
    this.goBack,
  })
      : this.controller = controller ?? NavigationBarController(),
        super(key: key);

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

  SystemUiOverlayStyle get statusBarStyle =>
      _statusBarStyle ?? AppTheme.statusBarStyle;

  set statusBarStyle(SystemUiOverlayStyle style) {
    if (_statusBarStyle != style) {
      _statusBarStyle = style;
      notifyListeners();
    }
  }

  SystemUiOverlayStyle _statusBarStyle;

  ///背景颜色
  Color get backgroundColor =>
      _backgroundColor ?? ColorTheme.navigationBarBackgroundColor;

  set backgroundColor(Color color) {
    if (color != _backgroundColor) {
      _backgroundColor = color;
      notifyListeners();
    }
  }

  Color _backgroundColor;

  ///阴影颜色
  Color get shadowColor => _shadowColor ?? ColorTheme.navigationBarShadowColor;

  set shadowColor(Color color) {
    if (color != _shadowColor) {
      _shadowColor = color;
      notifyListeners();
    }
  }

  Color _shadowColor;

  ///间距
  double get padding => _padding ?? 15;

  set padding(double padding) {
    if (padding != _padding) {
      _padding = padding;
      notifyListeners();
    }
  }

  double _padding = 12;

  ///标题 样式
  TextStyle get titleStyle => _titleStyle ?? AppTheme.navigationBarTitleStyle;

  set titleStyle(TextStyle style) {
    if (_titleStyle != titleStyle) {
      _titleStyle = titleStyle;
      notifyListeners();
    }
  }

  TextStyle _titleStyle;

  ///标题
  String get title => _title;

  set title(String title) {
    if (_title != title) {
      _title = title;
      notifyListeners();
    }
  }

  String _title;

  ///中间组件
  Widget get middle {
    if (_middle != null)
      return _middle;

    if (title != null) {
      _middle = Text(title, style: titleStyle,);
    }

    return _middle;
  }

  set middle(Widget widget) {
    if (_middle != widget) {
      _middle = widget;
      notifyListeners();
    }
  }

  Widget _middle;

  ///左边组件 优先使用
  Widget get leading {
    if (_leading != null)
      return _leading;

    if (leadingItem != null) {
      return leadingItem.getWidget(padding);
    }

    return _leading;
  }

  set leading(Widget widget) {
    if (_leading != widget) {
      _leading = widget;
      notifyListeners();
    }
  }

  Widget _leading;

  ///左边按钮
  NavigationBarItem get leadingItem {
    if (_leadingItem != null)
      return _leadingItem;

    return _leadingItem;
  }

  set leadingItem(NavigationBarItem item) {
    if (_leadingItem != item) {
      _leadingItem = item;
      notifyListeners();
    }
  }

  NavigationBarItem _leadingItem;

  ///右边组件 优先使用
  Widget get trailing {
    if (_trailing != null)
      return _trailing;

    if (trailingItem != null) {
      return trailingItem.getWidget(padding);
    }

    return _trailing;
  }

  set trailing(Widget widget) {
    if (_trailing != widget) {
      _trailing = widget;
      notifyListeners();
    }
  }

  Widget _trailing;

  ///左边按钮
  NavigationBarItem get trailingItem {
    if (_trailingItem != null)
      return _trailingItem;

    return _trailingItem;
  }

  set trailingItem(NavigationBarItem item) {
    if (_trailingItem != item) {
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
  }) {
    assert(title != null || child != null);
  }

  Widget getWidget(double padding) {
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
    List<_Type> types = [];
    var leading = widget.controller.leading;
    var middle = widget.controller.middle;
    var trailing = widget.controller.trailing;

    var route = ModalRoute.of(context);
    if (leading == null && route != null) {
      if (route.canPop) {
        leading = NavigationBarItem(
            child: Icon(
                CupertinoIcons.back,
                color: ColorTheme.navigationBarTintColor,
                size: 30
            ),
            onPressed: () {
              if (widget.goBack != null) {
                widget.goBack();
              } else {
                Navigator.of(context).pop();
              }
            }
        ).getWidget(5);
      }
    }

    if (leading != null) {
      children.add(leading);
      types.add(_Type.leading);
    }

    if (middle != null) {
      if (leading == null || trailing == null) {
        middle = Padding(
          padding: EdgeInsets.only(
              left: leading == null ? widget.controller.padding : 0,
              right: trailing == null ? widget.controller.padding : 0),
          child: middle,
        );
      }
      children.add(middle);
      types.add(_Type.middle);
    }

    if (trailing != null) {
      children.add(trailing);
      types.add(_Type.trailing);
    }

    Border border = widget.controller.shadowColor != null
        ? Border(
        bottom: BorderSide(color: widget.controller.shadowColor, width: 0.5))
        : null;

    var top = MediaQuery
        .of(context)
        .padding
        .top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: widget.controller.statusBarStyle,
        sized: true,
        child: Container(
          decoration: BoxDecoration(
              color: widget.controller.backgroundColor, border: border),
          height: top + AppTheme.navigationBarHeight,
          padding: EdgeInsets.only(top: top),
          child: _NavigationContent(
            children: children,
            types: types,
            controller: widget.controller,
          ),
        ));
  }
}

enum _Type { leading, middle, trailing }

class _NavigationContent extends MultiChildRenderObjectWidget {

  final List<_Type> types;
  final NavigationBarController controller;

  _NavigationContent({
    Key key,
    List<Widget> children = const <Widget>[],
    this.types,
    this.controller,
  }) : super(
    key: key,
    children: children,
  );

  @override
  RenderBox createRenderObject(BuildContext context) {
    return _NavigationContentRenderBox(
        types: this.types,
        controller: controller
    );
  }

  @override
  void updateRenderObject(BuildContext context,
      covariant _NavigationContentRenderBox renderObject) {
    renderObject
      ..controller = controller
      ..types = types;
  }
}

class _NavigationContentParentData extends ContainerBoxParentData<RenderBox> {
}

class _NavigationContentRenderBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _NavigationContentParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox,
            _NavigationContentParentData> {

  List<_Type> _types;

  set types(List<_Type> types) {
    if (_types != types) {
      _types = types;
      markNeedsLayout();
    }
  }

  set controller(NavigationBarController controller) {
    if (_controller != controller) {
      _controller = controller;
      markNeedsLayout();
    }
  }

  NavigationBarController _controller;

  _NavigationContentRenderBox(
      {List<_Type> types, NavigationBarController controller})
      : _types = types,
        _controller = controller;

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! _NavigationContentParentData) {
      child.parentData = _NavigationContentParentData();
    }
  }

  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    final childConstraints = BoxConstraints(
        minWidth: 0,
        maxWidth: constraints.maxWidth,
        minHeight: 0,
        maxHeight: constraints.maxHeight);

    RenderBox child = firstChild;
    double height = constraints.maxHeight;
    double width = constraints.maxWidth;
    RenderBox leading;
    RenderBox trailing;
    RenderBox middle;

    int index = 0;
    double remainingSpacing = width;
    while(child != null){
      var type = _types[index];

      child.layout(childConstraints, parentUsesSize: true);
      if(type != _Type.middle){
        remainingSpacing -= child.size.width;
      }
      _NavigationContentParentData parentData = child.parentData;

      switch(type){
        case _Type.leading :
          leading = child;
          parentData.offset = Offset(0, (height - child.size.height) / 2);
          break;
        case _Type.middle :
          middle = child;
          break;
        case _Type.trailing :
          trailing = child;
          parentData.offset = Offset(width - child.size.width, (height - child.size.height) / 2);
          break;
      }
      index ++;
      child = parentData.nextSibling;
    }

    if(middle != null){
      middle.layout(BoxConstraints(
          minWidth: 0,
          maxWidth: remainingSpacing,
          minHeight: 0,
          maxHeight: height), parentUsesSize: true);
      _NavigationContentParentData parentData = middle.parentData;
      double dx = (width - middle.size.width) / 2;
      if(leading != null && dx < leading.size.width){
        dx = leading.size.width;
      }
      parentData.offset = Offset(dx, (height - middle.size.height) / 2);
    }

    size = Size(width, height);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}