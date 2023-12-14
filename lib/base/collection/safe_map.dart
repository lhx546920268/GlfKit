
import 'collection_utils.dart' as collection_utils;
import 'dart:math' as math;

//字典工具类
extension MapUtils on Map {

  T? get<T>(dynamic key){
    dynamic value = this[key];
    if(value != null){
      if(value is T){
        return value;
      }else{

        if(T == String){
          return value.toString() as T;
        }else if(T == int){
          if(value is String){
            value = int.tryParse(value) as T?;
            return value == null ? 0 : value;
          }else if(value is double){
            return value.toInt() as T;
          }
        }else if(T == double){
          if(value is String){
            value = double.tryParse(value);
            return value == null ? 0 : value;
          }else if(value is int){
            return value.toDouble() as T;
          }
        }else if(T == bool){
          if(value is String){
            String str = value.toLowerCase();
            value = (str == 'true' || str == 'yes') ? true : false;
            return value as T;
          }else if(value is double || value is int){
            value = value > 0 ? true : false;
            return value as T;
          }
        }
      }
    }

    return null;
  }
}

///安全的map
class SafeMap{

  ///当前的值
  Map? get value {
    return _value;
  }
  Map? _value;
  
  ///是否为空
  bool get isEmpty => collection_utils.isEmpty(_value);

  ///当值为空是 返回默认值，只对 int, double, bool 有效
  final bool toDefaultValue;

  SafeMap(Map? value, {this.toDefaultValue = true}){
    if(value is Map){
      _value = value;
    }
  }

  T? get<T>(dynamic key){
    if(this.value != null){
      T value = this.value!.get(key);
      if(value != null){
        return value;
      }
    }

    if(toDefaultValue){
      if(T == int){
        return 0 as T;
      }else if(T == double){
        return 0.0 as T;
      } else if(T == bool){
        return false as T;
      }
    }

    return null;
  }

  String stringForKey(dynamic key){
    String value = get(key);
    return value;
  }

  int intForKey(dynamic key){
    int value = get(key);
    return value;
  }

  double doubleForKey(dynamic key){
    double value = get(key);
    return value;
  }

  bool boolForKey(dynamic key){
    bool value = get(key);
    return value;
  }

  List listForKey(dynamic key){
    List value = get(key);
    return value;
  }

  SafeMap map(dynamic key, {bool useTempSafeMap = true}){
    return SafeMap(value != null ? value![key]: null);
  }

  List<T>? getList<T, R>(dynamic key, GetListForEach<T, R> forEach, {int? max}){
    List<T> result = [];
    List? list = get(key);
    if(list is List && list.length > 0){
      int maxCount = list.length;
      if(max != null && max != 0){
        maxCount = max;
      }
      for(int i = 0;i < maxCount; i ++){
        var value = forEach(list[i], i);
        if(value != null){
          result.add(value);
        }
      }
    }

    return result;
  }

  List<T>? forEach<T>(dynamic key, SafeMapForEach<T> safeMapForEach, {bool useTempSafeMap = true, bool map = true, int? max}){
    List list = get(key);
    return forEachList(list, safeMapForEach, useTempSafeMap: useTempSafeMap, max: max, map: map);
  }

  List<T>? forEachList<T>(List? list, SafeMapForEach<T> safeMapForEach, {bool useTempSafeMap = true, bool map = true, int? max}){
    List<T>? result = map ? [] : null;
    
    if(list is List && list.length > 0){
      int maxCount = list.length;
      if(max != null && max != 0){
        maxCount = math.min(max, maxCount);
      }
      for(int i = 0;i < maxCount; i ++){
        var value = safeMapForEach(useTempSafeMap ? _getTempSafeMap(list[i]) : SafeMap(list[i]), i);
        if(map && value != null){
          result!.add(value);
        }
      }
    }

    return result;
  }

  ///临时使用
  SafeMap? _tempSafeMap;
  SafeMap _getTempSafeMap(Map value){
    if(_tempSafeMap == null){
      _tempSafeMap = SafeMap(value);
    }
    _tempSafeMap!._value = value;
    return _tempSafeMap!;
  }
}

typedef SafeMapForEach<T> = T Function(SafeMap map, int index);
typedef GetListForEach<T, R> = T Function(R value, int index);