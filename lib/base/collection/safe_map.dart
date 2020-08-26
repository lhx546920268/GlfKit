
extension on Map {

  T get<T>(String key){
    dynamic value = this[key];
    if(value != null){
      if(value is T){
        return value;
      }else{

        if(T == String){
          return value.toString() as T;
        }else if(T == int){
          if(value is String){
            value = int.tryParse(value) as T;
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
  Map<String, dynamic> value;

  ///当值为空是 返回默认值，只对 int, double, bool 有效
  final bool toDefaultValue;

  SafeMap(Map<String, dynamic> value, {this.toDefaultValue = true}){
    if(value is Map<String, dynamic>){
      this.value = value;
    }
  }

  T get<T>(String key){
    if(this.value != null){
      T value = this.value.get(key);
      if(value != null){
        return value;
      }
    }

    if(toDefaultValue){
      if(T == int || T == double){
        return 0 as T;
      }else if(T == bool){
        return false as T;
      }
    }

    return null;
  }

  SafeMap map(String key){
    if(this.value != null){
      dynamic value = this.value[key];
      if(value is Map<String, dynamic>){
        return SafeMap(value);
      }
    }
    return null;
  }
}