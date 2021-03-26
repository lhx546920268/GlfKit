import 'package:GlfKit/http/base_http_task.dart';
import 'package:flutter/cupertino.dart';
import 'dart:collection';

///主要用于自动取消http请求
mixin TaskAutoCancelMixin<T extends StatefulWidget> on State<T> {

  ///用来在dispose之前 要取消的请求
  Set<BaseHttpTask> get currentTasks {
    if (_currentTasks == null) {
      _currentTasks = HashSet();
    }
    return _currentTasks!;
  }

  Set<BaseHttpTask>? _currentTasks;

  ///  添加需要取消的请求 在dealloc
  ///
  ///  @param task 请求
  ///  @param cancelTheSame 是否取消相同的任务 通过 task.name 来判断
  void addCanceledTask(BaseHttpTask task, {bool cancelTheSame = true}) {
    if (cancelTheSame && _currentTasks != null) {
      _currentTasks!.removeWhere((element) => element.name == task.name);
    }
    task.addCompleteCallback((value) {
      currentTasks.remove(value);
    });
    currentTasks.add(task);
  }

  @override
  void dispose() {
    if (_currentTasks != null) {
      _currentTasks!.forEach((task) {
        task.cancel();
      });
    }

    super.dispose();
  }
}
