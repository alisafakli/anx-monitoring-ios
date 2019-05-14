#
# Be sure to run `pod lib lint ANXMonitoringIOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ANXMonitoringIOS'
  s.version          = '1.0.4'
  s.summary          = 'Anexia Version Monitoring Framework'
  s.swift_version    = '4.0'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Anexia Version Monitoring Framework to collecting Dependency versions & licenses to update them when necessary.
                       DESC

  s.homepage         = 'https://github.com/anx-asafakli/anx-monitoring-ios'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'anx-asafakli' => 'asafakli@anexia-it.com' }
  s.source           = { :git => 'https://github.com/anx-asafakli/anx-monitoring-ios.git', :tag => s.version}
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'Core/*.{h,m,swift}'
  #s.source_files = 'Classes/**/*.{h,m,swift}'
  #"FOLDERNAME1/*.{swift}", "FOLDERNAME2/*.{swift}"
  # s.resource_bundles = {
  #   'ANXMonitoringIOS' => ['ANXMonitoringIOS/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
