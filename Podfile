# Use CocoaPods CDN (faster / more reliable on GitHub Actions than Specs.git)
source 'https://cdn.cocoapods.org/'

platform :ios, '12.0'
use_frameworks!
inhibit_all_warnings!

# Exact versions from the original Podfile.lock — do not loosen these without testing.
def library
    pod 'KissXML', '5.2.2'
    pod 'ICSMainFramework', :path => "./Library/ICSMainFramework/"
    pod 'MMWormhole', '2.0.0'
    pod 'KeychainAccess', '4.2.2'
end

def tunnel
    pod 'MMWormhole', '2.0.0'
end

def socket
    pod 'CocoaAsyncSocket', '7.4.3'
end

def model
    pod 'RealmSwift', '2.10.2'
end

target "Potatso" do
    pod 'Aspects', :path => "./Library/Aspects/"
    pod 'Cartography', '3.1.0'
    pod 'AsyncSwift', '2.0.4'
    pod 'SwiftColor', '1.0.0'
    pod 'Appirater', '2.0.5'
    pod 'Eureka', '4.3.1'
    pod 'MBProgressHUD', '1.0.0'
    pod 'CallbackURLKit', :path => "./Library/CallbackURLKit"
    pod 'ICDMaterialActivityIndicatorView', '0.1.2'
    pod 'ICSPullToRefresh', :path => './Vendor/ICSPullToRefresh'
    pod 'ISO8601DateFormatter', '0.8'
    pod 'Alamofire', '4.9.1'
    pod 'ObjectMapper', '4.2.0'
    pod 'CocoaLumberjack/Swift', '3.0.0'
    # Vendored Core (Xcode 15 fix). Do NOT use CocoaPods trunk 4.x / 5.0.x tags.
    pod 'PSOperations', :path => './Vendor/PSOperations'
    tunnel
    library
    socket
    model
end

target "PacketTunnel" do
    tunnel
    socket
end

target "PacketProcessor" do
    socket
end

target "TodayWidget" do
    pod 'Cartography', '3.1.0'
    pod 'SwiftColor', '1.0.0'
    library
    socket
    model
end

target "PotatsoLibrary" do
    library
    model
    pod 'YAML-Framework', :path => "./Library/YAML-Framework"
end

target "PotatsoModel" do
    model
end

target "PotatsoLibraryTests" do
    library
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
      config.build_settings['CODE_SIGN_IDENTITY'] = ''
      config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ''
      # Force Swift 5 for all pods (ObjectMapper 2.x / other Swift 3 pods break on Xcode 15)
      config.build_settings['SWIFT_VERSION'] = '5.0'
    end
  end
end
