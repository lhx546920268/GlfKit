

import 'package:dio/dio.dart';
import 'package:GlfKit/base/collection/safe_map.dart';
import 'package:flutter/cupertino.dart';

mixin BaseHttpTask {

  ///http响应
  Response get response => _response;
  Response _response;

  ///所有json数据
  SafeMap rawData;

  ///用到的data
  SafeMap data;

  ///api状态码
  int code;

  ///提示信息
  String message;

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
  Options options;

  ///
  Dio get dio;

  ///用来取消的
  CancelToken _cancelToken;

  ///是否正在请求
  bool get isRunning => _running;
  bool _running = false;

  ///是否已取消
  bool get isCancelled => _cancelled;
  bool _cancelled = false;

  bool get isSuccess;

  bool get isNetworkError => code == null;

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

    _running = true;
    try {
      _cancelToken = CancelToken();
      Options options = this.options ?? Options();
      options.method = method;
      _response = await dio.request(path, queryParameters: params, options: options, cancelToken: _cancelToken);
    } on DioError catch (error) {
      if(error.type != DioErrorType.CANCEL){
        print('${dio.options.baseUrl}$path request error $error');
      }
      code = null;
    }

    if(!isCancelled && _response != null){
      await processResult();
    }
  }

  void cancel() {
    if(isRunning && !isCancelled && _cancelToken != null){
      _running = false;
      _cancelled = true;
      _cancelToken.cancel('cancelled');
    }
  }

  ///解析
  @protected
  Future<void> processResult() async {

  }

  @protected
  void onSuccess();

  String get get => 'GET';
  String get post => 'POST';
  String get put => 'PUT';
  String get delete => 'DELETE';
  String get head => 'HEAD';
}