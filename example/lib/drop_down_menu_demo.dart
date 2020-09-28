import 'package:GlfKit/menu/drop_down_menu.dart';
import 'package:GlfKit/event/event_bus.dart';
import 'package:GlfKit/theme/app_theme.dart';
import 'package:GlfKit/theme/color_theme.dart';
import 'package:GlfKit/widget/navigation_bar.dart';
import 'package:GlfKit/widget/page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DropDownMenuDemo extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _DropDownMenuDemoState();
  }
}

class _DropDownMenuDemoState extends State<DropDownMenuDemo> with StatefulPageState implements DropDownMenuDelegate {


  @override
  NavigationBarController configNavigationBar(BuildContext context){
    return NavigationBarController(title: 'DropDownMenu');
  }

  @override
  Widget getTopWidget(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: ColorTheme.dividerColor, width: AppTheme.dividerHeight))),
      child: DropDownMenu(
        delegate: this,
        itemEqualWidth: true,
        items: [
          DropDownMenuItem(
              title: '排序', conditions: ['销量', '价格从高到低', '价格从低到高']),
          DropDownMenuItem(title: '筛选', conditions: ['分类', '品牌', '材料', '产地'])
        ],
      ),
    );
  }

  @override
  void onDropDownMenuSelectCondition(DropDownMenuItem item) {

    if(item.selectedIndex == 0){
      EventBus.defaultBus.post('onLogin', value: '我登录了');
    }else{
      EventBus.defaultBus.post('onLogout', value: '我登出了');
    }
  }
}
