Pod::Spec.new do |s|
  s.name         = "ChatTransceiver"
  s.version      = "2.2.2"
  s.summary      = "ChatTransceiver"
  s.description  = "The ChatTransceiver allows for the seamless transfer of files to and from chat servers and podspace. It enables users to download and upload files with ease, making file sharing a hassle-free experience."
  s.homepage     = "https://pubgi.sandpod.ir/chat/ios/chat-transceiver"
  s.license      = "MIT"
  s.author       = { "Hamed Hosseini" => "hamed8080@gmail.com" }
  s.platform     = :ios, "13.0"
  s.swift_versions = "5.9"
  s.source       = { :git => "https://pubgi.sandpod.ir/chat/ios/chat-transceiver", :tag => s.version }
  s.source_files = "Sources/ChatTransceiver/**/*.{h,swift,xcdatamodeld,m,momd}"
  s.frameworks  = "Foundation", "CoreServices"
  s.dependency "ChatDTO"
  s.dependency "Additive"
  s.dependency "Mocks"
end
