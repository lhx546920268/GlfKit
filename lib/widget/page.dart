import 'dart:math';

import 'package:GlfKit/loading/page_fail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:GlfKit/loading/page_loading.dart';
import 'package:provider/provider.dart';

class NavigationBarParameters {
  final String leadingTitle;
  final String leadingIcon;
  final Widget leadingWidget;
  final VoidCallback leadingOnPressed;
  final String middleTitle;
  final Widget middleWidget;
  final String trailingTitle;
  final String trailingIcon;
  final Widget trailingWidget;
  final VoidCallback trailingOnPressed;

  const NavigationBarParameters({
    this.leadingTitle,
    this.leadingIcon,
    this.leadingWidget,
    this.leadingOnPressed,
    this.middleTitle,
    this.middleWidget,
    this.trailingIcon,
    this.trailingTitle,
    this.trailingWidget,
    this.trailingOnPressed,
  });

  Widget getMiddleWidget() {
    if (middleTitle != null) {
      return Text(
        middleTitle,
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.normal, color: Colors.white),
      );
    }
    return middleWidget;
  }

  Widget getLeadingWidget() {
    if (leadingWidget != null) {
      return leadingWidget;
    }

    return _getLeadingWidget(
        title: leadingTitle, icon: leadingIcon, onPressed: leadingOnPressed);
  }

  Widget getTrailingWidget() {
    if (trailingWidget != null) {
      return trailingWidget;
    }

    return _getTrailingWidget(
        title: trailingTitle, icon: trailingIcon, onPressed: trailingOnPressed);
  }

  Widget _getLeadingWidget(
      {String title, String icon, VoidCallback onPressed}) {
    return _getNavigationItemWidget(
        title: title,
        icon: icon,
        padding: EdgeInsetsDirectional.only(start: 7),
        onPressed: onPressed);
  }

  Widget _getTrailingWidget(
      {String title, String icon, VoidCallback onPressed}) {
    return _getNavigationItemWidget(
        title: title,
        icon: icon,
        padding: EdgeInsetsDirectional.only(end: 7),
        onPressed: onPressed);
  }

  Widget _getNavigationItemWidget(
      {String title,
      String icon,
      EdgeInsetsGeometry padding,
      VoidCallback onPressed}) {

    if(title == null && icon == null){
      return null;
    }

    Widget child;
    if (title != null) {
      child = Text(
        title,
        style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.normal, color: Colors.white),
      );
    } else {
      child = Image.asset(icon);
    }

    return _createNavigationItemWidget(child: child, padding: padding, onPressed: onPressed);
  }

  Widget _createNavigationItemWidget(
      {Widget child,
        EdgeInsetsGeometry padding,
        VoidCallback onPressed}) {
    if (child == null) {
      return null;
    }

    return CupertinoButton(
      padding: padding,
      child: child,
      onPressed: onPressed,
    );
  }
}

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

  Widget build(BuildContext context) {

    var topWidget = getTopWidget(context);
    var bottomWidget = getBottomWidget(context);

    var children = List<Widget>();
    if (topWidget != null) {
      children.add(topWidget);
    }

    Widget contentWidget;
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

    contentWidget = wrapContentWidget(context, contentWidget);

    if (contentWidget != null) {
      children.add(Expanded(
        child: contentWidget,
      ));
    }

    if (bottomWidget != null) {
      children.add(bottomWidget);
    }

    var navigationBar = getNavigationBar(context, getNavigationBarParameters());
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

  Widget getTopWidget(BuildContext context) {
    return null;
  }

  Widget getBottomWidget(BuildContext context) {
    return null;
  }

  Widget getContentWidget(BuildContext context) {
    return null;
  }

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

  NavigationBarParameters getNavigationBarParameters() {
    return NavigationBarParameters();
  }

  CupertinoNavigationBar getNavigationBar(
      BuildContext context, NavigationBarParameters parameters) {
    if (parameters == null) {
      return null;
    }

    var route = ModalRoute.of(context);
    Widget leading = parameters.getLeadingWidget();
    if(leading == null && route != null){
      if(route.canPop){
        var theme = CupertinoTheme.of(context);
        leading = parameters._createNavigationItemWidget(
            child: Icon(
              CupertinoIcons.back,
              color: theme.primaryContrastingColor,
              size: 32,
            ),
            padding: EdgeInsetsDirectional.only(start: 0),
            onPressed: (){
              goBack();
        });
      }
    }

    return CupertinoNavigationBar(
      brightness: CupertinoTheme.of(context).brightness,
      padding: EdgeInsetsDirectional.zero,
      leading: leading,
      trailing: parameters.getTrailingWidget(),
      middle: parameters.getMiddleWidget(),
      transitionBetweenRoutes: false,
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
  EasyRefreshController easyRefreshController;

  ///分页当前页码
  int curPage = 1;

  @override
  Widget wrapContentWidget(BuildContext context, Widget content){
    var widget = super.wrapContentWidget(context, content);
    if ((refreshEnable || loadMoreEnable) && pageStatus == PageStatus.normal) {

      if(easyRefreshController == null){
        easyRefreshController = EasyRefreshController();
      }
      return EasyRefresh(
        child: widget,
        controller: easyRefreshController,
        onRefresh: refreshEnable ? _onRefresh : null,
        onLoad: loadMoreEnable ? _onLoadMore : null,
      );
    }

    return widget;
  }

  Future<void> _onRefresh() async {
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

  Future<void> _onLoadMore() async {
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

  Widget wrapProviderIfNeeded(BuildContext context, Widget child);
}