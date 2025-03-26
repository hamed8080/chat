Pod::Spec.new do |s|
  s.name         = "ChatCore"
  s.version      = "2.2.1"
  s.summary      = "ChatCore"
  s.description  = "ChatCore SDK consists of all prerequisite models and protocols for Chat SDK."
  s.homepage     = "https://pubgi.sandpod.ir/chat/ios/chat-core"
  s.license      = "MIT"
  s.author       = { "Hamed Hosseini" => "hamed8080@gmail.com" }
  s.platform     = :ios, "13.0"
  s.swift_versions = "5.9"
  s.source       = { :git => "https://pubgi.sandpod.ir/chat/ios/chat-core", :tag => s.version }
  s.source_files = "Sources/ChatCore/**/*.{h,swift,xcdatamodeld,m,momd}"
  s.frameworks  = "Foundation"
  s.dependency "Async"
end
