Pod::Spec.new do |s|
  s.name         = "Spec"
  s.version      = "1.2.4"
  s.summary      = "Spec"
  s.description  = "Spec contains a set of URLs and Paths to run the Chat SDK and APP"
  s.homepage     = "https://pubgi.sandpod.ir/chat/ios/spec"
  s.license      = "MIT"
  s.author       = { "Hamed Hosseini" => "hamed8080@gmail.com" }
  s.platform     = :ios, "13.0"
  s.swift_versions = "5.9"
  s.source       = { :git => "https://pubgi.sandpod.ir/chat/ios/spec", :tag => s.version }
  s.source_files = "Sources/Spec/**/*.{h,swift,xcdatamodeld,m,momd}"
  s.frameworks  = "Foundation" , "CoreData"
end
