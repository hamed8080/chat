
Pod::Spec.new do |s|

  s.name         = "FanapPodChatSDK"
  s.version      = "1.2.10"
  s.summary      = "Fanap's POD Chat SDK"
  s.description  = "This Package is used for creating chat apps for companies whoes want to use Fanap Chat Services; This Package will use Fanap-Pod-Async-SDK"
  s.homepage     = "https://pubgi.sandpod.ir/chat/ios/chat"
  s.license      = "MIT"
  s.author       = { "Hamed Hosseini" => "hamed8080@gmail.com" }
  s.platform     = :ios, "10.0"
  s.swift_versions = "4.0"
  s.source       = { :git => "https://pubgi.sandpod.ir/chat/ios/chat.git", :tag => s.version }
  s.source_files = "Sources/FanapPodChatSDK/**/*.{h,swift,xcdatamodeld,m,momd}"
  s.resources = "Sources/FanapPodChatSDK/Resources/*.xcdatamodeld"
  s.frameworks  = "Foundation" , "CoreData" , "Contacts", "CoreServices"
  s.dependency "FanapPodAsyncSDK" , '~> 1.2.3'

end
