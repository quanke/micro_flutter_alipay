#import "MicroFlutterAlipayPlugin.h"
#import <micro_flutter_alipay/micro_flutter_alipay-Swift.h>

@implementation MicroFlutterAlipayPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMicroFlutterAlipayPlugin registerWithRegistrar:registrar];
}
@end
