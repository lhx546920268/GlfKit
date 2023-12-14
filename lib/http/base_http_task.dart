

import 'package:GlfKit/base/def.dart';
import 'package:GlfKit/interaction/toast.dart';
import 'package:GlfKit/loading/loading.dart';
import 'package:dio/dio.dart';
import 'package:GlfKit/base/collection/safe_map.dart';
import 'package:flutter/cupertino.dart';

mixin BaseHttpTask {

  ///任务名称
  String get name => _name ?? runtimeType.toString();
  set name(String value){
    _name = value;
  }
  String? _name;

  ///http响应
  Response? get response => _response;
  Response? _response;

  ///所有json数据
  SafeMap? rawData;

  ///用到的data
  SafeMap? data;

  ///api状态码
  int? code;

  ///提示信息
  String? message;

  ///是否还有更多
  bool hasMore = false;

  ///页码
  int page = 1;

  ///每页数量
  int count = 20;

  ///http请求方式
  String get method => get;

  ///请求参数
  Map<String, dynamic> get params;

  ///api地址
  String get path;

  ///配置
  Options? options;

  ///
  Dio get dio;

  ///用来取消的
  CancelToken? _cancelToken;

  ///是否正在请求
  bool get isRunning => _running;
  bool _running = false;

  ///是否已取消
  bool get isCancelled => _cancelled;
  bool _cancelled = false;

  bool get isSuccess;

  bool get isNetworkError => code == null;

  ///用来提示错误信息和loading的
  BuildContext? context;

  ///是否提示错误信息
  bool shouldShowErrorMessage = false;

  ///是否显示loading
  bool shouldShowLoading = false;

  ///loading 延迟显示
  Duration loadingDelay = const Duration(milliseconds: 500);

  ///loading 文字
  String? loadingText;

  ///开始请求
  Future<void> start() async {
    if(_running){
      print("$runtimeType is running");
      return;
    }

    if(_cancelled){
      print("$runtimeType is cancelled");
      return;
    }

    if(shouldShowLoading && context != null){
      Loading.show(context!, delay: loadingDelay, text: loadingText);
    }

    await beforeStart();

    _running = true;
    try {
      _cancelToken = CancelToken();
      Options options = this.options ?? Options();
      options.method = method;
      _response = await dio.request(path, queryParameters: params, options: options, cancelToken: _cancelToken);
    } on DioException catch (exception) {
      if(exception.type != DioExceptionType.cancel){
        print('${dio.options.baseUrl}$path request exception $exception');
      }
      code = null;
    }

    if(!isCancelled){
      if(_response != null){
        await processResult();
      }
      if(isSuccess){
        onSuccess();
        await afterSuccess();
      }else{
        onFail();
      }
      onComplete();
    }
  }

  ///在开始请求前执行，主要是用于初始化一些需要异步获取的信息
  Future<void> beforeStart() async {

  }

  void cancel() {
    if(isRunning && !isCancelled && _cancelToken != null){
      _running = false;
      _cancelled = true;
      _cancelToken!.cancel('cancelled');
      onComplete();
    }
  }

  ///解析
  @protected
  Future<void> processResult() async {

  }

  @protected
  void onSuccess();

  ///在onSuccess后执行，主要是用于保存一些信息
  Future<void> afterSuccess() async {

  }

  @protected
  void onFail() {
    if(shouldShowErrorMessage && message != null && context != null){
      if(shouldShowLoading){
        Loading.dismiss(animate: false);
      }
      Toast.showText(context!, message!);
    }
  }

  List<ValueCallback<BaseHttpTask>> get completeCallbacks {
    if(_completeCallbacks == null){
      _completeCallbacks = [];
    }
    return _completeCallbacks!;
  }
  List<ValueCallback<BaseHttpTask>>? _completeCallbacks;

  void addCompleteCallback(ValueCallback<BaseHttpTask> callback){
    completeCallbacks.add(callback);
  }

  void removeCompleteCallback(ValueCallback<BaseHttpTask> callback) {
    completeCallbacks.remove(callback);
  }

  @protected
  void onComplete() {
    if(shouldShowLoading){
      Loading.dismiss();
    }
    if(_completeCallbacks != null){
      _completeCallbacks!.forEach((callback) {
        callback(this);
      });
    }
  }

  String get get => 'GET';
  String get post => 'POST';
  String get put => 'PUT';
  String get delete => 'DELETE';
  String get head => 'HEAD';
}