import 'package:GlfKit/interaction/popover.dart';
import 'package:GlfKit/interaction/toast.dart';
import 'package:example/drop_down_menu_demo.dart';
import 'package:example/grid_demo.dart';
import 'package:example/list_demo.dart';
import 'package:example/menu_bar_demo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GliKitDemo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  GlobalKey key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('GliKitDemo'),
        ),
        body: ListView(
          children: List.generate(6, (index) => _getListItem(index)),
        ));
  }

  Widget _getListItem(int index) {

    String title;
    switch(index){
      case 0 :
        title = 'SectionListView';
        break;
      case 1 :
        title = 'SectionGridVie';
        break;
      case 2 :
        title = 'Toast';
        break;
      case 3 :
        title = "Popover";
        break;
      case 4 :
        title = "MenuBar";
        break;
      case 5 :
        title = "DropDownMenuDemo";
        break;
    }

    return Stack(
      children: <Widget>[
        ListTile(
          key: index == 3 ? key : null,
          onTap: (){
            if(index == 3){
              _showPopover();
              return;
            }
            if(index != 2){
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context){
                    switch(index){
                      case 0 : {
                        return SectionListDemo();
                      }
                      case 1 : {
                        return SectionGridViewDemo();
                      }
                      case 4 : {
                        return MenuBarDemo();
                      }
                      case 5 : {
                        return DropDownMenuDemo();
                      }
                    }

                    return null;
                  }
              ));
            }else{
              Toast.showText(context, '这是一个 Toast这是一个');
            }
          },
          title: Text(title, style: TextStyle(fontSize: 16)),
        ),
        Positioned(child: Divider(height: 0.5), left: 0, right: 0, bottom: 0,)
      ],
    );
  }

  void _showPopover(){
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
              ListTile(title: Text('首页'), leading: Icon(CupertinoIcons.home), onTap: (){

              },),
              ListTile(title: Text('购物车'), leading: Icon(CupertinoIcons.shopping_cart), onTap: (){

              }),
              ListTile(title: Text('个人中心'), leading: Icon(CupertinoIcons.profile_circled), onTap: (){

              }),
              ListTile(title: Text('位置'), leading: Icon(CupertinoIcons.location), onTap: (){

              })
            ],
          ),
        ));
  }
}
