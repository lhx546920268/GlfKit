
import 'package:GlfKit/menu/menu_bar.dart';
import 'package:flutter/material.dart';


class MenuPage extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return _MenuPageState();
  }
}

class _MenuPageState extends State<MenuPage>{

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
            child: NotificationListener(
              onNotification: _onPageNotification,
              child: PageView(
                controller: pageController,
                children: List.generate(titles.length, (index) => Container(
                  alignment: Alignment.center,
                  child: Text('$index'),
                )),
              ),
            ),
          )
        ],
      ),
    );
  }

  bool _onPageNotification(Notification notification){

    if(notification is ScrollNotification){
      scrollNotification.value = notification;
    }

    return false;
  }
}