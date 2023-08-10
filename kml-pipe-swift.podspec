#
# Be sure to run `pod lib lint kml-pipe-swift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'kml-pipe-swift'
  s.version          = '0.2.7'
  s.summary          = 'A short description of kml-pipe-swift.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
This package lets you deploy Kinetix ML pipelines from the Kinetix ML platform to native iOS apps.
                       DESC

  s.homepage         = 'https://www.kinetixml.com'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'GPLv3', :file => 'LICENSE' }
  s.author           = { 'MadeWithStone' => 'maxwell@kinetixml.com' }
  s.source           = { :git => 'https://github.com/Kinetix-ML/kml-pipe-swift.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '15.0'
  s.swift_version = '5.8'
  s.source_files = 'kml-pipe-swift/Classes/**/*'
  s.resources = 'kml-pipe-swift/Assets/**/*'
  s.resource_bundles = {'kml_pipe_swift' => ['kml-pipe-swift/Assets/**/*.{storyboard,xib,png,jsbundle,meta,tflite}']}

  
  # s.resource_bundles = {
  #   'kml-pipe-swift' => ['kml-pipe-swift/Assets/*.png']
  # }
  
  s.dependency 'TensorFlowLiteSwift/CoreML', '~> 2.4.0'
  s.dependency 'TensorFlowLiteSwift/Metal', '~> 2.4.0'
  # s.dependency 'GoogleMLKit/PoseDetection', '3.2.0'

  s.static_framework = true
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
end
