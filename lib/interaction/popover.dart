import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

///箭头方向
enum ArrowDirection {left, top, right, bottom }

///可指定弹出位置的弹窗
// ignore: must_be_immutable
class Popover extends StatelessWidget {

  //显示一个弹窗，使用 Navigator.of(context).pop() 关闭
  static Future<T> show<T>({
    @required BuildContext context,
    @required Widget child,
    Rect relatedRect, // relatedRect和clickWidgetKey必须有一个
    Key clickWidgetKey, //
    Key key,
    ArrowDirection arrowDirection, //null 将自动计算方向
    double arrowMargin = 5,
    double arrowMinPadding = 10,
    Color popoverColor = Colors.white,
    BoxShadow shadow,
    double cornerRadius = 10,
    Size arrowSize = const Size(18, 12),
    EdgeInsets margin =
        const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
    Color barrierColor = const Color(0x01000000),
    bool barrierDismissible = true,
    Duration duration,
  }) {
    assert(context != null && child != null);
    return showGeneralDialog(
        context: context,
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor,
        transitionDuration: duration ?? Duration(milliseconds: 200),
        barrierLabel: "Dismiss",
        pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return child;
        },
        transitionBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation, Widget child) {
          return Popover(
            relatedRect: relatedRect,
            clickWidgetKey: clickWidgetKey,
            child: child,
            key: key,
            arrowDirection: arrowDirection,
            arrowMargin: arrowMargin,
            popoverColor: popoverColor,
            shadow: shadow,
            margin: margin,
            arrowSize: arrowSize,
            cornerRadius: cornerRadius,
            animation: animation,
          );
        });
  }

  static Future<void> dismiss(BuildContext context) async {
    return Navigator.of(context).pop();
  }

  Popover({
    Key key,
    GlobalKey clickWidgetKey,
    Rect relatedRect,
    ArrowDirection arrowDirection,
    double arrowMargin = 5,
    double arrowMinPadding = 10,
    Color popoverColor = Colors.white,
    BoxShadow shadow,
    double cornerRadius = 10,
    Size arrowSize = const Size(18, 12),
    EdgeInsets margin = const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
    @required this.child,
    this.animation,
  }) : super(key: key){

    assert(clickWidgetKey != null || relatedRect != null);
    assert(arrowMargin != null);
    assert(popoverColor != null);
    assert(cornerRadius != null);
    assert(arrowSize != null);
    assert(margin != null);
    assert(child != null);

    if(relatedRect == null){
      final RenderBox renderBox = clickWidgetKey.currentContext.findRenderObject();
      final Size size = renderBox.size;
      final Offset offset = renderBox.localToGlobal(Offset.zero);
      relatedRect = Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height);
    }

    _position = _PopoverPosition(
        relatedRect: relatedRect,
        arrowDirection: arrowDirection,
        arrowMargin: arrowMargin,
        arrowMinPadding: arrowMinPadding,
        margin: margin);

    _style = _PopoverStyle(
        backgroundColor: popoverColor,
        shadow: shadow,
        cornerRadius: cornerRadius,
        arrowSize: arrowSize
    );
  }

  ///位置
  _PopoverPosition _position;

  ///样式
  _PopoverStyle _style;

  ///要显示的内容
  final Widget child;

  ///过渡动画
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: <Widget>[
        _PopoverPositioned(
          position: _position,
          child: _PopoverContent(
            style: _style,
            scale: animation.value,
            position: _position,
            child: Material(
              type: MaterialType.transparency,
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

///弹窗位置
class _PopoverPosition {
  ///点击按钮的位置
  final Rect relatedRect;

  ///箭头方向
  final ArrowDirection arrowDirection;

  ///箭头和点击位置的间距
  final double arrowMargin;

  ///箭头和弹窗的最小间距
  final double arrowMinPadding;

  ///外边距
  final EdgeInsets margin;

  _PopoverPosition(
      {this.relatedRect, this.arrowDirection, this.arrowMargin, this.margin, this.arrowMinPadding});

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;

    return other is _PopoverPosition &&
        other.relatedRect == relatedRect &&
        other.arrowDirection == arrowDirection &&
        other.arrowMargin == arrowMargin &&
        other.arrowMinPadding == arrowMinPadding &&
        other.margin == margin;
  }

  @override
  int get hashCode =>
      hashValues(relatedRect, arrowDirection, arrowMargin, arrowMinPadding, margin);
}

///弹窗样式
class _PopoverStyle{

  ///背景颜色
  final Color backgroundColor;

  ///阴影
  final BoxShadow shadow;

  ///圆角
  final double cornerRadius;

  ///箭头大小
  final Size arrowSize;

  _PopoverStyle({
    this.backgroundColor,
    this.shadow,
    this.cornerRadius,
    this.arrowSize,
  });

  @override
  bool operator ==(other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;

    return other is _PopoverStyle &&
        other.backgroundColor == backgroundColor &&
        other.shadow == shadow &&
        other.cornerRadius == cornerRadius &&
        other.arrowSize == arrowSize;
  }

  @override
  int get hashCode => hashValues(backgroundColor, shadow, cornerRadius, arrowSize);
}

///弹窗位置
class _PopoverPositioned extends SingleChildRenderObjectWidget {

  final _PopoverPosition position;

  _PopoverPositioned({
    Key key,
    Widget child,
    this.position,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _PopoverPositionedRenderBox(
        position: position,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, _PopoverPositionedRenderBox renderObject) {
    renderObject.position = position;
  }
}

///弹窗位置渲染
class _PopoverPositionedRenderBox extends RenderShiftedBox {

  ///弹窗位置
  _PopoverPosition _position;

  _PopoverPositionedRenderBox({RenderBox child, _PopoverPosition position})
      : super(child) {
    _position = position;
  }

  _PopoverPosition get position => _position;
  set position(_PopoverPosition position) {
    if (_position != position) {
      _position = position;
      markNeedsLayout();
    }
  }

  @override
  void performLayout() {
    final childConstraints = this.constraints;
    child.layout(childConstraints, parentUsesSize: true);

    double width = this.constraints.maxWidth;
    double height = this.constraints.maxHeight;
    size = Size(width, height);

    //计算弹窗内容位置
    double dx;
    double dy;

    ArrowDirection direction = _calcArrowDirection(_position, child.size, constraints);
    switch (direction) {
      case ArrowDirection.top:
      case ArrowDirection.bottom:
        {
          dx = _position.relatedRect.center.dx - child.size.width / 2;

          if(dx < _position.margin.left){
            dx = _position.margin.left;
          }
          if(dx + child.size.width + _position.margin.right > width){
            dx = width - _position.margin.right - child.size.width;
          }
          if(direction == ArrowDirection.top){
            dy = _position.relatedRect.bottom + _position.arrowMargin;
            if(dy + _position.arrowMargin + child.size.height + _position.margin.bottom > height){
              dy = height - _position.arrowMargin - child.size.height - _position.margin.bottom;
            }
          }else{
            dy = _position.relatedRect.top - _position.arrowMargin - child.size.height;
            if(dy < _position.margin.top){
              dy = _position.margin.top;
            }
          }
        }
        break;
      case ArrowDirection.left:
      case ArrowDirection.right :
        {
          if(direction == ArrowDirection.left){
            dx = _position.relatedRect.right + _position.arrowMargin;
            if(dx + _position.arrowMargin + child.size.width + _position.margin.right > width){
              dx = width - _position.arrowMargin - child.size.width - _position.margin.right;
            }
          }else{
            dx = _position.relatedRect.left - _position.arrowMargin - child.size.width;
            if(dx < _position.margin.left){
              dx = _position.margin.left;
            }
          }

        dy = _position.relatedRect.center.dy - child.size.height / 2;
          if(dy < _position.margin.top){
            dy = _position.margin.top;
          }
          if(dy + child.size.height + _position.margin.bottom > height){
            dy = height - _position.margin.bottom - child.size.height;
          }
        }
        break;
      default:
        break;
    }

    BoxParentData parentData = child.parentData as BoxParentData;
    parentData.offset = Offset(dx, dy);
  }
}

///弹窗内容
class _PopoverContent extends SingleChildRenderObjectWidget {

  ///弹窗样式
  final _PopoverStyle style;

  ///当前动画缩放比例
  final double scale;

  ///弹窗位置
  final _PopoverPosition position;

  _PopoverContent({
    Key key,
    Widget child,
    this.style,
    this.scale,
    this.position
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _PopoverContentRenderBox(scale: scale, style: style, position: position);
  }

  @override
  void updateRenderObject(BuildContext context, _PopoverContentRenderBox renderObject) {
    renderObject
      ..style = style
      ..scale = scale
      ..position = position;
  }
}

///弹窗内容渲染
class _PopoverContentRenderBox extends RenderShiftedBox {

  ///弹窗样式
  _PopoverStyle _style;

  ///当前动画缩放比例
  double _scale;

  ///弹窗位置
  _PopoverPosition _position;

  _PopoverContentRenderBox({
    RenderBox child,
    double scale,
    _PopoverStyle style,
    _PopoverPosition position
  }) : super(child){
    _scale = scale;
    _style = style;
    _position = position;
  }

  double get scale => _scale;
  set scale(double scale){
    if(_scale != scale){
      _scale = scale;
      markNeedsPaint();
    }
  }

  _PopoverStyle get style => _style;
  set style(_PopoverStyle style){
    if(_style != style){
      _style = style;
      markNeedsLayout();
    }
  }

  _PopoverPosition get position => _position;
  set position(_PopoverPosition position) {
    if (_position != position) {
      _position = position;
      markNeedsLayout();
    }
  }

  @override
  void performLayout() {
    child.layout(constraints, parentUsesSize: true);

    double width;
    double height;
    double dx;
    double dy;

    ArrowDirection direction = _calcArrowDirection(_position, child.size, constraints);
    switch(direction){
      case ArrowDirection.top :
      case ArrowDirection.bottom : {
      height = child.size.height + _style.arrowSize.height;
      width = child.size.width;
      dx = 0;
      dy = direction == ArrowDirection.top ? _style.arrowSize.height : 0;
    }
        break;
      case ArrowDirection.left :
      case ArrowDirection.right : {
        height = child.size.height;
        width = child.size.width + _style.arrowSize.height;
        dx = direction == ArrowDirection.left ? _style.arrowSize.height : 0;
        dy = 0;
      }
      break;
      default:
        break;
    }

    size = Size(width, height);
    BoxParentData parentData = child.parentData as BoxParentData;
    parentData.offset = Offset(dx, dy);
  }

  @override
  void paint(PaintingContext context, Offset offset) {

    Size childSize = child.size;

    ArrowDirection direction = _calcArrowDirection(_position, childSize, constraints);

    //箭头位置
    Offset arrowOffset = _calcArrowOffset(direction, _position, offset, childSize, style);

    //绘制背景
    Path path = _getBackgroundPath(direction, offset, arrowOffset);
    Paint paint = Paint();
    paint.color = _style.backgroundColor;

    //绘制阴影
    Paint shadowPaint;
    if(_style.shadow != null){
      shadowPaint = _style.shadow.toPaint();
    }

    //缩放
    Matrix4 transform = Matrix4.identity();
    transform.scale(scale, scale, 1.0);

    //缩放点
    context.pushTransform(needsCompositing, arrowOffset, transform, (context, _) {

      if(shadowPaint != null){
        context.canvas.drawPath(path, shadowPaint);
      }
      context.canvas.drawPath(path, paint);

      //先绘制阴影，不然会被切掉， 防止子视图的背景、点击效果超出弹窗位置
      context.canvas.clipPath(path);

      super.paint(context, offset);
    });
  }

  ///获取弹窗背景路径
  Path _getBackgroundPath(ArrowDirection direction, Offset offset, Offset arrowOffset){

    double dx = offset.dx;
    double dy = offset.dy;
    double width = child.size.width;
    double height = child.size.height;
    double arrowWidth = _style.arrowSize.width;
    double arrowHeight = _style.arrowSize.height;
    double cornerRadius = _style.cornerRadius;
    Radius radius = Radius.circular(cornerRadius);


    //箭头位置
    double arrowDx = arrowOffset.dx;
    double arrowDy = arrowOffset.dy;

    Path path = new Path();
    switch(direction){
      case ArrowDirection.top : {

        double right = dx + width;
        double top = dy + arrowHeight;
        double bottom = top + height;

        //从箭头开始 向右边绘制
        path.moveTo(arrowDx, arrowDy);
        path.lineTo(arrowDx + arrowWidth / 2, top);

        //右上角
        path.lineTo(right - cornerRadius, top);
        path.arcToPoint(Offset(right, top + cornerRadius), radius: radius);

        //右下角
        path.lineTo(right, bottom - cornerRadius);
        path.arcToPoint(Offset(right - cornerRadius, bottom), radius: radius);

        //左下角
        path.lineTo(dx + cornerRadius, bottom);
        path.arcToPoint(Offset(dx, bottom - cornerRadius), radius: radius);

        //左上角
        path.lineTo(dx, top + cornerRadius);
        path.arcToPoint(Offset(dx + cornerRadius, top), radius: radius);

        //回到箭头
        path.lineTo(arrowDx - arrowWidth / 2, top);
        path.lineTo(arrowDx, arrowDy);
      }
      break;
      case ArrowDirection.bottom : {

        double right = dx + width;
        double top = dy;
        double bottom = top + height;

        //从箭头开始 向右边绘制
        path.moveTo(dx + width / 2, bottom + arrowHeight);
        path.lineTo(dx + width / 2 + arrowWidth / 2, bottom);

        //右下角
        path.lineTo(right - cornerRadius, bottom);
        path.arcToPoint(Offset(right, bottom - cornerRadius), radius: radius, clockwise: false);

        //右上角
        path.lineTo(right, top + cornerRadius);
        path.arcToPoint(Offset(right - cornerRadius, top), radius: radius, clockwise: false);

        //左上角
        path.lineTo(dx + cornerRadius, top);
        path.arcToPoint(Offset(dx, top + cornerRadius), radius: radius, clockwise: false);

        //左下角
        path.lineTo(dx, bottom - cornerRadius);
        path.arcToPoint(Offset(dx + cornerRadius, bottom), radius: radius, clockwise: false);

        //回到箭头
        path.lineTo(dx + width / 2 - arrowWidth / 2, bottom);
        path.lineTo(dx + width / 2, bottom + arrowHeight);
      }
      break;
      case ArrowDirection.left : {

        double left = dx + arrowHeight;
        double right = left + width;
        double bottom = dy + height;

        //从箭头开始 向下绘制
        path.moveTo(dx, dy + height / 2);
        path.lineTo(left, dy + height / 2 + arrowWidth / 2);

        //左下角
        path.lineTo(left, bottom - cornerRadius);
        path.arcToPoint(Offset(left + cornerRadius, bottom), radius: radius, clockwise: false);

        //右下角
        path.lineTo(right - cornerRadius, bottom);
        path.arcToPoint(Offset(right, bottom - cornerRadius), radius: radius, clockwise: false);

        //右上角
        path.lineTo(right, dy + cornerRadius);
        path.arcToPoint(Offset(right - cornerRadius, dy), radius: radius, clockwise: false);

        //左上角
        path.lineTo(left + cornerRadius, dy);
        path.arcToPoint(Offset(left, dy + cornerRadius), radius: radius, clockwise: false);

        //回到箭头
        path.lineTo(left, dy + height / 2 - arrowWidth / 2);
        path.lineTo(dx, dy + height / 2);
      }
      break;
      case ArrowDirection.right : {

        double left = dx;
        double right = left + width;
        double bottom = dy + height;

        //从箭头开始 向下绘制
        path.moveTo(right + arrowHeight, dy + height / 2);
        path.lineTo(right, dy + height / 2 + arrowWidth / 2);

        //右下角
        path.lineTo(right, bottom - cornerRadius);
        path.arcToPoint(Offset(right - cornerRadius, bottom), radius: radius);

        //左下角
        path.lineTo(left + cornerRadius, bottom);
        path.arcToPoint(Offset(left, bottom - cornerRadius), radius: radius);

        //左上角
        path.lineTo(left, dy + cornerRadius);
        path.arcToPoint(Offset(left + cornerRadius, dy), radius: radius);

        //右上角
        path.lineTo(right - cornerRadius, dy);
        path.arcToPoint(Offset(right, dy + cornerRadius), radius: radius);

        //回到箭头
        path.lineTo(right, dy + height / 2 - arrowWidth / 2);
        path.lineTo(right + arrowHeight, dy + height / 2);
      }
      break;
      default:
        break;
    }

    return path;
  }
}

///确定箭头方向
ArrowDirection _calcArrowDirection(_PopoverPosition position, Size childSize, BoxConstraints constraints) {
  if (position.arrowDirection == null) {
    double scale = 2.0 / 3.0;
    double width = constraints.maxWidth;
    double height = constraints.maxHeight;

    if ((height - position.relatedRect.bottom) * scale > childSize.height) {
      return ArrowDirection.top;
    } else if (position.relatedRect.top * scale > childSize.height) {
      return ArrowDirection.bottom;
    } else {
      if ((width - position.relatedRect.right) * scale > childSize.width) {
        return ArrowDirection.left;
      } else {
        return ArrowDirection.right;
      }
    }
  }

  return position.arrowDirection;
}

///获取箭头位置
Offset _calcArrowOffset(ArrowDirection direction, _PopoverPosition position, Offset offset, Size childSize, _PopoverStyle style) {
  double dx;
  double dy;
  switch (direction) {
    case ArrowDirection.top :
    case ArrowDirection.bottom : {
        double edge = offset.dx + childSize.width;
        double arrowSize = style.arrowSize.width / 2;

        dx = position.relatedRect.center.dx;
        if (dx + arrowSize + position.arrowMinPadding > edge) {
          dx = edge - position.arrowMinPadding - arrowSize;
        }

        dy = offset.dy;
        if(direction == ArrowDirection.bottom){
          dy += childSize.height;
        }
      }
      break;
    case ArrowDirection.left :
    case ArrowDirection.right : {
      double edge = offset.dy + childSize.height;
      double arrowSize = style.arrowSize.width / 2;

      dy = position.relatedRect.center.dy;
      if (dy + arrowSize + position.arrowMinPadding > edge) {
        dy = edge - position.arrowMinPadding - arrowSize;
      }

      dx = offset.dx;
      if(direction == ArrowDirection.right){
        dx += childSize.width;
      }
    }
    break;
  }

  return Offset(dx, dy);
}