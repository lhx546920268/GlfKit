
import 'package:GlfKit/base/collection/safe_map.dart';
import 'package:flutter/cupertino.dart';

export '../collection/safe_map.dart';

///基础数据模型
mixin BaseInfo {

  ///解析json
  T? fromJson<T>(Map? map){
    return fromMap(SafeMap(map));
  }

  T? fromMap<T>(SafeMap map){
    parseData(map);
    dynamic value = this;
    if(value is T){
      return value;
    }
    return null;
  }

  ///解析数据
  @protected
  void parseData(SafeMap map);
}