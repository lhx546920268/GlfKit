
//集合是否为空
import 'dart:convert';

///判断集合是否为空
bool isEmpty(dynamic obj){

  if(obj is Iterable){
    Iterable iterable = obj;
    return iterable.length == 0;
  }else if(obj is Map){
    Map map = obj;
    return map.length == 0;
  }

  return obj == null;
}

extension JsonUtils on JsonCodec {

  ///解析返回数组
  List decodeList(String source,
      {Object reviver(Object key, Object value)}){
    try{
      var value = decode(source, reviver: reviver);
      if(value is List){
        return value;
      }
    }catch(_){

    }
    return null;
  }

  ///解析返回字典
  Map decodeMap(String source,
      {Object reviver(Object key, Object value)}){
    try{
      var value = decode(source, reviver: reviver);
      if(value is Map){
        return value;
      }
    }catch(_){
      
    }
    return null;
  }
}