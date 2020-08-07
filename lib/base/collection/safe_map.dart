
///安全的map
class SafeMap{

  Map<String, dynamic> value;

  SafeMap(Map<String, dynamic> value){
    if(value is Map<String, dynamic>){
      this.value = value;
    }
  }

  T get<T>(String key){
    if(this.value != null){
      dynamic value = this.value[key];
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
    }

    if(T == int || T == double){
      return 0 as T;
    }else if(T == bool){
      return false as T;
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