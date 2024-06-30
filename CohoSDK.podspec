#
#  Be sure to run `pod spec lint CohoSDK.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "CohoSDK"
  spec.version      = "1.0.4-beta1"
  spec.summary      = "Coho AI Events SDK for Swift."
  spec.description  = <<-DESC
  Send events to Coho AI with the SDK for Swift.
                   DESC
  spec.homepage     = "https://coho.ai"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.authors             = "Coho AI"
  spec.source       = { :git => "https://github.com/coho-ai/swift-sdk.git", :tag => "#{spec.version}" }
  spec.ios.deployment_target = "12.0"
  spec.swift_version = "5.3"
  spec.source_files  = "Sources/**/*"

end
