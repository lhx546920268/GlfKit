

import 'package:GlfKit/loading/page_fail.dart';
import 'package:GlfKit/widget/navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:GlfKit/loading/page_loading.dart';

export 'navigation_bar.dart';

///页面状态
enum PageStatus {normal, loading, fail, empty}

mixin StateSafe<T extends StatefulWidget> on State<T> {

  setStateSafe(VoidCallback fn){
    if(mounted){
      setState(fn);
    }else{
      fn();
    }
  }
}

mixin StatefulPageState<T extends StatefulWidget> on State<T> {

  ///页面状态
  PageStatus pageStatus = PageStatus.normal;

  ///背景颜色
  Color backgroundColor = Colors.white;

  ///导航栏控制器
  NavigationBarController? get navigationBarController => _navigationBarController;
  NavigationBarController? _navigationBarController;

  Widget build(BuildContext context) {

    if(shouldCallSuperBuild){
      super.build(context);
    }
    var topWidget = getTopWidget(context);
    var bottomWidget = getBottomWidget(context);

    List<Widget> children = [];
    if (topWidget != null) {
      children.add(topWidget);
    }

    Widget? contentWidget;
    switch(pageStatus){
      case PageStatus.normal :
        contentWidget = getContentWidget(context);
        break;
      case PageStatus.loading :
        contentWidget = getPageLoadingWidget(context);
        break;
      case PageStatus.fail :
        contentWidget = getPageFailWidget(context);
        break;
      case PageStatus.empty :
        contentWidget = getEmptyWidget(context);
        break;
    }

    if (contentWidget != null) {
      contentWidget = wrapContentWidget(context, contentWidget);
      children.add(Expanded(
        child: contentWidget,
      ));
    }

    if (bottomWidget != null) {
      children.add(bottomWidget);
    }

    var navigationBar = getNavigationBar(context);
    var child = wrapContainer(context, Column(children: children));

    if (navigationBar != null) {
      return CupertinoPageScaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: backgroundColor,
        navigationBar: navigationBar,
        child: child,
      );
    } else {
      return Container(
          color: backgroundColor,
          child: child,
      );
    }
  }

  //  bool get shouldCallSuperBuild => false;

  Widget? getTopWidget(BuildContext context) {
    return null;
  }

  Widget? getBottomWidget(BuildContext context) {
    return null;
  }

  Widget? getContentWidget(BuildContext context) {
    return null;
  }

  bool get shouldCallSuperBuild => false;

  @mustCallSuper
  Widget wrapContentWidget(BuildContext context, Widget content) {
    return content;
  }

  @mustCallSuper
  Widget wrapContainer(BuildContext context, Widget container) {
    return container;
  }

  Widget getPageLoadingWidget(BuildContext context) {
    return PageLoadingWidget();
  }

  Widget getPageFailWidget(BuildContext context) {
    return PageFailWidget(
      onRefresh: onReloadData,
    );
  }

  Widget getEmptyWidget(BuildContext context) {
    var color = Color.fromRGBO(200, 200, 200, 1.0);
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Icon(Icons.cloud_done, color: color, size: 100,),
          ),
          Text('暂无数据', style: TextStyle(fontSize: 16, color: color,))
        ],
      ),
    );
  }

  void onReloadData(){

  }

  NavigationBarController? configNavigationBar(BuildContext context){
    return null;
  }

  NavigationBar? getNavigationBar(
      BuildContext context) {

    NavigationBarController? controller = configNavigationBar(context);
    if(controller == null){
      return null;
    }

    _navigationBarController = controller;
    return NavigationBar(
      controller: controller,
      goBack: goBack,
    );
  }

  //返回
  void goBack(){
    Navigator.of(context).pop();
  }

  setStateSafe(VoidCallback fn){
    if(mounted){
      setState(fn);
    }else{
      fn();
    }
  }
}

///可加载更多和下拉刷新的
mixin RefreshPageState<T extends StatefulWidget> on StatefulPageState<T> {

  ///是否可以刷新
  bool refreshEnable = false;

  ///是否正在下拉刷新
  bool get isRefreshing => _isRefreshing;
  bool _isRefreshing = false;

  ///是否可以加载更多
  bool loadMoreEnable = false;

  ///是否正在加载更多
  bool get isLoadingMore => _isLoadingMore;
  bool _isLoadingMore = false;

  ///刷新控制器
  EasyRefreshController? easyRefreshController;

  ///分页当前页码
  int curPage = 1;

  @override
  Widget wrapContentWidget(BuildContext context, Widget content){
    var child = super.wrapContentWidget(context, content);
    if ((refreshEnable || loadMoreEnable) && pageStatus == PageStatus.normal) {

      if(easyRefreshController == null){
        easyRefreshController = EasyRefreshController();
      }
      return getEasyRefresh(child);
    }

    return child;
  }

  EasyRefresh getEasyRefresh(Widget child){
    return EasyRefresh(
      child: child,
      controller: easyRefreshController,
      onRefresh: refreshEnable ? willRefresh : null,
      onLoad: loadMoreEnable ? willLoadMore : null,
    );
  }

  Future<void> willRefresh() async {
    _isRefreshing = true;
    await onRefresh();
  }
  Future<void> onRefresh() async {}

  void startRefresh(){
    easyRefreshController?.callRefresh();
  }

  void stopRefresh(){
    easyRefreshController?.finishRefresh();
    _isRefreshing = false;
  }

  Future<void> willLoadMore() async {
    _isLoadingMore = true;
    await onLoadMore();
  }
  Future<void> onLoadMore() async {}

  void startLoadMore(){
    easyRefreshController?.callLoad();
  }

  void stopLoadMore(bool hasMore){
    easyRefreshController?.finishLoad(noMore: !hasMore);
    _isLoadingMore = false;
  }
}

mixin ProviderPageState<T extends StatefulWidget> on StatefulPageState<T> {

  @override
  Widget wrapContainer(BuildContext context, Widget container) {
    var widget = super.wrapContainer(context, container);
    var provider = wrapProviderIfNeeded(context, widget);
    if(provider != null){
      return provider;
    }

    return widget;
  }

  Widget? wrapProviderIfNeeded(BuildContext context, Widget child);
}

mixin WillScrollKeyboardDismiss <T extends StatefulWidget> on StatefulPageState<T>{

  @override
  Widget wrapContentWidget(BuildContext context, Widget content) {

    var child = super.wrapContentWidget(context, content);
    if(pageStatus == PageStatus.normal){
      child = NotificationListener(
        onNotification: _willScroll,
        child: child,
      );
    }
    return child;
  }

  bool _willScroll(ScrollStartNotification notification){
    if(notification.dragDetails != null){
      FocusScope.of(context).requestFocus(new FocusNode());
    }
    return true;
  }
}