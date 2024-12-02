Pod::Spec.new do |s|
  s.name         = "ChatDTO"
  s.version      = "2.2.1"
  s.summary      = "ChatDTO"
  s.description  = "ChatDTO consists of requests and responses data object transfers for coding and encoding purposes only."
  s.homepage     = "https://pubgi.sandpod.ir/chat/ios/chat-dto"
  s.license      = "MIT"
  s.author       = { "Hamed Hosseini" => "hamed8080@gmail.com" }
  s.platform     = :ios, "13.0"
  s.swift_versions = "5.9"
  s.source       = { :git => "https://pubgi.sandpod.ir/chat/ios/chat-dto", :tag => s.version }
  s.source_files = "Sources/ChatDTO/**/*.{h,swift,xcdatamodeld,m,momd}"
  s.frameworks  = "Foundation", "CoreServices"
  s.dependency "ChatModels"
end
