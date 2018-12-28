
Pod::Spec.new do |s|

  s.name         = "Pod-Chat-iOS-SDK"
  s.version      = "0.2.4"
  s.summary      = "Fanap's POD Chat SDK"
  s.description  = "This Package is used for creating chat apps for companies whoes want to use Fanap Chat Services; This Package will use Fanap-Async-iOS-SDK"
  s.homepage     = "https://github.com/smartPodLand/Pod-Chat-iOS-SDK"
  s.license      = "MIT"
  s.author       = { "Mahyar" => "mahyar.zhiani@icloud.com" }
  s.platform     = :ios, "11.2"
  s.source       = { :git => "https://github.com/smartPodLand/Pod-Chat-iOS-SDK.git", :tag => s.version }
  s.frameworks  = "Foundation" , "CoreData" , "Contacts"
  s.dependency "Pod-Async-iOS-SDK"
  s.dependency "Alamofire"

end
