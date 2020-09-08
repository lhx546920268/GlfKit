import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/**
 * 和PageView 一起使用
 *   PageScrollNotification scrollNotification = PageScrollNotification(null);
    List<String> titles = ['零食', '粮油', '生活用品', '家具', '家电', '移动设备', '五金', '生鲜', '衣服', '百货'];
    PageController pageController;


    @override
    Widget build(BuildContext context) {

    if(pageController == null){
    pageController = PageController();
    }

    return Scaffold(
    appBar: AppBar(title: Text('MenuPage'),),
    body: Column(
    mainAxisAlignment: MainAxisAlignment.start,
    children: <Widget>[
    MenuBar(
    titles: titles,
    indicatorWidth: 20,
    scrollNotification: scrollNotification,
    onChange: (int page){
    pageController.jumpToPage(page);
    },
    ),
    Expanded(
    child: NotificationListener<ScrollNotification>(
    onNotification: _onPageNotification,
    child: PageView(
    controller: pageController,
    children: List.generate(titles.length, (page) => ListView(
    children: List.generate(30, (index) => ListTile(
    title: Text('Page $page, index $index'),
    )),
    )),
    ),
    ),
    )
    ],
    ),
    );
    }

    bool _onPageNotification(ScrollNotification event){

    if(event.depth == 0){
    scrollNotification.value = event;
    }

    return false;
    }
 */

///滑动通知
class PageScrollNotification extends ValueNotifier<ScrollNotification>{

  PageScrollNotification(ScrollNotification notification) : super(notification);
}

///菜单条控制器
class MenuBarController extends ChangeNotifier {

  int _position = 0;
  int get position => _position;

  ///滑动到某个位置
  void animateTo(int position) {
    if(_position != position){
      _position = position;
      notifyListeners();
    }
  }
}

///条形菜单
// ignore: must_be_immutable
class MenuBar extends StatefulWidget {
  ///菜单栏高度
  final double height;

  ///菜单按钮标题
  final List<String> titles;

  ///选中的下标
  final int selectedPosition;

  ///字体大小
  final double fontSize;

  ///字体颜色
  final Color textColor;

  ///选中的字体颜色
  final Color selectedTextColor;

  ///选中改变
  final ValueChanged<int> onChange;

  ///关联的page滑动通知
  final PageScrollNotification scrollNotification;

  ///控制器
  MenuBarController _controller;

  ///样式
  MenuBarStyle _style;

  MenuBar({
    Key key,
    this.height = 45,
    this.titles,
    this.selectedPosition = 0,
    this.fontSize = 14,
    this.textColor = Colors.black,
    this.selectedTextColor = Colors.blue,
    this.onChange,
    this.scrollNotification,
    MenuBarController controller,
    double indicatorWidth,
    double indicatorHeight = 2,
    Color indicatorColor = Colors.blue,
    double spacing = 20,
    bool equalWidth = false,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 20),
  })  : assert(height != null),
        assert(selectedPosition != null),
        assert(fontSize != null),
        super(key: key) {
    _style = MenuBarStyle(
      equalWidth: equalWidth,
      indicatorWidth: indicatorWidth,
      indicatorHeight: indicatorHeight,
      indicatorColor: indicatorColor,
      spacing: spacing,
      padding: padding,
    );

    _controller = controller ?? MenuBarController();
    _controller._position = selectedPosition;
  }

  @override
  State<StatefulWidget> createState() {
    return MenuBarState();
  }
}

class MenuBarState extends State<MenuBar> with SingleTickerProviderStateMixin {

  ///item标识符
  var keys = Map<int, GlobalKey>();

  ///动画
  AnimationController animationController;
  Animation<double> animation;

  ///滑动监听
  ScrollNotification _scrollNotification;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    animation = Tween<double>(begin: 0, end: 1.0).animate(animationController)
      ..addListener(() {
        setState(() {});
      });

    widget.scrollNotification?.addListener(_onPageScrollNotification);
    widget._controller.addListener(_onAnimateTo);
  }

  ///page滑动改变
  void _onPageScrollNotification(){
    ScrollNotification scrollNotification = widget.scrollNotification.value;
    int position;

    ScrollMetrics metrics = scrollNotification.metrics;
    double value = metrics.pixels % metrics.viewportDimension / metrics.viewportDimension;

    //避免选中的效果有延迟
    position = metrics.pixels ~/ metrics.viewportDimension + (value - value.floor() > 0.9 ? 1 : 0);

    if(scrollNotification is ScrollEndNotification || scrollNotification is UserScrollNotification){
      scrollNotification = null;
    }

    setState(() {
      _scrollNotification = scrollNotification;
      if(position != null){
        widget._controller._position = position;
      }
    });
    if(position != null){
      _animateTo(position);
    }
  }

  ///监听要滑动了
  void _onAnimateTo(){
    _select(widget._controller.position, false);
  }

  @override
  void dispose() {
    widget.scrollNotification?.removeListener(_onPageScrollNotification);
    widget._controller.removeListener(_onAnimateTo);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var titles = widget.titles;

    List<Widget> children = List();
    for (int i = 0; i < titles.length; i++) {
      if (keys[i] == null) {
        keys[i] = GlobalKey();
      }

      children.add(GestureDetector(
        key: keys[i],
        onTap: () {
          if (i != widget._controller.position) {
            _select(i, true);
          }
        },
        child: Text(
          titles[i],
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: widget.fontSize,
              color: widget._controller.position != i
                  ? widget.textColor
                  : widget.selectedTextColor),
        ),
      ));
    }

    return SizedBox(
      height: widget.height,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: _MenuBarFlex(
          selectedPosition: widget._controller.position,
          animatedValue: animationController.isAnimating ? animation.value : 1.0,
          children: children,
          style: widget._style,
          scrollNotification: _scrollNotification,
        ),
      ),
    );
  }

  ///选中某个
  void _select(int position, bool callback){
    setState(() {
      widget._controller._position = position;
    });
    animationController.reset();
    animationController.forward();
    if(callback && widget.onChange != null){
      widget.onChange(position);
    }
   // _animateTo(position);
  }

  ///滑动到某个位置
  void _animateTo(int position){
    Scrollable.ensureVisible(keys[position].currentContext,
        alignment: 0.5, duration: animationController.duration);
  }
}

///菜单样式
class MenuBarStyle {

  ///是否每个按钮的宽度一样
  final bool equalWidth;

  ///下划线宽度，如果为空或者<=0，则使用选中的item宽度
  final double indicatorWidth;

  ///下划线高度
  final double indicatorHeight;

  ///下划线颜色
  final Color indicatorColor;

  ///item间隔
  final double spacing;

  ///内边距仅支持左右
  final EdgeInsets padding;

  MenuBarStyle(
      {this.equalWidth,
        this.indicatorWidth,
      this.indicatorHeight,
      this.indicatorColor,
      this.spacing,
      this.padding});

  @override
  int get hashCode => hashValues(
      indicatorWidth, indicatorHeight, indicatorColor, spacing, padding);

  ///是否需要显示下划线
  bool shouldDisplayIndicator() =>
      indicatorHeight > 0 &&
      indicatorColor != null &&
      indicatorColor.opacity > 0.01;

  ///获取下划线宽度
  double indicatorWidthFor(RenderBox child){
    if(indicatorWidth == null || indicatorWidth <= 0){
      return child.size.width;
    }

    return indicatorWidth;
  }

  @override
  bool operator ==(other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;

    return other is MenuBarStyle &&
        indicatorWidth == other.indicatorWidth &&
        indicatorHeight == other.indicatorHeight &&
        indicatorColor == other.indicatorColor &&
        spacing == other.spacing &&
        padding == other.padding;
  }
}

class _MenuBarFlex extends MultiChildRenderObjectWidget {
  ///当前选中的
  final int selectedPosition;

  ///当前动画值
  final double animatedValue;

  ///样式
  final MenuBarStyle style;

  ///关联的page滑动通知
  final ScrollNotification scrollNotification;

  _MenuBarFlex({
    Key key,
    List<Widget> children = const <Widget>[],
    this.selectedPosition = 0,
    this.animatedValue,
    this.style,
    this.scrollNotification,
  }) : super(
          key: key,
          children: children,
        );

  @override
  RenderBox createRenderObject(BuildContext context) {

    return MenuBarRenderBox(
        windowWidth: MediaQuery.of(context).size.width,
        selectedPosition: selectedPosition,
        animatedValue: animatedValue,
        style: style,
        scrollNotification: scrollNotification
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant MenuBarRenderBox renderObject) {
    renderObject
      ..windowWidth = MediaQuery.of(context).size.width
      ..selectedPosition = selectedPosition
      ..animatedValue = animatedValue
      ..style = style
        ..scrollNotification = scrollNotification;
  }
}

class MenuBarParentData extends ContainerBoxParentData<RenderBox> {

  ///原始大小
  Size size;
}

class MenuBarRenderBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MenuBarParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MenuBarParentData> {

  double windowWidth;

  ///当前选中的子视图
  RenderBox _selectedChild;

  ///以前选中的子视图
  RenderBox _oldSelectedChild;

  ///当前选中的
  int _selectedPosition;
  set selectedPosition(int position) {
    if (_selectedPosition != position) {
      _selectedPosition = position;
      _oldSelectedChild = _selectedChild;
      _selectedChild = null;
      markNeedsPaint();
    }
  }

  ///动画值
  double _animatedValue;
  set animatedValue(double value) {
    if (_animatedValue != value) {
      _animatedValue = value;
      markNeedsPaint();
    }
  }

  ///样式
  MenuBarStyle _style;
  set style(MenuBarStyle style) {
    if (_style != style) {
      _style = style;
      markNeedsLayout();
    }
  }

  ///关联的page滑动通知
  ScrollNotification _scrollNotification;
  set scrollNotification(ScrollNotification notification){
    if(notification != _scrollNotification){
      _scrollNotification = notification;
      markNeedsPaint();
    }
  }

  MenuBarRenderBox({
    this.windowWidth,
    List<RenderBox> children,
    int selectedPosition = 0,
    double animatedValue,
    MenuBarStyle style,
    ScrollNotification scrollNotification,
  })  : _selectedPosition = selectedPosition,
        _animatedValue = animatedValue,
        _style = style {
    addAll(children);
  }

  //获取选中的child
  void _fetchSelectedChildIfNeeded() {
    if (_selectedChild == null || _selectedChild.parent != this) {
      _oldSelectedChild = _oldSelectedChild ?? firstChild;
      int index = 0;
      RenderBox child = firstChild;
      while (index != _selectedPosition) {
        child = childAfter(child);
        index++;
      }
      _selectedChild = child;
    }
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! MenuBarParentData) {
      child.parentData = MenuBarParentData();
    }
  }

  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    final childConstraints = BoxConstraints(
        minWidth: constraints.minWidth,
        maxWidth: constraints.maxWidth,
        minHeight: 0,
        maxHeight: constraints.maxHeight);

    double minWidth = constraints.minWidth;
    double maxWidth = constraints.maxWidth;
    if(_style.equalWidth){
      double width = constraints.hasBoundedWidth ? constraints.maxWidth : windowWidth;
      minWidth = (width - _style.padding.left - _style.padding.right - _style.spacing * (childCount - 1)) / childCount;
      maxWidth = minWidth;
    }

    final otherConstraints = BoxConstraints(
        minWidth: minWidth,
        maxWidth: maxWidth,
        minHeight: constraints.minHeight,
        maxHeight: constraints.maxHeight);

    RenderBox child = firstChild;
    double dx = _style.padding?.left ?? 0;
    double height = constraints.maxHeight;

    while (child != null) {
      child.layout(childConstraints, parentUsesSize: true);

      MenuBarParentData parentData = child.parentData;
      parentData.offset = Offset(dx, (height - child.size.height) / 2);
      parentData.size = child.size;

      //把item高度改成和parent一样高，扩大点击范围
      child.layout(otherConstraints, parentUsesSize: true);

      dx += child.size.width;
      child = parentData.nextSibling;
      if(child != null){
        dx += _style.spacing ?? 0;
      }
    }

    dx += _style.padding?.right ?? 0;

    size = Size(dx, height);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);

    //绘制下划线
    if (childCount > 0 && _style.shouldDisplayIndicator()) {
      _fetchSelectedChildIfNeeded();

      RenderBox child;
      RenderBox oldChild;

      double value;
      if(_scrollNotification != null){

        ScrollMetrics metrics = _scrollNotification.metrics;
        if(!metrics.outOfRange){
          oldChild = _selectedChild;
          if(metrics.pixels < _selectedPosition * metrics.viewportDimension){
            child = (_selectedChild.parentData as MenuBarParentData).previousSibling;
            if(child != null){
              value = 1.0 - metrics.pixels % metrics.viewportDimension / metrics.viewportDimension;
            }
          }else{
            child = (_selectedChild.parentData as MenuBarParentData).nextSibling;
            if(child != null){
              value = metrics.pixels % metrics.viewportDimension / metrics.viewportDimension;
            }
          }
        }
      }

      if(child == null || oldChild == null){
        child = _selectedChild;
        oldChild = _oldSelectedChild;
      }

      if(value == null){
        value = _animatedValue ?? 1;
      }

      MenuBarParentData parentData = child.parentData as MenuBarParentData;
      double dx = parentData.offset.dx + (child.size.width - parentData.size.width) / 2 + (parentData.size.width - _style.indicatorWidthFor(child)) / 2;
      double dy = size.height - _style.indicatorHeight;

      MenuBarParentData oldParentData = oldChild.parentData as MenuBarParentData;
      double oldDx = oldParentData.offset.dx + (child.size.width - parentData.size.width) / 2 + (oldParentData.size.width - _style.indicatorWidthFor(oldChild)) / 2;

      double indicatorWidth = _style.indicatorWidthFor(oldChild) +
          (_style.indicatorWidthFor(child) - _style.indicatorWidthFor(oldChild)) * value;
      double indicatorDx = offset.dx + oldDx + (dx - oldDx) * value;

      Path path = Path();
      path.moveTo(indicatorDx, dy);
      path.lineTo(indicatorDx + indicatorWidth, dy);

      Paint paint = Paint();
      paint.style = PaintingStyle.stroke;
      paint.color = _style.indicatorColor;
      paint.strokeWidth = _style.indicatorHeight;

      context.canvas.drawPath(path, paint);
    }
  }
}
