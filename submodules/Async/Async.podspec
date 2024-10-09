Pod::Spec.new do |s|
  s.name         = "Async"
  s.version      = "2.2.1"
  s.summary      = "Async"
  s.description  = "Async SDk manage all communication with Chat Server."
  s.homepage     = "https://pubgi.sandpod.ir/chat/ios/async"
  s.license      = "MIT"
  s.author       = { "Hamed" => "hamed8080@gmail.com" }
  s.platform     = :ios, "10.0"
  s.swift_versions = "5.6"
  s.source       = { :git => "https://pubgi.sandpod.ir/chat/ios/async", :tag => s.version }
  s.source_files = "Sources/Async/**/*.{h,swift,m}"
  s.framework  = "Foundation"
  s.dependency "Starscream"  , '~> 3.1.1'
  s.dependency "Additive" , '~> 1.2.4'
  s.dependency "Logger" , '~> 1.2.4'
  s.dependency "Mocks" , '~> 1.2.5'
end
