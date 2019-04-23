import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:micro_flutter_alipay/micro_flutter_alipay.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final Alipay alipay;

  const MyApp({Key key, this.alipay}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Alipay alipay = Alipay();
    alipay.registerApp();

    return AlipayProvider(
      alipay: alipay,
      child: MaterialApp(
        home: Home(alipay: alipay),
      ),
    );
  }
}

class Home extends StatefulWidget {
  Home({
    Key key,
    @required this.alipay,
  }) : super(key: key);

  final Alipay alipay;

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<Home> {
  StreamSubscription<Map<String, String>> _pay;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  void _listenPay(Map<String, String> resp) {
    String content = "pay: ${resp}";
    _showTips('支付', content);
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
    if (_pay != null) {
      _pay.cancel();
    }
    super.dispose();
  }

  //不要把支付秘钥放到本地
  void _onPay() {
    widget.alipay.payOrder(
      orderInfo:
          'app_id=2019040163782036&biz_content=%7B%22body%22%3A%221%E5%88%86%2F%E6%9D%A1%22%2C%22out_trade_no%22%3A%22a5d134aa63014dee8456fdc1409e3f8f%22%2C%22product_code%22%3A%22QUICK_MSECURITY_PAY%22%2C%22seller_id%22%3A%222088431796501714%22%2C%22subject%22%3A%22%E7%9F%AD%E4%BF%A1%3A1115159959747825664%22%2C%22total_amount%22%3A%221.00%22%7D&charset=utf-8&format=json&method=alipay.trade.app.pay&notify_url=http%3A%2F%2F95vwz5.natappfree.cc%2Fpay%2Fali%2FpayBack.json&return_url=http%3A%2F%2Fwoquanke.com&sign=YIIvO%2FtYvuHjt9fxF%2BEzShHoipc5Fwn2oUhybDp8VqOXp8wxKNvP6xPTV5154n3wg9ORGSJdBmUl48cjv12ZAG6LOOx7TD6jWjzCfGviXRTM%2Fgs45dAXc0oMYt%2BvHQKSU%2BEFI%2BmZvEze8kuAmS%2BYoCfKyhePbq%2BOUJQxNccGh%2B9VyYqfWybiFD4StqanA2xmttk8tfYmxDl9aIUwkUW40Msr4ulR0FK2rlUte%2FU2SoiZ5K0IIyZYqd8Ij%2Ba0u7xGAA0MoqtxZGH%2BeSMzQxSdZW9lX2%2BZRk%2BuK%2BNV%2FGUQg%2BirvqfzlmvegqiMjOySR7vChJCnAgR00Gw%2Fi6mT2bvsWA%3D%3D&sign_type=RSA2&timestamp=2019-04-24+01%3A48%3A42&version=1.0',
    );
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    _pay = widget.alipay.payResp().listen(_listenPay);

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
