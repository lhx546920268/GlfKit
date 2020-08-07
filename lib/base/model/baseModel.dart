
import 'package:GlfKit/base/collection/safe_map.dart';

///基础数据模型
abstract class BaseModel{

  BaseModel();

  BaseModel.fromJson(Map<String, dynamic> map){
    parseData(SafeMap(map));
  }

  BaseModel.fromSafeMap(SafeMap map){
    parseData(map);
  }

  ///解析数据
  void parseData(SafeMap map);
}