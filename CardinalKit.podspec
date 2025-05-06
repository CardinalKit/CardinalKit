#
# Be sure to run `pod lib lint CardinalKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CardinalKit'
  s.version          = '2.2.0'
  s.summary          = 'https://cardinalkit.org/'

  s.description      = 'CardinalKit empowers the digital health community to rapidly prototype and build modern, interoperable, scalable digital health solutions on a variety of platforms.'

  s.homepage         = 'https://github.com/CardinalKit/CardinalKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'CardinalKit' => 'https://cardinalkit.org/' }
  s.source           = { :git => 'https://github.com/CardinalKit/CardinalKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '15.0'

  s.source_files = 'CardinalKit/Source/**/*'
  
  s.resource_bundles = {
      'CardinalKit' => ['CardinalKit/Assets/*.png', 'CardinalKit/Assets/*.pdf']
  }

  s.frameworks = 'UIKit', 'Foundation'
  
  s.dependency 'Granola'

  #Local Storage
  s.dependency 'RealmSwift', '~> 10'
  
  #Networking and responses
  s.dependency 'ObjectMapper', '~> 3'
  s.dependency 'ReachabilitySwift', '~> 3'

  #Compressing files
  s.dependency 'Zip', '~> 2.1.2'
  
  #Firebase
  s.dependency 'Firebase', '~> 10'
  s.dependency 'FirebaseFirestore', '~> 10'
  s.dependency 'FirebaseAuth', '~> 10'
  s.dependency 'FirebaseStorage', '~> 10'
  s.dependency 'FirebaseAnalytics', '~> 10'

  s.static_framework = true
  s.public_header_files = 'CardinalKit/Source/Components/Header.h'
end
