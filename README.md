# Pod-Chat-iOS-SDK
<img src="https://fanap.ir/images/fanap-logo.png" width="64" height="64" />
<br />
<br />

[![Swift](https://img.shields.io/badge/Swift-5+-orange?style=flat-square)](https://img.shields.io/badge/-Orange?style=flat-square)
[![Platforms](https://img.shields.io/badge/Platforms-iOS-yellowgreen?style=flat-square)](https://img.shields.io/badge/Platforms-macOS_iOS_tvOS_watchOS_Linux_Windows-Green?style=flat-square)

Fanap's POD Chat Service - iOS SDK
## Features

- [x] Simplify Socket connection to Async server
- [x] Caching system
- [x] Static file response
- [x] Downlaod / Upload File or Data or Image resumebble

## Installation

#### [CocoaPods](https://cocoapods.org) 

Add in `Podfile`:

```ruby
pod 'FanapPodChatSDK'
```

## Intit 

```swift
Chat.sharedInstance.createChatObject(config: .init(socketAddress          : socketAddresss,
                                                    serverName            : serverName,
                                                    token                 : token,
                                                    ssoHost               : ssoHost,
                                                    platformHost          : platformHost,
                                                    fileServer            : fileServer,
                                                    enableCache           : true,
                                                    reconnectOnClose      : true,
                                                    isDebuggingLogEnabled : true
))

Chat.sharedInstance.delegate = self
```

## Usage 
```swift
let req = NewSendTextMessageRequest(threadId: threadId, textMessage: "Hello World!", messageType: .TEXT)

Chat.sharedInstance.sendTextMessage(req, uniqueIdresult: nil) { sentResult, uniqueId , error in
    print(sentResult ?? "")
} onSeen: { seenResult, uniqueId , error in
    print(seenResult ?? "")
} onDeliver: { deliverResult, uniqueId , error in
    print(deliverResult ?? "")
}
```
<br/>
<br/>

## Documentation
For more information about how to use Chat SDK visit [Documentation](https://docs.pod.ir/v0.10.5.0/Chat/ios/9560/installation) 
<br/>
<br/>

## Developer Application 
For more example and usage you can use [developer implementation app](https://github.com/hamed8080/ChatImplementation)
