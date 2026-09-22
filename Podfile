# Use CocoaPods CDN (faster / more reliable on GitHub Actions than Specs.git)
source 'https://cdn.cocoapods.org/'

platform :ios, '9.0'
use_frameworks!
inhibit_all_warnings!

# Exact versions from the original Podfile.lock — do not loosen these without testing.
def library
    pod 'KissXML', '5.2.2'
    pod 'ICSMainFramework', :path => "./Library/ICSMainFramework/"
    pod 'MMWormhole', '2.0.0'
    pod 'KeychainAccess', '3.1.1'
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
    pod 'Cartography', '1.0.1'
    pod 'AsyncSwift', '2.0.4'
    pod 'SwiftColor', '0.4.0'
    pod 'Appirater', '2.0.5'
    pod 'Eureka', '4.1.1'
    pod 'MBProgressHUD', '1.0.0'
    pod 'CallbackURLKit', :path => "./Library/CallbackURLKit"
    pod 'ICDMaterialActivityIndicatorView', '0.1.2'
    pod 'ICSPullToRefresh', '0.6'
    pod 'ISO8601DateFormatter', '0.8'
    pod 'Alamofire', '4.2.0'
    pod 'ObjectMapper', '2.2.2'
    pod 'CocoaLumberjack/Swift', '3.0.0'
    pod 'PSOperations', '4.1.0'
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
    pod 'Cartography', '1.0.1'
    pod 'SwiftColor', '0.4.0'
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
      if config.build_settings['SWIFT_VERSION'].to_s.empty?
        config.build_settings['SWIFT_VERSION'] = '5.0'
      end
    end
  end
end
