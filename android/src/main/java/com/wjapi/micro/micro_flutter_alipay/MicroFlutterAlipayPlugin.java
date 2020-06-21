package com.wjapi.micro.micro_flutter_alipay;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.AsyncTask;
import android.os.Build;
import android.util.Log;

import com.alipay.sdk.app.AuthTask;
import com.alipay.sdk.app.PayTask;

import java.lang.ref.WeakReference;
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


    private final Registrar registrar;
    private final MethodChannel channel;

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

    private static final String METHOD_ON_INIT = "onInit";

    private static final String ARGUMENT_KEY_URL_SCHEME = "urlScheme";

    @Override
    public void onMethodCall(MethodCall call, Result result) {

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

            final WeakReference<Activity> activityRef = new WeakReference<>(registrar.activity());
            new AsyncTask<String, String, Map<String, String>>() {
                @Override
                protected Map<String, String> doInBackground(String... params) {
                    Activity activity = activityRef.get();
                    if (activity != null && !activity.isFinishing()) {
                        PayTask task = new PayTask(activity);
                        return task.payV2(orderInfo, showLoading);
                    }
                    return null;
                }

                @Override
                protected void onPostExecute(Map<String, String> result) {
                    if (result != null) {
                        Activity activity = activityRef.get();
                        if (activity != null && !activity.isFinishing()) {
                            if (channel != null) {
                                channel.invokeMethod(METHOD_ON_PAY, result);
                            }
                        }
                    }
                }
            }.execute();

//
//
//            Runnable pay = new Runnable() {
//                @Override
//                public void run() {
//                    PayTask task = new PayTask(registrar.activity());
//                    Map<String, String> result = task.payV2(orderInfo, showLoading);
//                    Log.d(TAG, "run: " + result);
//                    channel.invokeMethod(METHOD_ON_PAY, result);
//                }
//            };
//            new Thread(pay).start();
            result.success(null);
        } else if (METHOD_ON_INIT.equals(call.method)) {
            final String urlScheme = call.argument(ARGUMENT_KEY_URL_SCHEME);
            result.success(null);
        } else {
            result.notImplemented();
        }


    }
}
