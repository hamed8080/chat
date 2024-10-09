Pod::Spec.new do |s|
  s.name         = "Chat"
  s.version      = "1.0.0"
  s.summary      = "Swift ChatCall SDK"
  s.description  = "Swift Chat Call SDK provides video and audio calling facilities."
  s.homepage     = "https://pubgi.fanapsoft.ir/chat/ios/chat-call"
  s.license      = "MIT"
  s.author       = { "Hamed Hosseini" => "hamed8080@gmail.com" }
  s.platform     = :ios, "10.0"
  s.swift_versions = "4.0"
  s.source       = { :git => "https://pubgi.fanapsoft.ir/chat/ios/chat-call.git", :tag => s.version }
  s.source_files = "Sources/ChatCall/**/*.{h,swift,xcdatamodeld,m,momd}"
  s.resources = "Sources/ChatCall/Resources/*.xcdatamodeld"
  s.frameworks  = "Foundation" , "CoreData" , "Contacts", "CoreServices"
  s.dependency "Chat" , '~> 1.3.2'
  s.dependency 'WebRTC', :git => 'https://github.com/stasel/WebRTC.git', :tag => '107.0.0'
end
