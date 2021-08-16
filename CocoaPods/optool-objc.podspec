#
# Be sure to run `pod lib lint optool-objc.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'optool-objc'
  s.version          = '0.1.0'
  s.summary          = 'Interface of optool for ObjC'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  Support: install, uninstall
                       DESC

  s.homepage         = 'https://github.com/Magic-Unique/optool-objc'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Magic-Unique' => 'Magic-Unique@qq.com' }
  s.source           = { :git => 'https://github.com/Magic-Unique/optool-objc.git', :tag => "#{s.version}" }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.10'

  s.source_files = 'optool-objc/**/*'
  
  # s.resource_bundles = {
  #   'optool-objc' => ['optool-objc/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'optool'
  
end
