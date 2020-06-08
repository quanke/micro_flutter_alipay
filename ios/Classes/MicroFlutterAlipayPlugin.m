#import "MicroFlutterAlipayPlugin.h"
#import <AlipaySDK/AlipaySDK.h>


@implementation MicroFlutterAlipayPlugin {
    FlutterMethodChannel * _channel;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"micro_flutter_alipay"
                                     binaryMessenger:[registrar messenger]];
    MicroFlutterAlipayPlugin* instance = [[MicroFlutterAlipayPlugin alloc] initWithChannel:channel];
    [registrar addApplicationDelegate:instance];
    [registrar addMethodCallDelegate:instance channel:channel];
}

static NSString * const METHOD_ALI_PAY_INSTALLED = @"alipayInstalled";
static NSString * const METHOD_PAY = @"pay";


static NSString * const METHOD_ON_PAY = @"onPay";
static NSString * const METHOD_ON_INIT = @"onInit";


static NSString * const ARGUMENT_KEY_ORDER_INFO = @"orderInfo";

static NSString * const ARGUMENT_KEY_URL_SCHEME = @"urlScheme";

NSString * urlScheme = @"alipay";

-(instancetype)initWithChannel:(FlutterMethodChannel *)channel {
    self = [super init];
    if (self) {
        _channel = channel;
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([METHOD_ALI_PAY_INSTALLED isEqualToString:call.method]) {
        BOOL isAlipayInstalled = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"alipay:"]];
        result([NSNumber numberWithBool:isAlipayInstalled]);
    } else if ([METHOD_PAY isEqualToString:call.method]) {
        NSString * orderInfo = call.arguments[ARGUMENT_KEY_ORDER_INFO];
        
        NSString * scheme = [self fetchUrlScheme];
        [[AlipaySDK defaultService] payOrder:orderInfo fromScheme:scheme callback:^(NSDictionary *resultDic) {
            [self -> _channel invokeMethod:METHOD_ON_PAY arguments:resultDic];
        }];
        result(nil);
    } else if([METHOD_ON_INIT isEqualToString:call.method]){
        urlScheme = call.arguments[ARGUMENT_KEY_URL_SCHEME];
        result(nil);
    }
    else {
        result(FlutterMethodNotImplemented);
    }
}

-(NSString *)fetchUrlScheme{
    NSDictionary * infoDic = [[NSBundle mainBundle] infoDictionary];
    NSArray * types = [infoDic objectForKey:@"CFBundleURLTypes"];
    for (NSDictionary * type in types) {
        if([urlScheme isEqualToString: [type objectForKey:@"CFBundleURLName"]]){
            return [type objectForKey:@"CFBundleURLSchemes"][0];
        }
    }
    return nil;
}

# pragma mark - AppDelegate

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self handleOpenURL:url];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [self handleOpenURL:url];
}

-(BOOL)handleOpenURL:(NSURL *)url {
    if ([url.host isEqualToString:@"safepay"]) {
        // 支付跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            [self -> _channel invokeMethod:METHOD_ON_PAY arguments:resultDic];
        }];
        
        // 授权跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic) {
            [self -> _channel invokeMethod:METHOD_ON_PAY arguments:resultDic];
        }];
        
        return YES;
    }
    return NO;
}

@end
