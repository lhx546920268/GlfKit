
import 'dart:async';

import 'package:GlfKit/widget/page_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const Duration _defaultAnimationInterval = Duration(seconds: 5);

///轮播图
class AppBanner extends StatefulWidget {

  ///轮播动画间隔
  final Duration animationInterval;

  ///item数量
  final int count;

  ///组件构造
  final IndexedWidgetBuilder builder;

  AppBanner({
    Key? key,
    this.animationInterval = _defaultAnimationInterval,
    required this.count,
    required this.builder,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AppBanner();
  }
}

class _AppBanner extends State<AppBanner> with SingleTickerProviderStateMixin{

  ///计时器
  Timer? _timer;
  PageController? _pageController;
  PageIndicatorController? _indicatorController;

  @override
  void initState() {

    int count = widget.count;
    if(count > 1){
      _timer = Timer.periodic(widget.animationInterval, (Timer timer){
        if(_pageController != null){
          _pageController!.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeOut);
        }
      });

      _indicatorController = PageIndicatorController();
    }

    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    int realCount = widget.count;
    bool isInfinite = realCount > 1;
    _pageController = PageController(
      initialPage: isInfinite ? 1 : 0
    );

    ValueChanged<int>? onPageChanged;
    if(isInfinite){
      onPageChanged = (int index){
        if(index == 0){
          _pageController?.jumpToPage(realCount + 1);
        }else if(index >= (realCount + 1)){
          _pageController?.jumpToPage(1);
        }
        _indicatorController?.curPage = _getRealIndex(index, realCount);
      };
    }

    int count = realCount;
    if(isInfinite){
      count += 2;
    }

    List<Widget> children = [];
    children.add(PageView(
      controller: _pageController!,
      onPageChanged: onPageChanged,
      children: List.generate(count, (index){
        return widget.builder(context, _getRealIndex(index, realCount));
      }).toList(),
    ));

    if(realCount > 1){
      children.add(Padding(
        padding: EdgeInsetsDirectional.only(bottom: 15),
        child: PageIndicator(
          numberOfPage: realCount,
          controller: _indicatorController,
        ),
      ));
    }

    if(count == 0){
      return Text("没数据");
    }else{
      return Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: children,
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