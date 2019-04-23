import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:micro_flutter_alipay/src/rsa.dart';

/// Author: quanke (woquanke.com)
/// Date: 2019/4/22

class Alipay {
  static const String _METHOD_ALI_PAY_INSTALLED = 'alipayInstalled';
  static const String _METHOD_PAY = 'pay';

  static const String _METHOD_ON_PAY = 'onPay';

  static const String _ARGUMENT_KEY_ORDER_INFO = 'orderInfo';
  static const String _ARGUMENT_KEY_SHOW_LOADING = 'showLoading';

  static const String SIGN_TYPE_RSA = 'RSA';
  static const String SIGN_TYPE_RSA2 = 'RSA2';

  static const int PRIVATE_KEY_RSA2_MIN_LENGTH = 2048;

  static const MethodChannel _channel = MethodChannel('micro_flutter_alipay');

  final StreamController<Map<String, String>> _payRespStreamController =
      StreamController<Map<String, String>>.broadcast();

  Future<void> registerApp() async {
    _channel.setMethodCallHandler(_handleMethod);
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case _METHOD_ON_PAY:
        _payRespStreamController.add(call.arguments as Map<String, String>);
        break;
    }
  }

  Stream<Map<String, String>> payResp() {
    return _payRespStreamController.stream;
  }

  Future<bool> isAlipayInstalled() async {
    return (await _channel.invokeMethod(_METHOD_ALI_PAY_INSTALLED)) as bool;
  }

  Future<void> payOrderJson({
    @required String orderInfo,
    String signType = SIGN_TYPE_RSA2,
    @required String privateKey,
    bool isShowLoading = true,
  }) {
    assert(orderInfo != null && orderInfo.isNotEmpty);
    assert((signType == SIGN_TYPE_RSA &&
            privateKey != null &&
            privateKey.isNotEmpty) ||
        (signType == SIGN_TYPE_RSA2 &&
            privateKey != null &&
            privateKey.length >= PRIVATE_KEY_RSA2_MIN_LENGTH));

    return payOrderMap(
      orderInfo: json.decode(orderInfo) as Map<String, String>,
      signType: signType,
      privateKey: privateKey,
      isShowLoading: isShowLoading,
    );
  }

  Future<void> payOrder({
    @required String orderInfo,
    bool isShowLoading = true,
  }) {
    assert(orderInfo != null && orderInfo.isNotEmpty);

    return payOrderSign(
      orderInfo: orderInfo,
      isShowLoading: isShowLoading,
    );
  }

  Future<void> payOrderMap({
    @required Map<String, String> orderInfo,
    String signType = SIGN_TYPE_RSA2,
    @required String privateKey,
    bool isShowLoading = true,
  }) {
    assert(orderInfo != null && orderInfo.isNotEmpty);
    assert((signType == SIGN_TYPE_RSA &&
            privateKey != null &&
            privateKey.isNotEmpty) ||
        (signType == SIGN_TYPE_RSA2 &&
            privateKey != null &&
            privateKey.length >= PRIVATE_KEY_RSA2_MIN_LENGTH));

    orderInfo.putIfAbsent('sign_type', () => signType);

    String charset = orderInfo['charset'];
    Encoding encoding;
    if (charset != null && charset.isNotEmpty) {
      encoding = Encoding.getByName(charset);
    }
    if (encoding == null) {
      encoding = utf8;
    }

    String param = _param(orderInfo, encoding);
    String sign = _sign(orderInfo, signType, privateKey);

    return payOrderSign(
      orderInfo:
          '$param&sign=${Uri.encodeQueryComponent(sign, encoding: encoding)}',
      isShowLoading: isShowLoading,
    );
  }

  Future<void> payOrderSign({
    @required String orderInfo,
    bool isShowLoading = true,
  }) {
    assert(orderInfo != null && orderInfo.isNotEmpty);

    return _channel.invokeMethod(
      _METHOD_PAY,
      <String, dynamic>{
        _ARGUMENT_KEY_ORDER_INFO: orderInfo,
        _ARGUMENT_KEY_SHOW_LOADING: isShowLoading,
      },
    );
  }

  String _param(Map<String, String> map, Encoding encoding) {
    List<String> keys = map.keys.toList();
    return List<String>.generate(keys.length, (int index) {
      String key = keys[index];
      String value = map[key];
      return '$key=${Uri.encodeQueryComponent(value, encoding: encoding)}';
    }).join('&');
  }

  String _sign(Map<String, String> map, String signType, String privateKey) {
    /// 参数排序
    List<String> keys = map.keys.toList();
    keys.sort();
    String content = List<String>.generate(keys.length, (int index) {
      String key = keys[index];
      String value = map[key];
      return '$key=$value';
    }).join('&');
    String sign;
    switch (signType) {
      case SIGN_TYPE_RSA:
        sign = base64
            .encode(RsaSigner.sha1Rsa(privateKey).sign(utf8.encode(content)));
        break;
      case SIGN_TYPE_RSA2:
        sign = base64
            .encode(RsaSigner.sha256Rsa(privateKey).sign(utf8.encode(content)));
        break;
      default:
        throw UnsupportedError('Alipay sign_type($signType) is not supported!');
    }
    return sign;
  }
}
