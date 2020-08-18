
import 'package:GlfKit/menu/menu_bar.dart';
import 'package:flutter/material.dart';


class MenuBarDemo extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return _MenuBarDemoState();
  }
}

class _MenuBarDemoState extends State<MenuBarDemo>{

  PageScrollNotification scrollNotification = PageScrollNotification(null);
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

  bool _onPageNotification(ScrollNotification notification){

    if(notification.depth == 0){
      scrollNotification.value = notification;
      return true;
    }

    return false;
  }
}