# Chat

<h5>A Swift Chat SDK which handle all backend communication with Async SDK and Chat Server.</h5>

<img src="https://github.com/hamed8080/chat/raw/main/images/icon.png"  width="164" height="164">

## Features

- [x] Simplify Socket connection to Async server
- [x] Caching system
- [x] Static file response
- [x] Downlaod / Upload File or Data or Image resumebble
- [x] Manage threads and messages
- [x] Manage multiple accounts at the same time
- Not compatible with cocoapods

## Installation

#### Swift Package Manager(SPM) 

Add in `Package.swift` or directly in `Xcode Project dependencies` section:

```swift
.package(url: "https://pubgi.sandpod.ir/chat/ios/chat.git", from: "2.2.1")
```

## How to use? 

```swift
let asyncConfig = AsyncConfigBuilder()
            .socketAddress("socketAddresss")
            .reconnectCount(Int.max)
            .reconnectOnClose(true)
            .appId("PodChat")
            .peerName("peerName")
            .isDebuggingLogEnabled(false)
            .loggerConfig(asyncLoggerConfig)
            .build()
let chatConfig = ChatConfigBuilder(asyncConfig)
            .token(token)
            .ssoHost("ssoHost")
            .platformHost("platformHost")
            .fileServer("fileServer")
            .enableCache(true)
            .msgTTL(800_000) // for integeration server need to be long time
            .persistLogsOnServer(true)
            .appGroup(AppGroup.group)
            .loggerConfig(chatLoggerConfig)
            .mapApiKey("map_api_key")
            .typeCodes([.init(typeCode: "default", ownerId: nil)])
            .build()
ChatManager.instance.createOrReplaceUserInstance(config: config)
ChatManager.activeInstance?.delegate = self
ChatManager.activeInstance?.connect()
```

## Send a Request to the server
```swift
let req = ThreadsRequest(count: 10, offset: 0, cache: false)
ChatManager.activeInstance?.conversation.get(req);
```
## Receive events for a specific group center
```swift
NotificationCenter.thread.publisher(for: .thread)
    .compactMap { $0.object as? ThreadEventTypes }
    .sink { event in
        // Main Thread
        onThreadEvent(event)
    }
    .store(in: &cancelable)

func onThreadEvent(_ event: ThreadEventTypes?) {
    switch event {
    case .threads(let response):
        let threads = response.result
        // Write your code here
    }
}
```

## [Documentation](https://hamed8080.github.io/chat/documentation/chat)
For more information about how to use Chat SDK visit [Documentation](https://hamed8080.github.io/chat/documentation/chat/) 
<br/>

## [Developer Application](https://github.com/hamed8080/ChatApplication) 
For more example and usage you can use [developer implementation app](https://pubgi.fanapsoft.ir/chat/ios/chatapplication)
<br/>

## Contributing to Chat
Please see the [contributing guide](/CONTRIBUTING.md) for more information.

<!-- Copyright (c) 2021-2022 Apple Inc and the Swift Project authors. All Rights Reserved. -->
