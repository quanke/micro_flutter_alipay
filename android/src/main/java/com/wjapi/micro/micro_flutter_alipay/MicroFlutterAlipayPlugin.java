package com.wjapi.micro.micro_flutter_alipay;

import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.util.Log;

import com.alipay.sdk.app.AuthTask;
import com.alipay.sdk.app.PayTask;

import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * MicroFlutterAlipayPlugin
 */
public class MicroFlutterAlipayPlugin implements MethodCallHandler {

    private static final String TAG = MicroFlutterAlipayPlugin.class.getSimpleName();

    public MicroFlutterAlipayPlugin(Registrar registrar, MethodChannel channel) {
        this.registrar = registrar;
        this.channel = channel;
    }

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "micro_flutter_alipay");
        channel.setMethodCallHandler(new MicroFlutterAlipayPlugin(registrar, channel));
    }


    private static final String METHOD_ALI_PAY_INSTALLED = "aliPayInstalled";

    private static final String METHOD_PAY = "pay";

    private static final String METHOD_ON_PAY = "onPay";

    private static final String ARGUMENT_KEY_ORDER_INFO = "orderInfo";

    private static final String ARGUMENT_KEY_SHOW_LOADING = "showLoading";

    private final Registrar registrar;
    private final MethodChannel channel;

    @Override
    public void onMethodCall(MethodCall call, Result result) {
//    if (call.method.equals("getPlatformVersion")) {
//      result.success("Android " + android.os.Build.VERSION.RELEASE);
//    } else {
//      result.notImplemented();
//    }

        if (METHOD_ALI_PAY_INSTALLED.equals(call.method)) {
            boolean aliPayInstalled = false;
            try {
                final PackageManager packageManager = registrar.context().getPackageManager();
                PackageInfo info = packageManager.getPackageInfo("com.eg.android.AlipayGphone", PackageManager.GET_SIGNATURES);
                aliPayInstalled = info != null;
            } catch (PackageManager.NameNotFoundException e) {
                Log.e(TAG, "获取支付宝包异常", e);
            }
            result.success(aliPayInstalled);
        } else if (METHOD_PAY.equals(call.method)) {
            final String orderInfo = call.argument(ARGUMENT_KEY_ORDER_INFO);
            final boolean showLoading = call.argument(ARGUMENT_KEY_SHOW_LOADING);
            Runnable pay = new Runnable() {
                @Override
                public void run() {
                    PayTask task = new PayTask(registrar.activity());
                    Map<String, String> result = task.payV2(orderInfo, showLoading);
                    channel.invokeMethod(METHOD_ON_PAY, result);
                }
            };
            new Thread(pay).start();
            result.success(null);
        } else {
            result.notImplemented();
        }


    }
}
