# Pod-Chat-iOS-SDK
<img src="https://gitlab.com/hamed8080/fanappodchatsdk/-/raw/gl-pages/.docs/favicon.svg"  width="64" height="64">
<br />
<br />

Fanap's POD Chat Service - iOS SDK
## Features

- [x] Simplify Socket connection to Async server
- [x] Caching system
- [x] Static file response
- [x] Downlaod / Upload File or Data or Image resumebble
- [x] Manage threads and messages 

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
let req = SendTextMessageRequest(threadId: threadId, textMessage: "Hello World!", messageType: .TEXT)

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
For more information about how to use Chat SDK visit [Documentation](https://hamed8080.gitlab.io/fanappodchatsdk/documentation/fanappodchatsdk/) 
<br/>
<br/>

## Developer Application 
For more example and usage you can use [developer implementation app](https://pubgi.fanapsoft.ir/chat/ios/chatapplication)
