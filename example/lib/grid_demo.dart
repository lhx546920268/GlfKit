
import 'package:GlfKit/list/section.dart';
import 'package:GlfKit/list/section_adapter.dart';
import 'package:GlfKit/list/section_grid_view.dart';
import 'package:flutter/material.dart';

class SectionGridViewDemo extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SectionGridViewState();
  }
}

class _SectionGridViewState extends State<SectionGridViewDemo> {

  MyAdapter _adapter;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if(_adapter == null){
      _adapter = MyAdapter();
      _adapter.onReload = (){
        setState(() {
          _changeCount();
        });
      };
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("SectionGridView"),
      ),
      body: Container(
        child: SizedBox(
          width: 300,
          child: SectionGridView.builder(adapter: _adapter),
        ),
      ),
    );
  }

  void _changeCount(){
    _adapter.count = _adapter.count == 20 ? 30 : 20;
  }
}

class MyAdapter extends SectionGridAdapter{

  int count = 30;

  @override
  Widget getItem(BuildContext context, IndexPath indexPath) {
    // TODO: implement getItem

    EdgeInsetsDirectional inset = getSectionInsets(indexPath.section);
    double totalWidth = crossAxisExtent - getCrossAxisSpacing(indexPath.section) - inset.start - inset.end;
    double width;
    double height;

    switch(indexPath.item % 3){
      case 0 :
        width = totalWidth / 3;
        height = 200;
        break;
      case 1 :
        width = totalWidth / 3 * 2;
        height = 80;
        break;
      case 2 :
        width = totalWidth / 3 * 2;
        height = 200.0 - 80 - 5;
        break;
    }

    return GestureDetector(
      key: GlobalKey(debugLabel: 'item ${indexPath.section}, ${indexPath.item}'),
      onTap: (){
        reloadData();
      },
      child: Container(
        width: width,
        height: height,
        color: Colors.red,
        child: Center(
          child: Text('${indexPath.item}'),
        ),
      ),
    );
  }

  @override
  int numberOfItems(int section) {
    return this.count;
  }

  @override
  int numberOfSections() {
    // TODO: implement numberOfSections
    return 10;
  }

  @override
  double getMainAxisSpacing(int section) {
    return 5;
  }

  @override
  double getCrossAxisSpacing(int section) {
    return 5;
  }

  @override
  EdgeInsetsDirectional getSectionInsets(int section) {
    return EdgeInsetsDirectional.fromSTEB(10, 8, 10, 8);
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
  double getFooterItemSpacing(int section) {
    // TODO: implement getFooterItemSpacing
    return 5;
  }

  @override
  double getHeaderItemSpacing(int section) {
    // TODO: implement getHeaderItemSpacing
    return 5;
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