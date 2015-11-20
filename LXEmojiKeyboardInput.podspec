#
#  Be sure to run `pod spec lint QFToolBar.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "LXEmojiKeyboardInput"
  s.version      = "0.2"
  s.summary      = "低耦合的emoji表情的自定义键盘，以及用于消息发送的输入框"
  s.homepage     = "https://github.com/xx-li/LXEmojiKeyboardInput"
  s.license      = 'MIT'

  s.author       = { "xx-li" => "x@devlxx.com" }
 
  s.platform     = :ios, '6.0'

  s.source       = { :git => "https://github.com/xx-li/LXEmojiKeyboardInput.git", :tag => "0.2" }

  s.source_files  = 'LXEmojiKeyboardInput/*'
  s.exclude_files = 'LXEmojiKeyboardInputDemo'
  s.resource_bundles = {  
    'LXEmojiKeyboardInput' => ['Pod/**/**']
  }

  s.frameworks = 'Foundation', 'CoreGraphics', 'UIKit'
  s.requires_arc = true
  s.dependency 'Masonry', '~> 0.6.3'

end
