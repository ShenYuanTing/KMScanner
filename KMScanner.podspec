#
# Be sure to run `pod lib lint KMScanner.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'KMScanner'
  s.version          = '1.4.0'
  s.summary          = 'CodeScan.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/ShenYuanTing/KMScanner/tree/1.0.0'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'shenhao' => 'shenhao@mfhcd.com' }
  s.source           = { :git => 'https://github.com/ShenYuanTing/KMScanner.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'KMScanner/Classes/**/*'

   s.resource_bundles = {
     'KMScanner' => ['KMScanner/Assets/*']
   }
   s.framework  = "AVFoundation"

end
