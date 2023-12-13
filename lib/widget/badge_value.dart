

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

//角标
class BadgeValue extends SingleChildRenderObjectWidget {

  final _Style _style;

  BadgeValue({
    Key? key,
    Widget? child,
    double? minWidth,
    double? minHeight,
    EdgeInsets? padding,
    Color? color,
    double? pointSize,
  }): _style = _Style(
      minWidth: minWidth ?? 15,
      minHeight: minHeight ?? 15,
      padding: padding ?? EdgeInsets.fromLTRB(5, 3, 5, 3),
      color: color ?? Colors.red,
      pointSize: pointSize ?? 8
  ), super(
      key: key,
      child: child != null ? DefaultTextStyle(
    style: TextStyle(fontSize: 12, color: Colors.white),
    child: child,
  ): null);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _BadgeValueRenderObject(style: _style);
  }

  @override
  void updateRenderObject(BuildContext context, _BadgeValueRenderObject renderObject) {
    renderObject.style = _style;
  }
}

class _Style {

  double minWidth;
  double minHeight;
  EdgeInsets padding;
  Color color;
  double pointSize;

  _Style({
    required this.minWidth,
    required this.minHeight,
    required this.padding,
    required this.color,
    required this.pointSize
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;

    return other is _Style &&
        other.minWidth == minWidth &&
        other.minHeight == minHeight &&
        other.padding == padding &&
        other.color == color &&
        other.pointSize == pointSize;
  }

  @override
  int get hashCode => Object.hash(minWidth, minHeight, padding, color, pointSize);
}

class _BadgeValueRenderObject extends RenderShiftedBox {

  set style(_Style style){
    if(_style != style){
      _style = style;
      markNeedsLayout();
    }
  }
  _Style _style;

  _BadgeValueRenderObject({RenderBox? child, required _Style style}): _style = style, super(child);

  @override
  void performLayout() {
    if(child != null){
      child!.layout(constraints, parentUsesSize: true);

      BoxParentData parentData = child!.parentData as BoxParentData;

      double width = max(child!.size.width + _style.padding.left + _style.padding.right, _style.minWidth);
      double height = max(child!.size.height + _style.padding.top + _style.padding.bottom, _style.minHeight);
      width = max(height, width);

      parentData.offset = Offset((width - child!.size.width) / 2, (height - child!.size.height) / 2);

      size = Size(width, height);
    }else{
      size = Size(_style.pointSize, _style.pointSize);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {

    Paint paint = new Paint();
    paint.color = _style.color;
    paint.style = PaintingStyle.fill;

    context.canvas.drawRRect(RRect.fromLTRBR(offset.dx, offset.dy, offset.dx + size.width, offset.dy + size.height, Radius.circular(size.height / 2)), paint);

    super.paint(context, offset);
  }
}