

import 'package:GlfKit/menu/drop_down_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DropDownMenuDemo extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('DropDownMenu'),),
      body: Container(
          child: DropDownMenu(items: [
            DropDownMenuItem(title: '排序', conditions: ['销量', '价格从高到低', '价格从低到高']),
            DropDownMenuItem(title: '筛选', conditions: ['分类', '品牌', '材料', '产地'])
          ],),
      ),
    );
  }
}