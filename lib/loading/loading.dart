
import 'dart:async';

import 'package:GlfKit/loading/activity_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///默认文字样式
const TextStyle _kDefaultTextStyle = TextStyle(color: Colors.white, fontSize: 14);

///默认圆角
const BorderRadius _kDefaultBorderRadius = BorderRadius.all(Radius.circular(10));

///默认背景颜色
const Color _kDefaultBackgroundColor = Color(0xb2000000);

///消失动画时长
const Duration _kDefaultDismissDuration = Duration(milliseconds: 200);

///默认大小
const Size _kDefaultSize = Size(130, 120);

enum _Status {show, willShow, dismiss}

class Loading{

  //全局的
  static OverlayEntry _entry;
  static ValueNotifier<_Status> _statusNotifier;

  static void show(
      BuildContext context, {
        String text,
        TextStyle style,
        Duration delay,
        Size size,
        BorderRadius borderRadius,
        Color backgroundColor
      }){

    assert(context != null);

    Widget child = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ActivityIndicator(activeColor: Colors.white, radius: 16,),
        Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(text ?? '加载中...', style: style ?? _kDefaultTextStyle, overflow: TextOverflow.ellipsis, softWrap: true,),
        )
      ],
    );

    //移除已存在的
    _entry?.remove();

    _statusNotifier = ValueNotifier(delay != null ? _Status.willShow : _Status.show);

    OverlayState overlayState = Overlay.of(context);
    _entry = OverlayEntry(builder: (BuildContext context){

      return _LoadingWidget(
        child: child,
        backgroundColor: backgroundColor ?? _kDefaultBackgroundColor,
        borderRadius: borderRadius ?? _kDefaultBorderRadius,
        delay: delay,
        onDismiss: _onDismiss,
        statusNotifier: _statusNotifier,
        size: size ?? _kDefaultSize,
      );
    }, opaque: false);
    overlayState.insert(_entry);
  }

  static void dismiss({bool animate = true}) {
    if(_statusNotifier != null){
      if(_statusNotifier.value == _Status.willShow || !animate){
        _onDismiss();
      }else{
        _statusNotifier.value = _Status.dismiss;
      }
    }
  }

  static void _onDismiss(){
    _entry?.remove();
    _entry = null;
  }
}

///loading 组件
class _LoadingWidget extends StatefulWidget{

  final Widget child;
  final Color backgroundColor;
  final BorderRadius borderRadius;
  final ValueNotifier<_Status> statusNotifier;
  final Duration delay;
  final VoidCallback onDismiss;
  final Size size;

  _LoadingWidget({
    this.child,
    this.backgroundColor,
    this.borderRadius,
    this.statusNotifier,
    this.delay,
    this.onDismiss,
    this.size,
  });

  @override
  State<StatefulWidget> createState() {
    return _LoadingWidgetState();
  }
}

class _LoadingWidgetState extends State<_LoadingWidget> {

  double _opacity = 1.0;
  Timer _timer;

  @override
  void initState() {
    if(widget.delay != null){
      _timer = Timer(widget.delay, () {
        widget.statusNotifier?.value = _Status.show;
      });
    }
    widget.statusNotifier?.addListener(_onStatusChange);
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.statusNotifier?.removeListener(_onStatusChange);
    super.dispose();
  }

  void _onStatusChange() {
    switch(widget.statusNotifier.value){
      case _Status.show :
      case _Status.willShow : {
        setState(() {

        });
      }
      break;
      case _Status.dismiss : {
        if(mounted){
          setState(() {
            _opacity = 0;
          });
        }
      }
      break;
    }
  }

  @override
  Widget build(BuildContext context) {

    var status = widget.statusNotifier?.value ?? _Status.show;

    var child = Center(
      child: Material(
        type: MaterialType.transparency,
        child: status != _Status.willShow ? Container(
          width: widget.size.width,
          height: widget.size.height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            color: widget.backgroundColor,
          ),
          child: widget.child,
        ) : null,
      ),
    );

    return AbsorbPointer(
      absorbing: true,
      child: AnimatedOpacity(
        opacity: _opacity,
        curve: Curves.easeOut,
        duration: _kDefaultDismissDuration,
        onEnd: widget.onDismiss,
        child: child,
      ),
    );
  }
}