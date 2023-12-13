import 'dart:async';

import 'package:GlfKit/interaction/popover.dart';
import 'package:GlfKit/interaction/toast.dart';
import 'package:GlfKit/event/event_bus.dart';
import 'package:GlfKit/loading/loading.dart';
import 'package:GlfKit/tab/tab_item.dart';
import 'package:GlfKit/tab/tab_scaffold.dart';
import 'package:GlfKit/utils/app_utils.dart';
import 'package:GlfKit/utils/route_utils.dart';
import 'package:GlfKit/widget/badge_value.dart';
import 'package:GlfKit/widget/page.dart';
import 'package:example/drop_down_menu_demo.dart';
import 'package:example/grid_demo.dart';
import 'package:example/list_demo.dart';
import 'package:example/menu_bar_demo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

double kStatusBarHeight = 0;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  final TabBarController controller = TabBarController();

  @override
  Widget build(BuildContext context) {
    kStatusBarHeight = AppUtils.getStatusBarHeight(context);

    return CupertinoApp(
        title: 'GliKitDemo',
        theme: CupertinoThemeData(brightness: Brightness.light),
        home: TabBarScaffold(items: _tabBarItems(), tabBuilder: _tabBuilder, controller: controller,));
  }

  final List<Widget> tabs = [
    MyHomePage(),
    CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text('发现'),),
      child: Container(
        child: Center(
          child: Text('发现啦'),
        ),
      ),
    ),
    CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text('我的'),),
      child: Container(
        child: Center(
          child: Text('是我啦'),
        ),
      ),
    )
  ];

  Widget _tabBuilder(BuildContext context, int index){
    return tabs[index];
  }

  List<TabItem> _tabBarItems(){
    return [
      _tabBarItem("首页", Icon(Icons.home, color: Colors.grey,), Icon(Icons.home, color: Colors.blue), null),
      _tabBarItem("发现", Icon(Icons.search, color: Colors.grey,), Icon(Icons.search, color: Colors.blue), BadgeValue(child: Text('23', style: TextStyle(fontSize: 11, color: Colors.white),),)),
      _tabBarItem("我的", Icon(Icons.person, color: Colors.grey,), Icon(Icons.person, color: Colors.blue), null),
    ];
  }

  TabItem _tabBarItem(String title, Widget icon, Widget activeIcon, Widget? badgeValue){

    return TabItem(
        title: Text(title),
        icon: icon,
        activeIcon: activeIcon,
      badgeValue: badgeValue
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class HomeListItem {

  final String title;
  final Function() onTap;
  final int count;

  HomeListItem(this.title, this.onTap, this.count);
}

class _MyHomePageState extends State<MyHomePage> with StatefulPageState {
  GlobalKey key = GlobalKey();
  late final List<HomeListItem> items;

  @override
  void initState() {
    items = [
      HomeListItem("SectionListView", () => _openPage(SectionListDemo()), 1),
      HomeListItem("SectionGridView", () => _openPage(SectionGridViewDemo()),
          15),
      HomeListItem("Toast", () => Toast.showText(context, '这是一个 Toast这是一个'),
          39),
      HomeListItem("Loading", () {
        Loading.show(context);
        Timer(Duration(milliseconds: 2000), () {
          Loading.dismiss();
        });
      }, 0),
      HomeListItem("Popover", _showPopover, -1),
      HomeListItem("MenuBar", () => _openPage(MenuBarDemo()), 0),
      HomeListItem("DropDownMenuDemo", () => _openPage(DropDownMenuDemo()), 0),
    ];

    super.initState();

    EventBus.defaultBus.subscribe('onLogin', _onValueChange);
    EventBus.defaultBus.subscribe('onLogout', _onValueChange);
  }

  @override
  void dispose() {
    EventBus.defaultBus.unsubscribe('onLogin', _onValueChange);
    EventBus.defaultBus.unsubscribe('onLogout', _onValueChange);
    super.dispose();
  }

  void _onValueChange(dynamic name) {
    print('value $name');
  }

  Future<String> _loadData() {
    return Future.delayed(Duration(seconds: 1), () {
      return "first";
    });
  }

  @override
  Widget build(BuildContext context) {
    return buildInternal(context);
  }

  @override
  Widget getContentWidget(BuildContext context) {
    return FutureBuilder(
      future: _loadData(),
      initialData: 'init',
      // ignore: missing_return
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.done:
            {
              return ListView(
                children: List.generate(
                    items.length, (index) => _getListItem(index, context)),
              );
            }
          case ConnectionState.waiting:
          case ConnectionState.active:
            {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
        }
      },
    );
  }

  @override
  NavigationBarController configNavigationBar(BuildContext context) {
    return NavigationBarController(title: 'GlfKitDemo');
  }

  Widget _getListItem(int index, BuildContext context) {
    final item = items[index];
    Widget? trailing;
    if (item.count > 0) {
      trailing = BadgeValue(child: Text("${item.count}", style: TextStyle(color: Colors
          .white, fontSize: 12),),);
    } else if (item.count < 0) {
      trailing = BadgeValue();
    }

    return Stack(
      children: <Widget>[
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          key: index == 3 ? key : null,
          onTap: item.onTap,
          child: Container(
            height: 50,
            alignment: Alignment.center,
            padding: EdgeInsets.only(left: 15, right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item.title, style: TextStyle(fontSize: 16)),
                if(trailing != null)
                  trailing,
              ],
            ),
          ),
        ),
        Positioned(
          child: Divider(height: 0.5),
          left: 0,
          right: 0,
          bottom: 0,
        )
      ],
    );
  }

  void _openPage(Widget page) {
    RouteUtils.push(context, page);
  }

  void _showPopover() async {

    onTap() {
      Navigator.of(context).pop();
    }

    Popover.show(
        context: context,
        shadow: BoxShadow(color: Colors.grey, blurRadius: 10),
        clickWidgetKey: key,
        child: Container(
          width: 180,
          child: ListView(
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: <Widget>[
              ListTile(
                title: Text('首页'),
                leading: Icon(CupertinoIcons.home),
                onTap: onTap,
              ),
              ListTile(
                  title: Text('购物车'),
                  leading: Icon(CupertinoIcons.shopping_cart),
                  onTap: onTap),
              ListTile(
                  title: Text('个人中心'),
                  leading: Icon(CupertinoIcons.profile_circled),
                  onTap: onTap),
              ListTile(
                  title: Text('位置'),
                  leading: Icon(CupertinoIcons.location),
                  onTap: onTap)
            ],
          ),
        ));
  }
}

