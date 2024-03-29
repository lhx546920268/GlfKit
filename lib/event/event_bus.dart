
import 'dart:collection';

typedef EventCallback = void Function(dynamic value);

class Event {

  final Object? sender;
  Event({this.sender});
}

///事件处理中心
class EventBus {

  ///单例
  static EventBus? _defaultBus;
  static EventBus get defaultBus => _getInstance();

  ///内部构造方法
  EventBus._();

  ///观察者
  Map _subscribers = HashMap<String, Set<EventCallback>>();

  ///单例
  static EventBus _getInstance(){
    if(_defaultBus == null){
      _defaultBus = EventBus._();
    }
    return _defaultBus!;
  }

  ///订阅
  void subscribe(String name, EventCallback callback){

    Set? set = _subscribers[name];
    if(set == null){
      set = LinkedHashSet<EventCallback>();
      _subscribers[name] = set;
    }
    set.add(callback);
  }

  ///取消订阅
  void unsubscribe(String name, EventCallback callback){
    Set? set = _subscribers[name];
    if(set != null && set.isNotEmpty){
      set.remove(callback);
      if(set.isEmpty){
        _subscribers.remove(name);
      }
    }
  }

  ///发送一个事件
  void post(String name, {dynamic value}){
    Set? set = _subscribers[name];
    if(set != null && set.isNotEmpty){
      for(EventCallback callback in set){
        callback(value);
      }
    }
  }
}