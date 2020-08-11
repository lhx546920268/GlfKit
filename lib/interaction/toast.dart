
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
  static Timer _timer;
  static AnimationController _animationController;

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
    _timer?.cancel();
    _animationController?.dispose();

    //n秒后消失
    _timer = Timer(duration, (){
      dismiss();
    });

    OverlayState overlayState = Overlay.of(context);
    _animationController = AnimationController(duration: _toastDismissDuration, vsync: overlayState);
    _entry = OverlayEntry(builder: (BuildContext context){

      return _ToastWidget(
        child: widget,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        gravity: gravity,
        padding: padding,
        margin: margin,
        opacityAnimation: Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut)),
      );
    }, opaque: false);
    overlayState.insert(_entry);
  }

  static void dismiss() async{
    if(_entry != null){

      _animationController.forward();
      await Future.delayed(_toastDismissDuration);
      _entry?.remove();
      _animationController?.dispose();
      _animationController = null;
      _timer = null;
      _entry = null;
    }
  }
}

///toast 组件
class _ToastWidget extends StatelessWidget{

  final Widget child;
  final Color backgroundColor;
  final BorderRadius borderRadius;
  final ToastGravity gravity;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Animation<double> opacityAnimation;

  _ToastWidget({
    this.child,
    this.backgroundColor,
    this.borderRadius,
    this.gravity,
    this.padding,
    this.margin,
    this.opacityAnimation
  });

  @override
  Widget build(BuildContext context) {

    var widget = Center(
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: backgroundColor,
          ),
          child: child,
        ),
      ),
    );

    return Positioned(
      left: margin.left,
      right: margin.right,
      top: gravity == ToastGravity.top ? margin.top : null,
      bottom: gravity == ToastGravity.bottom ? margin.bottom : null,
      child: AnimatedBuilder(
        animation: opacityAnimation,
        child: widget,
        builder: (BuildContext context, Widget child){
          return Opacity(
            opacity: opacityAnimation.value,
            child: widget,
          );
        },
      ),
    );
  }
}
