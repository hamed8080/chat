
Pod::Spec.new do |s|

  s.name         = "FanapPodChatSDK"
  s.version      = "0.10.0.0"
  s.summary      = "Fanap's POD Chat SDK"
  s.description  = "This Package is used for creating chat apps for companies whoes want to use Fanap Chat Services; This Package will use Fanap-Pod-Async-SDK"
  s.homepage     = "https://github.com/FanapSoft/pod-chat-ios-sdk"
  s.license      = "MIT"
  s.author       = { "Hamed Hosseini" => "hamed8080@gmail.com" }
  s.platform     = :ios, "10.0"
  s.swift_versions = "4.0"
  s.source       = { :git => "https://github.com/FanapSoft/pod-chat-ios-sdk.git", :tag => s.version }
  s.source_files = "Pod-Chat-iOS-SDK/Chat/**/*.{h,swift,xcdatamodeld,m,momd}"
  s.resources = "Pod-Chat-iOS-SDK/Chat/*.xcdatamodeld"
  s.frameworks  = "Foundation" , "CoreData" , "Contacts"
  s.dependency "FanapPodAsyncSDK" , '~> 0.9.5.1'
  s.dependency "Alamofire" , '~> 4.8.2'
  s.dependency "Sentry" , '~> 4.3.1'

end
