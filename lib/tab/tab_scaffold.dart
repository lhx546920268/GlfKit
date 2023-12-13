
import 'package:GlfKit/base/collection/collection_utils.dart';
import 'package:GlfKit/tab/tab_bar.dart' as tabBar;
import 'package:GlfKit/tab/tab_item.dart';
import 'package:GlfKit/theme/color_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///标签栏控制器
class TabBarController extends ChangeNotifier {

  List<TabItem>? _items;

  ///选中的下标
  int get selectedIndex => _selectedIndex ?? 0;
  set selectedIndex(int value){
    assert(value >= 0);
    if(_selectedIndex != value){
      _selectedIndex = value;
      notifyListeners();
    }
  }
  int? _selectedIndex;

  void setBadgeValue(Widget value, int index){
    assert(_items != null && index >= 0 && index < _items!.length);
    _items![index].badgeValue = value;
    notifyListeners();
  }
}

///标签栏
class TabBarScaffold extends StatelessWidget {

  ///标签按钮
  final List<TabItem> items;

  ///背景颜色
  final Color? backgroundColor;

  ///边框
  final Border border;

  ///文字未选中样式
  final TextStyle style;

  ///文字选中样式
  final TextStyle activeStyle;

  ///标签栏控制器
  final TabBarController controller;

  ///内容
  final IndexedWidgetBuilder tabBuilder;

  TabBarScaffold({Key? key,
      required this.items,
      required this.tabBuilder,
      this.backgroundColor,
      this.border =
          const Border(top: BorderSide(color: Color(0xffdedede), width: 0.5)),
      TextStyle? style,
      TextStyle? activeStyle,
      TabBarController? controller})
      : this.style = style ?? TextStyle(fontSize: 11, color: Colors.grey),
        this.activeStyle =
            activeStyle ?? TextStyle(fontSize: 11, color: ColorTheme.themeColor),
        this.controller = controller ?? TabBarController(),
  assert(!isEmpty(items)),
        super(key: key) {
    this.controller._items = items;
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      color: backgroundColor ?? Colors.blue,
      child: SafeArea(
        top: false,
        bottom: true,
        child: Column(
          children: [
            Expanded(
              child: _TabBarContent(items: items, controller: controller, tabBuilder: tabBuilder,),
            ),
            tabBar.TabBar(items: items, backgroundColor: backgroundColor, border: border, style: style, activeStyle: activeStyle, controller: controller),
          ],
        ),
      ),
    );
  }
}

///标签栏内容
class _TabBarContent extends StatefulWidget {

  ///标签按钮
  final List<TabItem> items;

  ///标签栏控制器
  final TabBarController controller;

  ///内容
  final IndexedWidgetBuilder tabBuilder;

  _TabBarContent({
    Key? key,
    required this.items,
    required this.controller,
    required this.tabBuilder
  }): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TabBarContentState();
  }
}

class _TabBarContentState extends State<_TabBarContent> {

  int get tabCount => widget.items.length;

  final List<bool> shouldBuildTab = <bool>[];
  final List<FocusScopeNode> tabFocusNodes = <FocusScopeNode>[];

  // When focus nodes are no longer needed, we need to dispose of them, but we
  // can't be sure that nothing else is listening to them until this widget is
  // disposed of, so when they are no longer needed, we move them to this list,
  // and dispose of them when we dispose of this widget.
  final List<FocusScopeNode> discardedNodes = <FocusScopeNode>[];

  @override
  void initState() {
    super.initState();
    shouldBuildTab.addAll(List<bool>.filled(tabCount, false));
    widget.controller.addListener(_onChange);
  }

  void _onChange(){
    setState(() {

    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _focusActiveTab();
  }

  @override
  void didUpdateWidget(_TabBarContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only partially invalidate the tabs cache to avoid breaking the current
    // behavior. We assume that the only possible change is either:
    // - new tabs are appended to the tab list, or
    // - some trailing tabs are removed.
    // If the above assumption is not true, some tabs may lose their state.
    final int lengthDiff = tabCount - shouldBuildTab.length;
    if (lengthDiff > 0) {
      shouldBuildTab.addAll(List<bool>.filled(lengthDiff, false));
    } else if (lengthDiff < 0) {
      shouldBuildTab.removeRange(tabCount, shouldBuildTab.length);
    }
    _focusActiveTab();
  }

  // Will focus the active tab if the FocusScope above it has focus already.  If
  // not, then it will just mark it as the preferred focus for that scope.
  void _focusActiveTab() {
    if (tabFocusNodes.length != tabCount) {
      if (tabFocusNodes.length > tabCount) {
        discardedNodes.addAll(tabFocusNodes.sublist(tabCount));
        tabFocusNodes.removeRange(tabCount, tabFocusNodes.length);
      } else {
        tabFocusNodes.addAll(
          List<FocusScopeNode>.generate(
            tabCount - tabFocusNodes.length,
                (int index) => FocusScopeNode(debugLabel: '$CupertinoTabScaffold Tab ${index + tabFocusNodes.length}'),
          ),
        );
      }
    }
    FocusScope.of(context).setFirstFocus(tabFocusNodes[widget.controller.selectedIndex]);
  }

  @override
  void dispose() {
    for (final FocusScopeNode focusScopeNode in tabFocusNodes) {
      focusScopeNode.dispose();
    }
    for (final FocusScopeNode focusScopeNode in discardedNodes) {
      focusScopeNode.dispose();
    }
    widget.controller.removeListener(_onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: List<Widget>.generate(tabCount, (int index) {
        final bool active = index == widget.controller.selectedIndex;
        shouldBuildTab[index] = active || shouldBuildTab[index];

        return Offstage(
          offstage: !active,
          child: TickerMode(
            enabled: active,
            child: FocusScope(
              node: tabFocusNodes[index],
              child: Builder(builder: (BuildContext context) {
                return shouldBuildTab[index] ? widget.tabBuilder(context, index) : Container();
              }),
            ),
          ),
        );
      }),
    );
  }
}