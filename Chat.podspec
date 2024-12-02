Pod::Spec.new do |s|
  s.name         = "Chat"
  s.version      = "3.0.0"
  s.summary      = "Swift Chat SDK"
  s.description  = "A Swift Chat SDK which handle all backend communication with Async SDK and Chat Server."
  s.homepage     = "https://pubgi.sandpod.ir/chat/ios/chat"
  s.license      = "MIT"
  s.author       = { "Hamed Hosseini" => "hamed8080@gmail.com" }
  s.platform     = :ios, "13.0"
  s.swift_versions = "5.9"
  s.source       = { :git => "https://pubgi.sandpod.ir/chat/ios/chat.git", :tag => s.version }
  s.source_files = "Sources/Chat/**/*.{h,swift,xcdatamodeld,m,momd}"
  s.resources = "Sources/Chat/Resources/*.xcdatamodeld"
  s.frameworks  = "Foundation" , "CoreData" , "Contacts", "CoreServices"
  s.dependency "ChatExtensions"
end
