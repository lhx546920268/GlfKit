import 'package:GlfKit/menu/drop_down_menu.dart';
import 'package:GlfKit/event/event_bus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DropDownMenuDemo extends StatelessWidget implements DropDownMenuDelegate {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('DropDownMenu'),
      ),
      child: Container(
        child: DropDownMenu(
          delegate: this,
          itemEqualWidth: true,
          items: [
            DropDownMenuItem(
                title: '排序', conditions: ['销量', '价格从高到低', '价格从低到高']),
            DropDownMenuItem(title: '筛选', conditions: ['分类', '品牌', '材料', '产地'])
          ],
        ),
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
