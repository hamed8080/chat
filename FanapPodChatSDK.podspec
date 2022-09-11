
Pod::Spec.new do |s|

  s.name         = "FanapPodChatSDK"
  s.version      = "0.10.5.0"
  s.summary      = "Fanap's POD Chat SDK"
  s.description  = "This Package is used for creating chat apps for companies whoes want to use Fanap Chat Services; This Package will use Fanap-Pod-Async-SDK"
  s.homepage     = "https://pubgi.fanapsoft.ir/chat/ios/fanappodchatsdk"
  s.license      = "MIT"
  s.author       = { "Hamed Hosseini" => "hamed8080@gmail.com" }
  s.platform     = :ios, "10.0"
  s.swift_versions = "4.0"
  s.source       = { :git => "https://pubgi.fanapsoft.ir/chat/ios/fanappodchatsdk.git", :tag => s.version }
  s.source_files = "Pod-Chat-iOS-SDK/Chat/**/*.{h,swift,xcdatamodeld,m,momd}"
  s.resources = "Pod-Chat-iOS-SDK/Chat/*.xcdatamodeld"
  s.frameworks  = "Foundation" , "CoreData" , "Contacts"
  s.dependency "FanapPodAsyncSDK" , '~> 0.10.5.0'

#   s.dependency 'FanapPodAsyncSDK'
#   s.subspec 'FanapPodAsyncSDK' do |ss|
#       ss.source_files         = 'Users/hamedhosseini/Desktop/WorkSpace/ios/Fanap/Fanap-Async-SDK/**/*.{h,swift,xcdatamodeld,m,momd}'
#       ss.resources            = "Users/hamedhosseini/Desktop/WorkSpace/ios/Fanap/Fanap-Async-SDK/*.xcdatamodeld"
#       ss.dependency "Starscream" , '~> 3.0.5'
#       ss.dependency "Sentry" , '~> 4.3.1'
#   end
   
  s.dependency "Sentry" , '~> 4.3.1'

end
