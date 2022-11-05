
Pod::Spec.new do |s|

  s.name         = "FanapPodChatSDK"
  s.version      = "1.1.0"
  s.summary      = "Fanap's POD Chat SDK"
  s.description  = "This Package is used for creating chat apps for companies whoes want to use Fanap Chat Services; This Package will use Fanap-Pod-Async-SDK"
  s.homepage     = "https://pubgi.fanapsoft.ir/chat/ios/fanappodchatsdk"
  s.license      = "MIT"
  s.author       = { "Hamed Hosseini" => "hamed8080@gmail.com" }
  s.platform     = :ios, "12.0"
  s.swift_versions = "4.0"
  s.source       = { :git => "https://pubgi.fanapsoft.ir/chat/ios/fanappodchatsdk.git", :tag => s.version }
  s.source_files = "Sources/FanapPodChatSDK/**/*.{h,swift,xcdatamodeld,m,momd}"
  s.resources = "Sources/FanapPodChatSDK/*.xcdatamodeld"
  s.frameworks  = "Foundation" , "CoreData" , "Contacts"
  #s.vendored_frameworks = "Frameworks/WebRTC.xcframework"#inside root folder of podhcat sdk
  s.dependency "FanapPodAsyncSDK" , '~> 1.1.0'
  s.dependency "WebRTC-lib" , '107.0.0'
  s.dependency "Sentry" , '~> 4.3.1'
end
