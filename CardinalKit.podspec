#
# Be sure to run `pod lib lint CardinalKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CardinalKit'
  s.version          = '1.0.0'
  s.summary          = 'https://cardinalkit.org/'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/CardinalKit/CardinalKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'ELP2', :file => 'LICENSE' }
  s.author           = { 'CardinalKit' => 'https://cardinalkit.org/' }
  s.source           = { :git => 'https://github.com/CardinalKit/CardinalKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://cardinalkit.org/'

  s.ios.deployment_target = '11.0'

  s.source_files = 'CardinalKit/Source/**/*'
  
  s.resource_bundles = {
      'CardinalKit' => ['CardinalKit/Assets/*.png', 'CardinalKit/Assets/*.pdf']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'Foundation'
  
  #ResearchKit
  # s.dependency 'ResearchKit', :git => 'https://github.com/ResearchKit/ResearchKit.git', :branch => 'master'
  
  #Securely storing key-value pairs on keychain
  s.dependency 'SAMKeychain',      '~> 1.5.2'

  #Local Storage
  s.dependency 'RealmSwift',       '~> 4.4.1'
  
  #Networking and responses
  s.dependency 'ObjectMapper',     '~> 3.3.0'
  s.dependency 'SwiftyJSON',       '~> 4.1.0'
  s.dependency 'ReachabilitySwift','~> 3'

  #Compressing files
  s.dependency 'Zip',              '~> 1.1.0'
end
