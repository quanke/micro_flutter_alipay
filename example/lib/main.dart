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
          'app_id=2019040163782036&biz_content=%7B%22body%22%3A%221%E5%88%86%2F%E6%9D%A1%22%2C%22out_trade_no%22%3A%220b4e8729402d4abba4bcb2d91dc4346d%22%2C%22product_code%22%3A%22QUICK_MSECURITY_PAY%22%2C%22seller_id%22%3A%222088431796501714%22%2C%22subject%22%3A%22%E7%9F%AD%E4%BF%A1%3A1121316475949420544%22%2C%22total_amount%22%3A%221.00%22%7D&charset=utf-8&format=json&method=alipay.trade.app.pay&notify_url=http%3A%2F%2F95vwz5.natappfree.cc%2Fpay%2Fali%2FpayBack.json&return_url=http%3A%2F%2Fwoquanke.com&sign=PnVfr0bKsejhY9E3fe9mwyFKBQU7BAVYnXc8giKayHtytP2lr1K9rM15lsk0EKV2LX1zO5KWbVAl5Q%2BNpgZN7Yi1k3uu3rXAGpTEZQorjimmqD31MK8rWOCrP3mjHXueOecHDkJqAFpcdmclW8GwxcQsYQwX74JEPpTN7MSF9THG8m8obGGcE0tzHuitutAMMwq02Kf%2F3ZRXluvnbJyE03iznkswne%2FfwayO0CoV4TURYL8%2BJVT0RaIRy6JidfMVeUeJXDtfhO2IMiW7XJFpMfd%2F0APAZ8qjubL9%2FnYJi6AOJwcKfCtN%2BJA23eK6laAaOMZtzWpmBJ9j7%2FYmWtQiXg%3D%3D&sign_type=RSA2&timestamp=2019-04-25+15%3A34%3A59&version=1.0',
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
