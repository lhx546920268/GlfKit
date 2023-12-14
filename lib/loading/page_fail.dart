
import 'package:flutter/material.dart';

//失败界面
class PageFailWidget extends StatelessWidget {

  ///刷新回调
  final VoidCallback onRefresh;

  PageFailWidget({Key? key, required this.onRefresh}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 50),
            child: Text('加载时遇到了问题，刷新一下试试', textAlign: TextAlign.center, style: TextStyle(color: Color(0xffaeaeae), fontSize: 14),),
          ),
          GestureDetector(
            onTap: onRefresh,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Color(0xffcccccc), width: 0.5,),
            ),
              width: 100,
              height: 30,
              alignment: Alignment.center,
              child: Text('刷新', style: TextStyle(fontSize: 14, color: Colors.black87),),
           )
          )
        ],
      ),
    );
  }
}