Pod::Spec.new do |s|
s.name             = "TagTextView"
s.version          = "1.0.2"
s.summary          = "UITextView with Mentions and Tags support for SwiftUI and UIKit"
s.homepage         = "https://github.com/Splash04/TagTextView"
s.license          = 'MIT'
s.author           = { "Igor Kharytaniuk" => "kharytaniuk@gmail.com" }
s.source           = { :git => "https://github.com/Splash04/TagTextView.git", :tag => s.version }
s.resource_bundle  = {"TagTextView.privacy"=>"Sources/PrivacyInfo.xcprivacy"}
s.requires_arc     = true
s.platform         = :ios, '15.0'
s.swift_version    = '5.0'
s.source_files     = 'Sources/TagTextView/**/*.swift'
end