
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///默认2秒后消失
const Duration _toastDefaultDuration = Duration(seconds: 2);

///默认文字样式
const TextStyle _toastDefaultTextStyle = TextStyle(color: Colors.white, fontSize: 14);

///默认圆角
const BorderRadius _toastDefaultBorderRadius = BorderRadius.all(Radius.circular(10));

///默认背景颜色
const Color _toastDefaultBackgroundColor = Color(0xb2000000);

///内边距
const EdgeInsets _toastDefaultPadding = EdgeInsets.fromLTRB(20, 15, 20, 15);

///外边距
const EdgeInsets _toastDefaultMargin = EdgeInsets.fromLTRB(20, 20, 20, 100);

///消失动画时长
const Duration _toastDismissDuration = Duration(milliseconds: 200);

///toast位置
enum ToastGravity{top, center, bottom}

class Toast{

  //全局的，用来防止出现多个toast
  static OverlayEntry _entry;

  static void showText(
      BuildContext context,
      String text, {
        TextStyle style = _toastDefaultTextStyle,
        Duration duration = _toastDefaultDuration,
        Color backgroundColor = _toastDefaultBackgroundColor,
        BorderRadius borderRadius = _toastDefaultBorderRadius,
        ToastGravity gravity = ToastGravity.bottom,
        EdgeInsets padding = _toastDefaultPadding,
        EdgeInsets margin = _toastDefaultMargin,
      }){

    assert(context != null);
    assert(text != null);

    Widget widget = Text(text, style: style,);
    showWidget(context, widget,
        duration: duration,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        gravity: gravity,
        padding: padding,
        margin: margin);
  }
  
  static void showWidget(
  BuildContext context,
      Widget widget, {
        Duration duration = _toastDefaultDuration,
        Color backgroundColor = _toastDefaultBackgroundColor,
        BorderRadius borderRadius = _toastDefaultBorderRadius,
        ToastGravity gravity = ToastGravity.bottom,
        EdgeInsets padding = _toastDefaultPadding,
        EdgeInsets margin = _toastDefaultMargin,
  }){

    assert(duration != null);
    assert(backgroundColor != null);
    assert(borderRadius != null);
    assert(gravity != null);
    assert(padding != null);
    assert(margin != null);

    //移除已存在的
    _entry?.remove();

    OverlayState overlayState = Overlay.of(context);
    _entry = OverlayEntry(builder: (BuildContext context){

      return _ToastWidget(
        child: widget,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        gravity: gravity,
        padding: padding,
        margin: margin,
        showDuration: duration,
        onDismiss: () {
          _entry?.remove();
          _entry = null;
        },
      );
    }, opaque: false);
    overlayState.insert(_entry);
  }
}

///toast 组件
class _ToastWidget extends StatefulWidget{

  final Widget child;
  final Color backgroundColor;
  final BorderRadius borderRadius;
  final ToastGravity gravity;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final VoidCallback onDismiss;
  final Duration showDuration;


  _ToastWidget({
    this.child,
    this.backgroundColor,
    this.borderRadius,
    this.gravity,
    this.padding,
    this.margin,
    this.onDismiss,
    this.showDuration
  });

  @override
  State<StatefulWidget> createState() {
    return _ToastState();
  }
}

class _ToastState extends State<_ToastWidget> {

  double _opacity = 1.0;
  Timer _timer;

  @override
  void initState() {
    _timer = Timer(widget.showDuration, () {
      if(mounted){
        setState(() {
          _opacity = 0;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    var child = Center(
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            color: widget.backgroundColor,
          ),
          child: widget.child,
        ),
      ),
    );

    return Positioned(
      left: widget.margin.left,
      right: widget.margin.right,
      top: widget.gravity == ToastGravity.top ? widget.margin.top : null,
      bottom: widget.gravity == ToastGravity.bottom ? widget.margin.bottom : null,
      child: AnimatedOpacity(
        opacity: _opacity,
        curve: Curves.easeOut,
        duration: _toastDismissDuration,
        onEnd: widget.onDismiss,
        child: child,
      ),
    );
  }
}
