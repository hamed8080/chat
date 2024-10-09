Pod::Spec.new do |s|
  s.name         = "Logger"
  s.version      = "1.2.4"
  s.summary      = "Logger SDK"
  s.description  = "Logging on a log server or device in a unified manner."
  s.homepage     = "https://pubgi.sandpod.ir/chat/ios/logger"
  s.license      = "MIT"
  s.author       = { "Hamed Hosseini" => "hamed8080@gmail.com" }
  s.platform     = :ios, "10.0"
  s.swift_versions = "5.6"
  s.source       = { :git => "https://pubgi.sandpod.ir/chat/ios/logger", :tag => s.version }
  s.source_files = "Sources/Logger/**/*.{h,swift,xcdatamodeld,m,momd}"
  s.resources = "Sources/Logger/Resources/*.xcdatamodeld"
  s.frameworks  = "Foundation" , "CoreData"
  s.dependency "Additive" , '~> 1.2.4'
  s.dependency "Mocks" , '~> 1.2.5'
end
