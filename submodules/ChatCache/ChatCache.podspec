Pod::Spec.new do |s|
  s.name         = "ChatCache"
  s.version      = "2.2.1"
  s.summary      = "ChatCache"
  s.description  = "ChatCache manage and save all caches of important things such as conversations, messages and so on."
  s.homepage     = "https://pubgi.sandpod.ir/chat/ios/chat-cache"
  s.license      = "MIT"
  s.author       = { "Hamed Hosseini" => "hamed8080@gmail.com" }
  s.platform     = :ios, "10.0"
  s.swift_versions = "5.6"
  s.source       = { :git => "https://pubgi.sandpod.ir/chat/ios/chat-cache", :tag => s.version }
  s.source_files = "Sources/ChatCache/**/*.{h,swift,xcdatamodeld,m,momd}"
  s.frameworks  = "Foundation"
  s.dependency "ChatModels" , '~> 2.2.1'
  s.dependency "Additive" , '~> 1.2.4'
  s.dependency "Mocks" , '~> 1.2.5'
end
