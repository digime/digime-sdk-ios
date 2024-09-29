require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name = 'DigiPlugin'
  s.version = package['version']
  s.summary = package['description']
  s.license = { :type => package['license'], :file => "LICENSE" }
  s.homepage = package['repository']['url']
  s.author = package['author']
  s.source = { :git => package['repository']['url'], :tag => s.version.to_s }

  s.platform         = :ios, '17.0'
  s.swift_version    = '5.10'
  s.requires_arc     = true

  s.source_files = 'ios/Sources/**/*.{swift,h,m,c,cc,mm,cpp}'
  s.ios.deployment_target = '13.0'

  s.dependency 'Capacitor'
  s.dependency 'Cordova'
  s.dependency 'ModelsR5', '~> 0.5.0'
  s.dependency 'DigiMeSDK', '~> 5.0.8'
  s.dependency 'DigiMeHealthKit', '~> 5.0.8'

  s.frameworks = 'Foundation', 'Security', 'UIKit', 'SafariServices'
  s.resources = ['ios/Sources/DigiMePlugin/Resources/**/*']

end
