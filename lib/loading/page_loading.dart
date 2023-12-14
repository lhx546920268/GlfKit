
import 'package:GlfKit/loading/activity_indicator.dart';
import 'package:flutter/material.dart';

class PageLoadingWidget extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ActivityIndicator(radius: 10,),
            Padding(
              padding: EdgeInsetsDirectional.only(start: 5),
              child: Text('加载中...', style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.normal),),
            )
          ],
        ),
      ),
    );
  }
}