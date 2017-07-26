#
# Be sure to run `pod lib lint CMTabbarView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CMTabbarView'
  s.version          = '0.1.3'
  s.summary          = 'CMTabbarView is a scrolling tab bar,provides a simple to implement view'

  s.description      = 'CMTabbarView is a scrolling tab bar,provides a simple to implement view like NetEase News'

  s.homepage         = 'https://github.com/moyunmo/CMTabbarView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'momo605654602@gmail.com' => 'moyunmo@hotmail.com' }
  s.source           = { :git => 'https://github.com/moyunmo/CMTabbarView.git', :tag => s.version.to_s }
  # s.social_media_url = ''

  s.ios.deployment_target = '8.0'

  s.source_files = 'CMTabbarView/Classes/**/*'
  
  # s.resource_bundles = {
  #   'CMTabbarView' => ['CMTabbarView/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
