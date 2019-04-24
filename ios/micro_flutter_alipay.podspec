#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'micro_flutter_alipay'
  s.version          = '0.0.1'
  s.summary          = '支付宝支付'
  s.description      = <<-DESC
支付宝支付
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
    # 支付宝
  s.static_framework = true
  s.dependency 'AlipaySDK-iOS', '~> 15.5.5'
  s.ios.deployment_target = '8.0'
end

