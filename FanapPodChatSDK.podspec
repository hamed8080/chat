
Pod::Spec.new do |s|

  s.name         = "FanapPodChatSDK"
  s.version      = "0.5.8.7"
  s.summary      = "Fanap's POD Chat SDK"
  s.description  = "This Package is used for creating chat apps for companies whoes want to use Fanap Chat Services; This Package will use Fanap-Pod-Async-SDK"
  s.homepage     = "https://github.com/Mahyar1990/Fanap-Chat-SDK"
  s.license      = "MIT"
  s.author       = { "Mahyar" => "mahyar.zhiani@icloud.com" }
  s.platform     = :ios, "10.0"
  s.source       = { :git => "https://github.com/Mahyar1990/Fanap-Chat-SDK.git", :tag => s.version }
  s.source_files = "Pod-Chat-iOS-SDK/Chat/**/*.{h,swift,xcdatamodeld,m,momd}"
  s.resources = "Pod-Chat-iOS-SDK/Chat/*.xcdatamodeld"
  s.frameworks  = "Foundation" , "CoreData" , "Contacts"
  s.dependency "FanapPodAsyncSDK" , '~> 0.5.3'
  s.dependency "Alamofire" , '~> 4.8.2'

end
