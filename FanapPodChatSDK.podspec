
Pod::Spec.new do |s|

  s.name         = "FanapPodChatSDK"
  s.version      = "0.10.3.1"
  s.summary      = "Fanap's POD Chat SDK"
  s.description  = "This Package is used for creating chat apps for companies whoes want to use Fanap Chat Services; This Package will use Fanap-Pod-Async-SDK"
  s.homepage     = "https://github.com/FanapSoft/pod-chat-ios-sdk"
  s.license      = "MIT"
  s.author       = { "Hamed Hosseini" => "hamed8080@gmail.com" }
  s.platform     = :ios, "10.0"
  s.swift_versions = "4.0"
  s.source       = { :git => "https://github.com/FanapSoft/pod-chat-ios-sdk.git", :tag => s.version }
  s.source_files = "Sources/FanapPodChatSDK/**/*.{h,swift,xcdatamodeld,m,momd}"
  s.resources = "Sources/FanapPodChatSDK/*.xcdatamodeld"
  s.frameworks  = "Foundation" , "CoreData" , "Contacts"
  s.dependency "FanapPodAsyncSDK" , '~> 0.10.0.2'

#   s.dependency 'FanapPodAsyncSDK'
#   s.subspec 'FanapPodAsyncSDK' do |ss|
#       ss.source_files         = 'Users/hamedhosseini/Desktop/WorkSpace/ios/Fanap/Fanap-Async-SDK/**/*.{h,swift,xcdatamodeld,m,momd}'
#       ss.resources            = "Users/hamedhosseini/Desktop/WorkSpace/ios/Fanap/Fanap-Async-SDK/*.xcdatamodeld"
#       ss.dependency "Starscream" , '~> 3.0.5'
#       ss.dependency "Sentry" , '~> 4.3.1'
#   end
   
  s.dependency "Sentry" , '~> 4.3.1'

end
