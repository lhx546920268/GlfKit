import 'dart:async';
import 'dart:collection';
import 'dart:isolate';

import 'package:GlfKit/base/collection/safe_map.dart';
import 'package:GlfKit/interaction/popover.dart';
import 'package:GlfKit/interaction/toast.dart';
import 'package:GlfKit/event/event_bus.dart';
import 'package:example/drop_down_menu_demo.dart';
import 'package:example/grid_demo.dart';
import 'package:example/list_demo.dart';
import 'package:example/menu_bar_demo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

double kStatusBarHeight = 0;

void main() {
  runApp(MyApp());
}

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(title: const Text(_title)),
        body: Center(
          child: MyStatefulWidget(),
        ),
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget>
    with SingleTickerProviderStateMixin {
  double _size = 50.0;
  bool _large = false;

  void _updateSize() {
    setState(() {
      _size = _large ? 250.0 : 100.0;
      _large = !_large;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _updateSize(),
      child: AnimatedContainer(
        curve: Curves.easeIn,
        width: _size,
        height: _size,
        color: Colors.red,
        duration: Duration(seconds: 1),
        child: Icon(Icons.shopping_cart, color: Colors.black54, size: 25,),
      ),
    );
  }
}

// class MyApp extends StatelessWidget {
//   // This widget is the root of your application.
//
//   @override
//   Widget build(BuildContext context) {
//     MediaQueryData data =
//         MediaQueryData.fromWindow(WidgetsBinding.instance.window);
//     kStatusBarHeight = data.padding.top;
//
//     return MaterialApp(
//         title: 'GliKitDemo',
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//           visualDensity: VisualDensity.adaptivePlatformDensity,
//         ),
//         home: MyHomePage());
//   }
// }

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey key = GlobalKey();

  @override
  void initState() {
    super.initState();

    EventBus.defaultBus().subscribe('onLogin', _onValueChange);
    EventBus.defaultBus().subscribe('onLogout', _onValueChange);
  }

  @override
  void dispose() {
    EventBus.defaultBus().unsubscribe('onLogin', _onValueChange);
    EventBus.defaultBus().unsubscribe('onLogout', _onValueChange);
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
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    print('didChangeDependencies');
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
    print('deactivate');
  }

  @override
  void didUpdateWidget(MyHomePage oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    print('didUpdateWidget');
  }

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(
      title: Text('GliKitDemo'),
    );
    return Scaffold(
        appBar: appBar,
        body: FutureBuilder(
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
                        6, (index) => _getListItem(index, context)),
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
        ));
  }

  Widget _getListItem(int index, BuildContext context) {
    String title;
    switch (index) {
      case 0:
        title = 'SectionListView';
        break;
      case 1:
        title = 'SectionGridView';
        break;
      case 2:
        title = 'Toast';
        break;
      case 3:
        title = "Popover";
        break;
      case 4:
        title = "MenuBar";
        break;
      case 5:
        title = "DropDownMenuDemo";
        break;
    }

    return Stack(
      children: <Widget>[
        ListTile(
          key: index == 3 ? key : null,
          onTap: () {
            if (index == 3) {
              _showPopover();
              return;
            }
            if (index != 2) {
              Navigator.of(context).push(MaterialPageRoute(
                  fullscreenDialog: true,
                  maintainState: false,
                  builder: (BuildContext context) {
                    switch (index) {
                      case 0:
                        {
                          return SectionListDemo();
                        }
                      case 1:
                        {
                          return SectionGridViewDemo();
                        }
                      case 4:
                        {
                          return MenuBarDemo();
                        }
                      case 5:
                        {
                          return DropDownMenuDemo();
                        }
                    }

                    return null;
                  }));
            } else {
              Toast.showText(context, '这是一个 Toast这是一个');
            }
          },
          title: Text(title, style: TextStyle(fontSize: 16)),
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

  void _showPopover() {
    onTap() {
      Navigator.of(context).pop();
    }

    Popover.show(
        context: context,
        shadow: BoxShadow(color: Colors.grey, blurRadius: 5),
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
