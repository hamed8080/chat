Pod::Spec.new do |s|
  s.name         = "ChatExtensions"
  s.version      = "1.0.0"
  s.summary      = "ChatExtensions"
  s.description  = "Additive is a set of UI extensions and custom views."
  s.homepage     = "https://pubgi.fanapsoft.ir/chat/ios/chat-extensions"
  s.license      = "MIT"
  s.author       = { "Hamed Hosseini" => "hamed8080@gmail.com" }
  s.platform     = :ios, "10.0"
  s.swift_versions = "4.0"
  s.source       = { :git => "https://pubgi.fanapsoft.ir/chat/ios/chat-extensions", :tag => s.version }
  s.source_files = "Sources/Additive/**/*.{h,swift,xcdatamodeld,m,momd}"
  s.frameworks  = "Foundation"
end
