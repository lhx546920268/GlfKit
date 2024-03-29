import 'package:GlfKit/base/def.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:GlfKit/base/collection/collection_utils.dart';

///下拉菜单按钮信息
class DropDownMenuItem {

  ///按钮标题
  String? title;

  ///下拉列表内容，如果标题为空，则使用第一个值作为标题
  List<String>? conditions;

  ///选中的列表item
  int? selectedIndex;

  ///当前显示的标题
  String get displayTitle {
    if (conditions != null && conditions!.isNotEmpty && selectedIndex != null) {
      return conditions![selectedIndex!];
    }
    return title!;
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

  ///关联区域，如果没有，则使用当前菜单栏
  final Rect? relatedRect;

  ///代理
  final DropDownMenuDelegate? delegate;

  ///选中颜色
  final Color selectedColor;

  ///正常颜色
  final Color normalColor;

  ///是否平均分
  final bool itemEqualWidth;

  ///item内边距
  final EdgeInsetsGeometry itemPadding;

  final double height;

  DropDownMenu({
    Key? key,
    required this.items,
    this.relatedRect,
    this.delegate,
    this.selectedColor = Colors.blue,
    this.normalColor = Colors.black,
    this.itemEqualWidth = true,
    this.itemPadding = EdgeInsets.zero,
    this.height = 45,
  }): assert(!isEmpty(items)),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DropDownMenuState();
  }
}

class _DropDownMenuState extends State<DropDownMenu> {

  ///当前选中的下标
  int? _selectedPosition;

  @override
  void dispose() {
    super.dispose();
    _dismissList(false);
    _animationController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buildMenuItems(),
      ),
    );
  }

  ///创建菜单按钮
  List<Widget> _buildMenuItems() {
    List<Widget> widgets = [];
    for (int i = 0; i < widget.items.length; i++) {
      bool tick = i == _selectedPosition;
      var item = widget.items[i];
      List<Widget> children = [];
      children.add(Text(
        item.displayTitle,
        maxLines: 1,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 14,
          color: tick ? widget.selectedColor : widget.normalColor,
        ),
      ));
      if (!isEmpty(item.conditions)) {
        children.add(
          Icon(
            tick ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            color: tick ? widget.selectedColor : widget.normalColor,
          ),
        );
      }

      Widget child = CupertinoButton(
        padding: widget.itemPadding,
        onPressed: () {
          if (_selectedPosition == i) {
            _dismissList(true);
          } else {
            _dismissList(false);
            setState(() {
              _selectedPosition = i;
            });
            _showList(item);
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      );
      if(widget.itemEqualWidth){
        child = Expanded(
          child: child,
        );
      }
      widgets.add(child);
    }

    return widgets;
  }

  //下拉列表容器和动画控制器
  OverlayEntry? _entry;
  AnimationController? _animationController;

  ///显示下拉菜单
  void _showList(DropDownMenuItem item) {
    Rect? relatedRect = widget.relatedRect;
    if (relatedRect == null) {
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
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
        relatedRect: relatedRect!,
        onSelect: (){
          widget.delegate?.onDropDownMenuSelectCondition(widget.items[_selectedPosition!]);
        },
        onDismiss: (bool animate) {
          _dismissList(animate);
        },
        listenable: Tween(begin: 0.0, end: 1.0).animate(_animationController!),
        selectedColor: widget.selectedColor,
        normalColor: widget.normalColor,
      );
    });

    overlayState.insert(_entry!);
    _animationController!.forward();
  }

  ///隐藏下拉菜单
  void _dismissList(bool animate) async {
    if (animate) {
      setState(() {
        _selectedPosition = null;
      });
      await _animationController?.reverse();
      _entry?.remove();
      _entry = null;
    } else {
      _entry?.remove();
      _entry = null;
    }
  }
}

///下拉菜单列表
class DropDownMenuList extends AnimatedWidget {

  ///菜单信息
  final DropDownMenuItem item;

  ///关联的区域
  final Rect relatedRect;

  ///关闭回调
  final ValueCallback<bool> onDismiss;

  ///点击某个item回调
  final VoidCallback? onSelect;

  ///选中颜色
  final Color selectedColor;

  ///正常颜色
  final Color normalColor;

  DropDownMenuList({
    Key? key,
    required this.item,
    required this.relatedRect,
    required this.onDismiss,
    this.onSelect,
    this.selectedColor = Colors.blue,
    this.normalColor = Colors.black,
    required Listenable listenable,
  }): super(key: key, listenable: listenable);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>?;
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
    List<Widget> widgets = [];
    for (int i = 0; i < item.conditions!.length; i++) {
      bool tick = i == item.selectedIndex;
      List<Widget> children = [];
      children.add(Text(
        item.conditions![i],
        maxLines: 1,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 14,
          color: tick ? selectedColor : normalColor,
        ),
      ));

      if (tick) {
        children.add(Icon(
          Icons.check,
          color: selectedColor,
        ));
      }

      widgets.add( GestureDetector(
        onTap: () {
          item.selectedIndex = i;
          if (onSelect != null) {
            onSelect!();
          }
          onDismiss(true);
        },
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: children,
          ),
        ),
      ));
    }

    return ListTile.divideTiles(tiles: widgets, context: context).toList();
  }
}

///下拉列表内容容器
class _DropDownMenuLisContent extends SingleChildRenderObjectWidget {
  final double? animatedValue;

  _DropDownMenuLisContent({Key? key, Widget? child, this.animatedValue})
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
  double? _animatedValue;
  set animatedValue(double? value) {
    if (_animatedValue != value) {
      _animatedValue = value;
      markNeedsLayout();
    }
  }

  _DropDownMenuListContentRenderBox({RenderBox? child, double? animatedValue})
      : _animatedValue = animatedValue,
        super(child);

  @override
  void performLayout() {
    if(this.child == null){
      return;
    }

    final child = this.child!;
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
