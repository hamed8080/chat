
Pod::Spec.new do |s|

  s.name         = "FanapPodChatSDK"
  s.version      = "0.2.3.3"
  s.summary      = "Fanap's POD Chat SDK"
  s.description  = "This Package is used for creating chat apps for companies whoes want to use Fanap Chat Services; This Package will use Fanap-Pod-Async-SDK"
  s.homepage     = "https://github.com/smartPodLand/Pod-Chat-iOS-SDK"
  s.license      = "MIT"
  s.author       = { "Mahyar" => "mahyar.zhiani@icloud.com" }
  s.platform     = :ios, "11.2"
  s.source       = { :git => "https://github.com/smartPodLand/Pod-Chat-iOS-SDK.git", :tag => s.version }
  s.source_files = "Pod-Chat-iOS-SDK/Chat/**/*.{h,swift,xcdatamodeld,m,momd}"
  s.frameworks  = "Foundation" , "CoreData" , "Contacts"
  s.dependency "FanapPodAsyncSDK"
  s.dependency "Alamofire"

end
