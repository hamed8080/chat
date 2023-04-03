
Pod::Spec.new do |s|

  s.name         = "Chat"
  s.version      = "1.2.0"
  s.summary      = "Swift Chat SDK"
  s.description  = "This Package is used for creating chat apps for companies whoes want to use Chat Services; This Package will use Async"
  s.homepage     = "https://pubgi.fanapsoft.ir/chat/ios/chat"
  s.license      = "MIT"
  s.author       = { "Hamed Hosseini" => "hamed8080@gmail.com" }
  s.platform     = :ios, "10.0"
  s.swift_versions = "4.0"
  s.source       = { :git => "https://pubgi.fanapsoft.ir/chat/ios/chat.git", :tag => s.version }
  s.source_files = "Sources/Chat/**/*.{h,swift,xcdatamodeld,m,momd}"
  s.resources = "Sources/Chat/Resources/*.xcdatamodeld"
  s.frameworks  = "Foundation" , "CoreData" , "Contacts", "CoreServices"
  s.dependency "Async" , '~> 1.2.0'
  s.dependency "Logger" , '~> 1.0.0'

end
