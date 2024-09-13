Pod::Spec.new do |s|
  s.name         = "Chat"
  s.version      = "2.2.1"
  s.summary      = "Swift Chat SDK"
  s.description  = "A Swift Chat SDK which handle all backend communication with Async SDK and Chat Server."
  s.homepage     = "https://pubgi.sandpod.ir/chat/ios/chat"
  s.license      = "MIT"
  s.author       = { "Hamed Hosseini" => "hamed8080@gmail.com" }
  s.platform     = :ios, "10.0"
  s.swift_versions = "5.6"
  s.source       = { :git => "https://pubgi.sandpod.ir/chat/ios/chat.git", :tag => s.version }
  s.source_files = "Sources/Chat/**/*.{h,swift,xcdatamodeld,m,momd}"
  s.resources = "Sources/Chat/Resources/*.xcdatamodeld"
  s.frameworks  = "Foundation" , "CoreData" , "Contacts", "CoreServices"
  s.dependency "Async" , '~> 2.1.0'
  s.dependency "Additive" , '~> 1.2.2'
  s.dependency "Logger" , '~> 1.2.2'
  s.dependency "ChatExtensions", '~> 2.2.1'
end
