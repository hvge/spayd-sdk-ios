#
# Be sure to run `pod lib lint spayd-sdk-ios.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'spayd-sdk-ios'
  s.version          = '1.1.0'
  s.summary          = 'Smart Payment Descriptor for iOS.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  The SmartPayment project is a full iOS implementation of Smart Payment Descriptor which is a standard for QR code payments on mobile devices in Czech Republic. If you're interested in full specification, please go to http://qr-platba.cz website.
                       DESC

  s.homepage         = 'https://github.com/ma-myair/spayd-sdk-ios'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Páll Zoltán' => 'pallzoltan@gmail.com' }
  s.source           = { :git => 'https://github.com/ma-myair/spayd-sdk-ios.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  # s.source_files = 'Sources/SmartPayment/*'

  s.subspec 'SmartPayment' do |ss|
    ss.source_files  = "Sources/SmartPayment/**/*"
  end
  
  # s.resource_bundles = {
  #   'spayd-sdk-ios' => ['spayd-sdk-ios/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
