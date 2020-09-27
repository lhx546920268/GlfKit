

import 'package:GlfKit/list/section.dart';
import 'package:GlfKit/list/section_adapter.dart';
import 'package:GlfKit/list/section_list_view.dart';
import 'package:GlfKit/widget/navigation_bar.dart';
import 'package:GlfKit/widget/page.dart';
import 'package:flutter/material.dart';
import 'package:GlfKit/utils/route_utils.dart';

class SectionListDemo extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _SectionListDemoState();
  }
}

class _SectionListDemoState extends State<SectionListDemo> with StatefulPageState, SectionAdapterMixin{

  @override
  NavigationBarController configNavigationBar(BuildContext context){
    return NavigationBarController(title: 'SectionListView');
  }

  @override
  Widget getContentWidget(BuildContext context) {
    return SectionListView.builder(adapter: this);
  }

  @override
  int numberOfSections() {
    return 10;
  }

  @override
  int numberOfItems(int section) {
    return 30;
  }

  @override
  Widget getItem(BuildContext context, IndexPath indexPath) {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: <Widget>[
        GestureDetector(
          child: Container(
            height: 50,
            padding: EdgeInsets.only(left: 15, right: 15),
            alignment: Alignment.centerLeft,
            child: Text('$indexPath'),
          ),
          onTap: () {
            RouteUtils.pushAndRemoveUntil(context, RouteDemo(), 'SectionListDemo');
          },
        ),
        Divider(height: 0.5,)
      ],
    );
  }

  @override
  bool shouldExistSectionHeader(int section) {
    return true;
  }

  @override
  bool shouldSectionHeaderStick(int section) {
    return true;
  }

  @override
  bool shouldExistSectionFooter(int section) {
    return section % 2 != 0;
  }

  @override
  Widget getSectionHeader(BuildContext context, int section) {
    return Container(
      key: GlobalKey(debugLabel: 'header $section'),
      height: 45,
      color: Colors.blue,
      child: Center(
        child: Text('Header $section'),
      ),
    );
  }

  @override
  Widget getSectionFooter(BuildContext context, int section) {
    return Container(
      key: GlobalKey(debugLabel: 'footer $section'),
      height: 45,
      color: Colors.green,
      child: Center(
        child: Text('Footer $section'),
      ),
    );
  }

  @override
  bool shouldExistHeader() {
    return true;
  }

  @override
  bool shouldExistFooter() {
    return true;
  }

  @override
  Widget getHeader(BuildContext context) {
    return Container(
      height: 200,
      color: Colors.amber,
      child: Center(
        child: Text('Header'),
      ),
    );
  }

  @override
  Widget getFooter(BuildContext context) {
    return Container(
      height: 200,
      color: Colors.amber,
      child: Center(
        child: Text('Footer'),
      ),
    );
  }
}

class RouteDemo extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _RouteDemo();
  }
}

class _RouteDemo extends State<RouteDemo> with StatefulPageState  {

  @override
  NavigationBarController configNavigationBar(BuildContext context){
    return NavigationBarController(title: 'RouteDemo');
  }
}

