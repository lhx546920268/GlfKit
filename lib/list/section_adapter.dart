
import 'package:GlfKit/list/section.dart';
import 'package:flutter/widgets.dart';

/// 列表分区适配器
abstract class SectionAdapter {

  ///要刷新了
  VoidCallback onReload;
  void reloadData() {
    if (onReload != null) {
      _totalCount = null;
      _sectionInfos.clear();
      onReload();
    }
  }

  ///列表交叉轴大小
  double crossAxisExtent;

  ///Item总数
  int _totalCount;
  final List<SectionInfo> _sectionInfos = List();

  ///构建item 组件，内部使用，通常情况下子类不需要重写这个
  Widget buildItem(BuildContext context, int position) {
    SectionInfo info = sectionInfoForPosition(position);
    if (info.isHeader(position)) {
      return getSectionHeader(context, info.section);
    } else if (info.isFooter(position)) {
      return getSectionFooter(context, info.section);
    } else {
      return getItem(
          context,
          IndexPath(
              section: info.section, item: info.getItemPosition(position)));
    }
  }

  ///item总数，内部使用，通常情况下子类不需要重写这个
  int getItemCount() {
    if (_totalCount == null) {
      ///计算列表行数量
      int numberOfSection = numberOfSections();
      int count = 0;

      if (shouldExistHeader()) {
        count++;
      }

      for (int i = 0; i < numberOfSection; i++) {
        int numberOfItem = numberOfItems(i);

        ///保存section信息
        SectionInfo sectionInfo = _createSection(i, numberOfItem, count);
        _sectionInfos.add(sectionInfo);

        count += numberOfItem;
        if (sectionInfo.isExistHeader) count++;
        if (sectionInfo.isExistFooter) count++;
      }

      if (shouldExistFooter()) {
        count++;
      }
      _totalCount = count;
    }
    return _totalCount;
  }

  ///创建sectionInfo
  SectionInfo _createSection(int section, int numberOfItems, int position) {
    SectionInfo sectionInfo = SectionInfo(
        section: section,
        numberItems: numberOfItems,
        sectionBegin: position,
        isExistHeader: shouldExistSectionHeader(section),
        isExistFooter: shouldExistSectionFooter(section),
        isHeaderStick: shouldSectionHeaderStick(section));

    return sectionInfo;
  }

  ///通过position获取对应的sectionInfo
  SectionInfo sectionInfoForPosition(int position) {
    if (_totalCount == null || _totalCount == 0) return null;

    var info = _sectionInfos[0];
    for (int i = 1; i < _sectionInfos.length; i++) {
      var sectionInfo = _sectionInfos[i];
      if (sectionInfo.sectionBegin > position) {
        break;
      } else {
        info = sectionInfo;
      }
    }
    return info;
  }

  ///获取对应section
  SectionInfo sectionInfoForSection(int section) {
    if (section >= 0 && section < _sectionInfos.length){
      return _sectionInfos[section];
    }
    return null;
  }

  ///section总数
  int numberOfSections() {
    return 1;
  }

  ///每个section的item数量
  int numberOfItems(int section);

  ///获取item
  Widget getItem(BuildContext context, IndexPath indexPath);

  ///类似UITableView.tableHeaderView
  bool shouldExistHeader() {
    return false;
  }

  ///类似UITableView.tableFooterView
  bool shouldExistFooter() {
    return false;
  }

  ///section 头部
  bool shouldExistSectionHeader(int section) {
    return false;
  }

  ///section 底部
  bool shouldExistSectionFooter(int section) {
    return false;
  }

  ///是否需要吸顶悬浮
  bool shouldSectionHeaderStick(int section) {
    return false;
  }

  Widget getHeader(BuildContext context) {
    throw UnimplementedError();
  }

  Widget getFooter(BuildContext context) {
    throw UnimplementedError();
  }

  Widget getSectionHeader(BuildContext context, int section) {
    throw UnimplementedError();
  }

  Widget getSectionFooter(BuildContext context, int section) {
    throw UnimplementedError();
  }
}

///section 网格适配器
abstract class SectionGridAdapter extends SectionAdapter {

  /// 滑动方向的 item间隔
  double getMainAxisSpacing(int section) {
    return 0;
  }

  /// 与滑动方向交叉 的item间隔
  double getCrossAxisSpacing(int section) {
    return 0;
  }

  ///section边距
  EdgeInsetsDirectional getSectionInsets(int section) {
    return EdgeInsetsDirectional.zero;
  }

  ///header和item的间距
  double getHeaderItemSpacing(int section) {
    return 0;
  }

  ///footer和item的间距
  double getFooterItemSpacing(int section) {
    return 0;
  }

  @override
  GridSectionInfo sectionInfoForPosition(int position) {
    return super.sectionInfoForPosition(position);
  }

  @override
  GridSectionInfo sectionInfoForSection(int section) {
    return super.sectionInfoForSection(section);
  }

  @override
  GridSectionInfo _createSection(int section, int numberOfItems, int position) {
    GridSectionInfo sectionInfo = GridSectionInfo(
        section: section,
        numberItems: numberOfItems,
        sectionBegin: position,
        isExistHeader: shouldExistSectionHeader(section),
        isExistFooter: shouldExistSectionFooter(section),
        isHeaderStick: shouldSectionHeaderStick(section),
        mainAxisSpacing: getMainAxisSpacing(section),
        crossAxisSpacing: getCrossAxisSpacing(section),
        sectionInsets: getSectionInsets(section),
        headerItemSpacing: getHeaderItemSpacing(section),
        footerItemSpacing: getFooterItemSpacing(section));

    return sectionInfo;
  }
}