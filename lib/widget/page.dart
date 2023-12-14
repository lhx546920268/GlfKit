
import 'package:GlfKit/loading/page_fail.dart';
import 'package:GlfKit/widget/custom_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:GlfKit/loading/page_loading.dart';
import 'package:get/get.dart';

export 'custom_navigation_bar.dart';

///页面状态
enum PageStatus {normal, loading, fail, empty}

extension StateSafe on State {

  setStateSafe(VoidCallback fn){
    if(mounted){
      // ignore: invalid_use_of_protected_member
      setState(fn);
    }else{
      fn();
    }
  }
}

class BaseController extends GetxController {

  ///导航栏控制器
  late final navigationBarController = NavigationBarController();

  //页面状态
  var pageStatus = PageStatus.normal.obs;

  //背景颜色
  var backgroundColor = Colors.white.obs;

  //是否有导航栏
  var hasNavigationBar = true.obs;

  void onReloadData(){}
}

class BaseView<T extends BaseController> extends GetView<T> with BasePage {

  @override
  Widget build(BuildContext context) {
    return buildInternal(context);
  }
}

mixin BasePage<T extends BaseController> on GetView<T> {

  ///导航栏控制器
  NavigationBarController get navigationBarController => controller.navigationBarController;
  bool get hasNavigationBar => controller.hasNavigationBar.value;

  PageStatus get pageStatus => controller.pageStatus.value;
  Color get backgroundColor => controller.backgroundColor.value;


  Widget buildInternal(BuildContext context) {
    return Obx(() {
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
          navigationBar: getNavigationBar(context),
          child: child,
        );
      } else {
        return Container(
          color: backgroundColor,
          child: child,
        );
      }
    });
  }

  Widget? getTopWidget(BuildContext context) {
    return null;
  }

  Widget? getBottomWidget(BuildContext context) {
    return null;
  }

  Widget? getContentWidget(BuildContext context) {
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
    controller.onReloadData();
  }

  CustomNavigationBar? getNavigationBar(BuildContext context) {
    if (!hasNavigationBar) return null;
    return CustomNavigationBar(controller: navigationBarController, goBack: goBack);
  }

  //返回
  void goBack(){
    Get.back();
  }
}

class BaseRefreshController extends BaseController {

  ///是否可以刷新
  var refreshEnable = false.obs;

  ///是否正在下拉刷新
  bool get isRefreshing => _isRefreshing;
  var _isRefreshing = false;

  ///是否可以加载更多
  var loadMoreEnable = false.obs;

  ///是否正在加载更多
  bool get isLoadingMore => _isLoadingMore;
  var _isLoadingMore = false;

  ///刷新控制器
  late final easyRefreshController = EasyRefreshController();

  ///分页当前页码
  int curPage = 1;

  Future<void> willRefresh() async {
    _isRefreshing = true;
    await onRefresh();
  }
  Future<void> onRefresh() async {}

  void startRefresh(){
    easyRefreshController.callRefresh();
  }

  void stopRefresh(){
    easyRefreshController.finishRefresh();
    _isRefreshing = false;
  }

  Future<void> willLoadMore() async {
    _isLoadingMore = true;
    await onLoadMore();
  }
  Future<void> onLoadMore() async {}

  void startLoadMore(){
    easyRefreshController.callLoad();
  }

  void stopLoadMore(bool hasMore){
    easyRefreshController.finishLoad(hasMore ? IndicatorResult.success : IndicatorResult.noMore);
    _isLoadingMore = false;
  }
}

class BaseRefreshView<T extends BaseRefreshController> extends BaseView<T> with RefreshPage {

}

///可加载更多和下拉刷新的
mixin RefreshPage<T extends BaseRefreshController> on BasePage<T> {

  bool get refreshEnable => controller.refreshEnable.value;
  bool get isRefreshing => controller.isRefreshing;
  bool get loadMoreEnable => controller.loadMoreEnable.value;
  bool get isLoadingMore => controller.isLoadingMore;
  EasyRefreshController get easyRefreshController => controller
      .easyRefreshController;

  @override
  Widget wrapContentWidget(BuildContext context, Widget content){
    var child = super.wrapContentWidget(context, content);
    if ((refreshEnable || loadMoreEnable) && pageStatus == PageStatus.normal) {
      return getEasyRefresh(child);
    }

    return child;
  }

  EasyRefresh getEasyRefresh(Widget child){
    return EasyRefresh(
      child: child,
      controller: easyRefreshController,
      onRefresh: refreshEnable ? controller.willRefresh : null,
      onLoad: loadMoreEnable ? controller.willLoadMore : null,
    );
  }
}

mixin ProviderPage on BasePage {

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

mixin WillScrollKeyboardDismiss on BasePage{

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
    if(notification.dragDetails != null) {
      final context = Get.context;
      if (context != null) {
        FocusScope.of(context).requestFocus(FocusNode());
      }
    }
    return true;
  }
}