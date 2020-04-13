import 'package:flutter/material.dart';
import 'dart:async';

import 'package:micro_flutter_alipay/micro_flutter_alipay.dart';

void main() => runApp(Home());

final Alipay alipay = Alipay();

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<Home> {

  @override
  void initState() {
    super.initState();
    alipay.init();
    initPlatformState();
  }

  void _listenPay(resp) {
    String content = "pay: ${resp}";

    print('支付：${resp}');
//    _showTips('支付', content);
  }

  void _showTips(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  //不要把支付秘钥放到本地
  void _onPay() {
    alipay.payOrder(
      orderInfo:
          'app_id=2019040163782036&biz_content=%7B%22body%22%3A%221%E5%88%86%2F%E6%9D%A1%22%2C%22out_trade_no%22%3A%22cef2b7a646e343ffb72844e470ddd814%22%2C%22product_code%22%3A%22QUICK_MSECURITY_PAY%22%2C%22seller_id%22%3A%222088431796501714%22%2C%22subject%22%3A%22%E7%9F%AD%E4%BF%A1%3A1123537927608078336%22%2C%22total_amount%22%3A%221.00%22%7D&charset=utf-8&format=json&method=alipay.trade.app.pay&notify_url=http%3A%2F%2Fdev.microapi.59api.com%2Fpay%2Fali%2FpayBack.json&return_url=http%3A%2F%2Fwoquanke.com&sign=dPUj2%2BfdyI5CIqfqCKv7hJmniJp7XgXZe2utPKiCB9nRIJepotxeRbWpKWgNjCMPT7FmY6gStmfAIsWa5oa8p5KznUfkZ14nxVx4H7wKkjz4qU2qWkUmlODDYIZ2g2W3nLV9PEcF0EJrM9BvSj4fbSEC66rmDPOIAIEFa47ZkxgZa4jYwOIgz7GA9HzAA9JNqesSdNTgmtkRdXtYqN3c%2BXVVoWKeYCy0OkhY7q0OKnQuSM8SG4gBDOfZfCE5yNKezN5Oidb4YJf0w8WcMG6dzygl72eVuwP6APy0i%2FlqMUqA4A7EqmUQbSh0NlweXaTaUKaG5r9Oci0CyjOSpCcN6A%3D%3D&sign_type=RSA2&timestamp=2019-05-01+18%3A42%3A09&version=1.0',
    );
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    alipay.onPay().listen(_listenPay);

    setState(() {
//      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: RaisedButton(
            child: Text("pay"),
            onPressed: _onPay,
          ),
        ),
      ),
    );
  }
}
