import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:GlfKit/loading/page_loading.dart';

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
    if (title == null && icon == null) {
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

    return CupertinoButton(
      padding: padding,
      child: child,
      onPressed: onPressed,
    );
  }
}

mixin StateFulPageState<T extends StatefulWidget> on State<T> {
  bool showPageLoading = false;
  bool refreshEnable = false;
  bool loadMoreEnable = false;
  Color backgroundColor = Colors.white;
  EasyRefreshController _easyRefreshController;

  int curPage = 1;

  Widget build(BuildContext context) {
    var topWidget = getTopWidget(context);
    var bottomWidget = getBottomWidget(context);

    var children = List<Widget>();
    if (topWidget != null) {
      children.add(topWidget);
    }

    var contentWidget =
        showPageLoading ? PageLoadingWidget() : getContentWidget(context);

    if ((refreshEnable || loadMoreEnable) && !showPageLoading) {

      if(_easyRefreshController == null){
        _easyRefreshController = EasyRefreshController();
      }
      contentWidget = EasyRefresh(
        child: contentWidget,
        controller: _easyRefreshController,
        onRefresh: refreshEnable ? onRefresh : null,
        onLoad: loadMoreEnable ? onLoadMore : null,
      );
    }

    if (contentWidget != null) {
      children.add(Expanded(
        child: contentWidget,
      ));
    }

    if (bottomWidget != null) {
      children.add(bottomWidget);
    }

    var navigationBar = getNavigationBar(context, getNavigationBarParameters());
    var child = Column(children: children);

    if (navigationBar != null) {
      return CupertinoPageScaffold(
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

  Future<void> onRefresh() async {}

  void startRefresh(){
    _easyRefreshController?.callRefresh();
  }

  void stopRefresh(){
    _easyRefreshController?.finishRefresh();
  }

  Future<void> onLoadMore() async {}

  void startLoadMore(){
    _easyRefreshController?.callLoad();
  }

  void stopLoadMore(bool hasMore){
    _easyRefreshController?.finishLoad(noMore: !hasMore);
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

  NavigationBarParameters getNavigationBarParameters() {
    return NavigationBarParameters();
  }

  CupertinoNavigationBar getNavigationBar(
      BuildContext context, NavigationBarParameters parameters) {
    if (parameters == null) {
      return null;
    }

    return CupertinoNavigationBar(
      brightness: Brightness.dark,
      padding: EdgeInsetsDirectional.zero,
      leading: parameters.getLeadingWidget(),
      trailing: parameters.getTrailingWidget(),
      middle: parameters.getMiddleWidget(),
    );
  }
}
