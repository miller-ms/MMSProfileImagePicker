#
# Be sure to run `pod lib lint MMSProfileImagePicker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "MMSProfileImagePicker"
  s.version          = "1.0.4"
  s.summary          = "A profile image selection view controller supporting image selection and editing behavior like in the contacts app."
  s.description      = <<-DESC
    This class supports the feature for selecting an image from the photo library or camera for use as a profile image. Before final selection, it presents an edit screen with a circle overalay to resize and position the image for cropping in a square whose side is the length of the circle's diameter.  An image can be submitted to the class for editing only.  With this class you can emulate the features of the contact app's profile image selection.
                       DESC

  s.homepage         = "https://github.com/miller-ms/MMSProfileImagePicker"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "William Miller" => "support@millermobilesoft.com" }
  s.source           = { :git => "https://github.com/miller-ms/MMSProfileImagePicker.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.2'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'MMSProfileImagePicker' => ['Pod/Assets/*.png']
  }

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'AVFoundation', 'CoreMedia', 'ImageIO'
  # s.dependency 'AFNetworking', '~> 2.3'
end
