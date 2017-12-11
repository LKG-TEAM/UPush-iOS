Pod::Spec.new do |s|
s.name             = 'UPushSDK'
s.version          = '1.0.0'
s.summary          = 'UPush SDK for iOS.'
s.requires_arc        = true
s.homepage         = 'https://github.com/LKG-TEAM/UPush-iOS'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'linkstec@linkstec.com' => 'linkstec@linkstec.com' }
s.platform     = :ios, "7.0"
s.source           = { :git => 'https://github.com/LKG-TEAM/UPush-iOS.git' }
s.source_files  = "UPush/*.{h}"
s.vendored_libraries = "UPush/libUPush.a"
s.frameworks = 'UIKit'
s.resources = ["UPush/UPush.bundle", "UPush/UPush.der"]
s.public_header_files = 'UPush/*.{h}'
s.libraries  = 'z'
s.module_name = 'UPushSDK'
end
