
import 'package:GlfKit/menu/tab_menu_bar.dart';
import 'package:GlfKit/theme/color_theme.dart';
import 'package:GlfKit/widget/page.dart';
import 'package:flutter/material.dart';


class MenuBarDemo extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return _MenuBarDemoState();
  }
}

class _MenuBarDemoState extends State<MenuBarDemo> with
    BasePage{

  PageScrollNotification scrollNotification = PageScrollNotification(null);
  List<String> titles = ['零食', '粮油', '生活用品', '家具', '家电', '移动设备', '五金', '生鲜', '衣服', '百货'];
  PageController? pageController;

  @override
  Widget build(BuildContext context) {
    return buildInternal(context);
  }

  @override
  Widget getContentWidget(BuildContext context) {
    if(pageController == null){
      pageController = PageController();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        TabMenuBar(
          titles: titles,
          indicatorWidth: 20,
          scrollNotification: scrollNotification,
          onChange: (int page){
            pageController?.jumpToPage(page);
          },
        ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: _onPageNotification,
            child: PageView(
              physics: ClampingScrollPhysics(),
              controller: pageController,
              children: List.generate(titles.length, (page) => ListView(
                children: List.generate(30, (index) => Container(
                  height: 50,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 15),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: ColorTheme.dividerColor, width: 0.5))),
                  child: Text('Page $page, index $index'),
                )),
              )),
            ),
          ),
        )
      ],
    );
  }


  @override
  NavigationBarController configNavigationBar(BuildContext context){
    return NavigationBarController(title: 'MenuPage');
  }

  bool _onPageNotification(ScrollNotification notification){

    if(notification.depth == 0){
      scrollNotification.notification = notification;
      return true;
    }

    return false;
  }
}