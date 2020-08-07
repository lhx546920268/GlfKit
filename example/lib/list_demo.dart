

import 'package:GlfKit/list/section.dart';
import 'package:GlfKit/list/section_adapter.dart';
import 'package:GlfKit/list/section_list_view.dart';
import 'package:flutter/material.dart';

class SectionListDemo extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SectionListDemoState();
  }
}

class _SectionListDemoState extends State<SectionListDemo>{

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text('SectionListDemo'),),
      body: SectionListView.builder(adapter: _MyAdapter()),
    );
  }
}

class _MyAdapter extends SectionAdapter {

  @override
  int numberOfSections() {
    // TODO: implement numberOfSections
    return 10;
  }

  @override
  int numberOfItems(int section) {
    // TODO: implement numberOfItems
    return 30;
  }

  @override
  Widget getItem(BuildContext context, IndexPath indexPath) {
    // TODO: implement getItemCount
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: <Widget>[
        ListTile(
          title: Text('$indexPath'),
        ),
        Divider(height: 0.5,)
      ],
    );
  }

  @override
  bool shouldExistSectionHeader(int section) {
    // TODO: implement shouldExistSectionHeader
    return true;
  }

  @override
  bool shouldSectionHeaderStick(int section) {
    // TODO: implement shouldSectionHeaderStick
    return true;
  }

  @override
  bool shouldExistSectionFooter(int section) {
    // TODO: implement shouldExistSectionFooter
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
    // TODO: implement getSectionFooter
    return Container(
      key: GlobalKey(debugLabel: 'footer $section'),
      height: 45,
      color: Colors.green,
      child: Center(
        child: Text('Footer $section'),
      ),
    );
  }

}
