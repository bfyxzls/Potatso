Pod::Spec.new do |s|
  s.name             = 'PSOperations'
  s.version          = '5.0.6-ci'
  s.summary          = 'Vendored PSOperations Core patched for Xcode 15 / Swift 5.9+'
  s.homepage         = 'https://github.com/pluralsight/PSOperations'
  s.license          = { :type => 'Apache-2.0' }
  s.author           = 'Pluralsight'
  s.source           = { :path => '.' }
  s.ios.deployment_target = '12.0'
  s.swift_version    = '5.0'
  s.source_files     = '*.swift'
  s.exclude_files    = 'Info.plist'
end
