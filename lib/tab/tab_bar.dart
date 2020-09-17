
import 'package:GlfKit/tab/tab_item.dart';
import 'package:GlfKit/tab/tab_scaffold.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class TabBar extends StatefulWidget {

  final List<TabItem> items;
  final Color backgroundColor;
  final Border border;
  final TextStyle style;
  final TextStyle activeStyle;
  final TabBarController controller;

  TabBar({
    Key key,
    this.items,
    this.backgroundColor,
    this.border,
    this.style,
    this.activeStyle,
    this.controller
  }): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TabBarState();
  }
}

class _TabBarState extends State<TabBar> {

  @override
  void initState() {
    widget.controller.addListener(_onChange);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    super.dispose();
  }

  void _onChange(){
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      height: 49,
      decoration: BoxDecoration(color: widget.backgroundColor ?? Colors.white, border: widget.border),
      child: Row(
        children: List.generate(widget.items.length, (index) => _getItem(index)),
      ),
    );
  }

  Widget _getItem(int index){
    bool selected = widget.controller.selectedIndex == index;
    var item = widget.items[index];
    List<Widget> children = [];

    Widget icon = selected ? item.activeIcon ?? item.icon : item.icon ?? item.activeIcon;
    if(icon != null){
      children.add(icon);
    }

    if(item.title != null){
      children.add(DefaultTextStyle(
        style: selected ? widget.activeStyle : widget.style,
        child: item.title,
      ));
    }

    if(item.badgeValue != null){
      children.add(item.badgeValue);
    }

    return Expanded(
      child: GestureDetector(
        onTap: () {
          widget.controller.selectedIndex = index;
        },
        behavior: HitTestBehavior.opaque,
        child: TabBarItem(item: item, children: children,),
      ),
    );
  }
}

class TabBarItem extends MultiChildRenderObjectWidget {

  final TabItem item;

  TabBarItem({
    Key key,
    List<Widget> children = const <Widget>[],
    @required this.item,
  }): super(key: key, children: children);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _TabBarItemRenderObject(item: item);
  }
}

class _TabBarItemParentData extends ContainerBoxParentData<RenderBox>  {
}

class _TabBarItemRenderObject extends RenderBox with
    ContainerRenderObjectMixin<RenderBox, _TabBarItemParentData>,
    RenderBoxContainerDefaultsMixin<RenderBox, _TabBarItemParentData> {

  TabItem item;

  _TabBarItemRenderObject({this.item});

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! _TabBarItemParentData) {
      child.parentData = _TabBarItemParentData();
    }
  }

  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    final childConstraints = BoxConstraints(
        minWidth: 0,
        maxWidth: constraints.maxWidth,
        minHeight: constraints.minHeight,
        maxHeight: constraints.maxHeight);

    RenderBox child = firstChild;
    double height = constraints.maxHeight;
    double width = constraints.maxWidth;
    RenderBox icon;
    RenderBox title;
    RenderBox badgeValue;

    int index = 0;
    while(child != null){

      child.layout(childConstraints, parentUsesSize: true);

      switch(index){
        case 0 :
          icon = child;
          break;
        case 1 :
          title = child;
          break;
        case 2 :
          badgeValue = child;
          break;
      }
      index ++;
      _TabBarItemParentData parentData = child.parentData as _TabBarItemParentData;
      child = parentData.nextSibling;
    }

    double dy = 0;
    if(title != null){
      _TabBarItemParentData parentData = title.parentData as _TabBarItemParentData;
      parentData.offset = Offset((width - title.size.width) / 2, height - title.size.height - 2);
      dy = parentData.offset.dy;
    }

    if(icon != null){
      _TabBarItemParentData parentData = icon.parentData as _TabBarItemParentData;
      double y;
      if(dy != 0){
        y = dy - item.padding - icon.size.height;
      }else{
        y = (height - icon.size.height) / 2;
      }
      parentData.offset = Offset((width - icon.size.width) / 2, y);
    }

    if(badgeValue != null){
      _TabBarItemParentData parentData = badgeValue.parentData as _TabBarItemParentData;
      double dx;
      double dy;
      if(icon != null){
        _TabBarItemParentData parentData = icon.parentData as _TabBarItemParentData;
        dx = parentData.offset.dx + icon.size.width - badgeValue.size.width / 2;
        dy = parentData.offset.dy - badgeValue.size.height / 2;

        if(dx + badgeValue.size.width > width){
          dx = width - badgeValue.size.width;
        }

        if(dy < 3){
          dy = 3;
        }

      }else{
        dx = width - badgeValue.size.width - 5;
        dy = 3;
      }
      parentData.offset = Offset(dx, dy);
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