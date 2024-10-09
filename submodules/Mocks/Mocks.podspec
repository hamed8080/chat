Pod::Spec.new do |s|
  s.name         = "Mocks"
  s.version      = "1.2.5"
  s.summary      = "Mocks"
  s.description  = "Mocks is a set of extensions over some primitive swift classes."
  s.homepage     = "https://pubgi.sandpod.ir/chat/ios/mocks"
  s.license      = "MIT"
  s.author       = { "Hamed Hosseini" => "hamed8080@gmail.com" }
  s.platform     = :ios, "10.0"
  s.swift_versions = "5.6"
  s.source       = { :git => "https://pubgi.sandpod.ir/chat/ios/mocks", :tag => s.version }
  s.source_files = "Sources/Mocks/**/*.{h,swift,xcdatamodeld,m,momd}"
  s.frameworks  = "Foundation" , "CoreData"
  s.dependency "Additive" , '~> 1.2.4'
end
