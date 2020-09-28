
import 'package:GlfKit/theme/color_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PageIndicatorController extends ChangeNotifier {

  int get curPage => _curPage ?? 0;
  set curPage(int curPage){
    if(curPage != _curPage){
      _curPage = curPage;
      notifyListeners();
    }
  }
  int _curPage;
}

class PageIndicator extends StatefulWidget {

  final Color color;
  final Color selectedColor;
  final double size;
  final double margin;
  final Alignment alignment;
  final PageIndicatorController controller;
  final int numberOfPage;

  PageIndicator({
    Key key,
    this.color,
    this.selectedColor,
    this.margin,
    this.size,
    this.alignment,
    this.controller,
    @required this.numberOfPage
  }): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PageIndicatorState();
  }
}

class _PageIndicatorState extends State<PageIndicator> {

  @override
  Widget build(BuildContext context) {

    Widget child;
    if(widget.numberOfPage != null && widget.numberOfPage > 0){

      var size = widget.size ?? 10;
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(widget.numberOfPage, (index) => Container(
          width: size,
          height: size,
          margin: index != 0 ? EdgeInsets.only(left: widget.margin ?? 10) : null,
          decoration: BoxDecoration(
              color: index == widget.controller?.curPage ? widget.selectedColor ?? ColorTheme.themeColor : widget.color ?? Colors.grey[200],
              borderRadius: BorderRadius.all(Radius.circular(size / 2))
          ),
        )),
      );
    }

    return Container(
      width: double.infinity,
      alignment: widget.alignment ?? Alignment.bottomCenter,
      child: child,
    );
  }

  @override
  void initState() {
    widget.controller?.addListener(_onChange);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    setState(() {

    });
  }
}

