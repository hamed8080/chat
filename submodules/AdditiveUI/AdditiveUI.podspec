Pod::Spec.new do |s|
  s.name         = "AdditiveUI"
  s.version      = "1.2.3"
  s.summary      = "AdditiveUI"
  s.description  = "It's comprised of common ui-views, extensions, and modifiers."
  s.homepage     = "https://pubgi.sandpod.ir/chat/ios/additive-ui"
  s.license      = "MIT"
  s.author       = { "Hamed Hosseini" => "hamed8080@gmail.com" }
  s.platform     = :ios, "16.0"
  s.swift_versions = "5.8"
  s.source       = { :git => "https://pubgi.sandpod.ir/chat/ios/additive-ui", :tag => s.version }
  s.source_files = "Sources/AdditiveUI/**/*.{h,swift,xcdatamodeld,m,momd}"
  s.frameworks  = "Foundation"
end
