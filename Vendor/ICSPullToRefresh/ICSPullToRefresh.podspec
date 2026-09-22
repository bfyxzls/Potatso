Pod::Spec.new do |s|
  s.name             = 'ICSPullToRefresh'
  s.version          = '0.6.0-ci'
  s.summary          = 'Vendored ICSPullToRefresh patched for Xcode 15 / Swift 5'
  s.homepage         = 'https://github.com/icodesign/ICSPullToRefresh.Swift'
  s.license          = { :type => 'MIT' }
  s.author           = 'iCodesign'
  s.source           = { :path => '.' }
  s.ios.deployment_target = '12.0'
  s.swift_version    = '5.0'
  s.source_files     = '*.swift'
end
