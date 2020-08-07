
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:GlfKit/widget/custom_page_view.dart';

const Duration _defaultAnimationInterval = Duration(seconds: 5);

///轮播图
class AppBanner extends StatefulWidget {

  ///轮播动画间隔
  final Duration animationInterval;

  AppBanner({
    Key key,
    this.animationInterval = _defaultAnimationInterval
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _AppBanner();
  }

  int getCount(){
    return 0;
  }

  Widget getWidget(BuildContext context, int index){

    return null;
  }
}

class _AppBanner extends State<AppBanner> with SingleTickerProviderStateMixin{

  ///计时器
  Timer _timer;
  CustomPageController _pageController;
  TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    int count = widget.getCount();
    if(count > 1){
      _timer = Timer.periodic(widget.animationInterval, (Timer timer){
        if(_pageController != null){
          _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeOut);
        }
      });

      _tabController = TabController(
          length: count,
          vsync: this
      );
    }

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    if(_timer != null){
      _timer.cancel();
    }

    if(_tabController != null){
      _tabController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    int realCount = widget.getCount();
    bool isInfinite = realCount > 1;
    _pageController = CustomPageController(
      initialPage: isInfinite ? 1 : 0
    );

    ValueChanged<int> onPageChanged;
    if(isInfinite){
      onPageChanged = (int index){
        if(index == 0){
          _pageController.jumpToPage(realCount + 1);
        }else if(index >= (realCount + 1)){
          _pageController.jumpToPage(1);
        }
        _tabController.animateTo(_getRealIndex(index, realCount));
      };
    }

    int count = realCount;
    if(isInfinite){
      count += 2;
    }

    Widget tabPageSelector;
    if(realCount > 1){
      tabPageSelector = Padding(
        padding: EdgeInsetsDirectional.only(bottom: 15),
        child: TabPageSelector(
          controller: _tabController,
          color: Colors.grey[400],
          selectedColor: Colors.white,
        ),
      );
    }

    if(count == 0){
      return Text("没数据");
    }else{
      return Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: <Widget>[
          CustomPageView(
            controller: _pageController,
            onPageChanged: onPageChanged,
            children: List.generate(count, (index){
              return widget.getWidget(context, _getRealIndex(index, realCount));
            }).toList(),
          ),
          tabPageSelector
        ],
      );
    }
  }

  int _getRealIndex(int index, int realCount){
    if(realCount > 1){
      int pageIndex = index - 1;
      if(pageIndex < 0){
        pageIndex = realCount - 1;
      }else if(pageIndex >= realCount){
        pageIndex = 0;
      }

      return pageIndex;
    }else{
      return index;
    }
  }
}