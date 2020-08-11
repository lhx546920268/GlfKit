import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

///下拉菜单按钮信息
class DropDownMenuItem {

  ///按钮标题
  String title;

  ///下拉列表内容，如果标题为空，则使用第一个值作为标题
  List<String> conditions;

  ///选中的列表item
  int selectedIndex;

  ///当前显示的标题
  String get displayTitle {
    if (conditions != null && conditions.isNotEmpty && selectedIndex != null) {
      return conditions[selectedIndex];
    }
    return title;
  }

  DropDownMenuItem({this.title, this.conditions, this.selectedIndex})
      : assert(title != null || (conditions != null && conditions.isNotEmpty));
}

///下拉菜单代理
abstract class DropDownMenuDelegate {

  ///选中某个条件了
  void onDropDownMenuSelectCondition(DropDownMenuItem item);
}

///下拉菜单
// ignore: must_be_immutable
class DropDownMenu extends StatefulWidget {
  ///菜单按钮
  final List<DropDownMenuItem> items;

  ///当前选中的下标
  int _selectedPosition;

  ///关联区域，如果没有，则使用当前菜单栏
  final Rect relatedRect;

  ///代理
  final DropDownMenuDelegate delegate;

  DropDownMenu({Key key, this.items, this.relatedRect, this.delegate})
      : assert(items != null && items.isNotEmpty),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DropDownMenuState();
  }
}

class _DropDownMenuState extends State<DropDownMenu> {
  @override
  void dispose() {
    _dismissList(false);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: 45,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _buildMenuItems(),
          ),
        ),
        Divider(height: 0.5),
      ],
    );
  }

  ///创建菜单按钮
  List<Widget> _buildMenuItems() {
    List<Widget> widgets = List();
    for (int i = 0; i < widget.items.length; i++) {
      bool tick = i == widget._selectedPosition;
      var item = widget.items[i];
      List<Widget> children = List();
      children.add(Text(
        item.displayTitle,
        maxLines: 1,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 14,
          color: tick ? Colors.blue : Colors.black,
        ),
      ));
      if (item.conditions != null && item.conditions.isNotEmpty) {
        children.add(
          Icon(
            tick ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            color: tick ? Colors.blue : Colors.black,
          ),
        );
      }

      widgets.add(
        Expanded(
          child: RaisedButton(
            onPressed: () {
              if (widget._selectedPosition == i) {
                _dismissList(true);
              } else {
                _dismissList(false);
                setState(() {
                  widget._selectedPosition = i;
                });
                _showList(item);
              }
            },
            color: Colors.white,
            splashColor: Colors.transparent,
            elevation: 0,
            hoverElevation: 0,
            focusElevation: 0,
            highlightElevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  //下拉列表容器和动画控制器
  OverlayEntry _entry;
  AnimationController _animationController;

  ///显示下拉菜单
  void _showList(DropDownMenuItem item) {
    Rect relatedRect = widget.relatedRect;
    if (relatedRect == null) {
      final RenderBox renderBox = context.findRenderObject();
      final Size size = renderBox.size;
      final Offset offset = renderBox.localToGlobal(Offset.zero);
      relatedRect =
          Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height);
    }

    _animationController?.dispose();

    OverlayState overlayState = Overlay.of(context);
    _animationController = AnimationController(
        duration: Duration(milliseconds: 200), vsync: overlayState);
    _entry = OverlayEntry(builder: (BuildContext context) {
      return DropDownMenuList(
        item: item,
        relatedRect: relatedRect,
        onSelect: (int index) {
          widget.delegate?.onDropDownMenuSelectCondition(widget.items[index]);
        },
        onDismiss: (bool animate) {
          _dismissList(animate);
        },
        listenable: Tween(begin: 0.0, end: 1.0).animate(_animationController),
      );
    });

    overlayState.insert(_entry);
    _animationController.forward();
  }

  ///隐藏下拉菜单
  void _dismissList(bool animate) async {
    if (animate) {
      setState(() {
        widget._selectedPosition = null;
      });
      await _animationController.reverse();
      _entry?.remove();
      _entry = null;
    } else {
      _entry?.remove();
      _entry = null;
    }
  }
}

typedef ValueCallback<T> = void Function(T value);

///下拉菜单列表
class DropDownMenuList extends AnimatedWidget {
  ///菜单信息
  final DropDownMenuItem item;

  ///关联的区域
  final Rect relatedRect;

  ///关闭回调
  final ValueCallback<bool> onDismiss;

  ///点击某个item回调
  final ValueCallback<int> onSelect;

  DropDownMenuList({
    Key key,
    @required this.item,
    @required this.relatedRect,
    @required this.onDismiss,
    this.onSelect,
    @required Listenable listenable,
  })  : assert(item != null && relatedRect != null && onDismiss != null),
        super(key: key, listenable: listenable);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable as Animation;
    double value = animation?.value ?? 1.0;

    return Stack(
      children: <Widget>[
        //点击关联区域的顶部时，关闭下拉列表，比如导航栏
        SizedBox(
          height: relatedRect.top,
          child: GestureDetector(onTap: () {
            onDismiss(true);
          }),
        ),
        Positioned(
          top: relatedRect.bottom,
          left: 0,
          right: 0,
          bottom: 0,
          child: Stack(
            children: <Widget>[
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () {
                    onDismiss(true);
                  },
                  child: Opacity(
                    opacity: value,
                    child: ColoredBox(
                      color: Colors.black26,
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 100),
                color: Colors.white,
                child: _DropDownMenuLisContent(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemExtent: 45,
                    physics: ClampingScrollPhysics(),
                    children: _buildListItems(context),
                  ),
                  animatedValue: value,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  //列表item
  List<Widget> _buildListItems(BuildContext context) {
    List<Widget> widgets = List();
    for (int i = 0; i < item.conditions.length; i++) {
      bool tick = i == item.selectedIndex;
      List<Widget> children = List();
      children.add(Text(
        item.conditions[i],
        maxLines: 1,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 14,
          color: tick ? Colors.blue : Colors.black,
        ),
      ));

      if (tick) {
        children.add(Icon(
          Icons.check,
          color: Colors.blue,
        ));
      }

      widgets.add(RaisedButton(
        onPressed: () {
          item.selectedIndex = i;
          if (onSelect != null) {
            onSelect(i);
          }
          onDismiss(true);
        },
        color: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 15),
        highlightElevation: 0,
        hoverElevation: 0,
        disabledColor: Colors.white,
        splashColor: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: children,
        ),
      ));
    }

    return ListTile.divideTiles(tiles: widgets, context: context).toList();
  }
}

///下拉列表内容容器
class _DropDownMenuLisContent extends SingleChildRenderObjectWidget {
  final double animatedValue;

  _DropDownMenuLisContent({Key key, Widget child, this.animatedValue})
      : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _DropDownMenuListContentRenderBox(animatedValue: animatedValue);
  }

  @override
  void updateRenderObject(
      BuildContext context, _DropDownMenuListContentRenderBox renderObject) {
    renderObject.animatedValue = animatedValue;
  }
}

class _DropDownMenuListContentRenderBox extends RenderShiftedBox {
  ///动画值
  double _animatedValue;
  set animatedValue(double value) {
    if (_animatedValue != value) {
      _animatedValue = value;
      markNeedsLayout();
    }
  }

  _DropDownMenuListContentRenderBox({RenderBox child, double animatedValue})
      : _animatedValue = animatedValue,
        super(child);

  @override
  void performLayout() {
    double value = (_animatedValue ?? 1.0);
    child.layout(constraints, parentUsesSize: true);
    size = Size(child.size.width, child.size.height * value);
    child.layout(constraints.copyWith(maxHeight: size.height),
        parentUsesSize: true);

    BoxParentData parentData = child.parentData as BoxParentData;
    parentData.offset = Offset(0, 0);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
  }
}
