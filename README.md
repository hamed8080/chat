# Chat
### A Swift Chat SDK which handle all backend communication with Async SDK and Chat Server. 
<img src="https://github.com/hamed8080/chat/raw/main/images/icon.png"  width="64" height="64">
<br />
<br />

## Features

- [x] Simplify Socket connection to Async server
- [x] Caching system
- [x] Static file response
- [x] Downlaod / Upload File or Data or Image resumebble
- [x] Manage threads and messages
- [x] Manage multiple accounts at the same time

## Installation

#### Swift Package Manager(SPM) 

Add in `Package.swift` or directly in `Xcode Project dependencies` section:

```swift
.package(url: "https://pubgi.fanapsoft.ir/chat/ios/chat.git", .upToNextMinor(from: "1.2.0")),
```

#### [CocoaPods](https://cocoapods.org) 

Add in `Podfile`:

```ruby
pod 'Chat'
```

## How to use? 

```swift
let asyncConfig = AsyncConfigBuilder()
            .socketAddress("socketAddresss")
            .reconnectCount(Int.max)
            .reconnectOnClose(true)
            .appId("PodChat")
            .serverName("serverName")
            .isDebuggingLogEnabled(false)
            .build()
let chatConfig = ChatConfigBuilder(asyncConfig)
            .token("token")
            .ssoHost("ssoHost")
            .platformHost("platformHost")
            .fileServer("fileServer")
            .enableCache(true)
            .msgTTL(800_000)
            .isDebuggingLogEnabled(true)
            .persistLogsOnServer(true)
            .appGroup("group")
            .sendLogInterval(15)
            .build()
ChatManager.instance.createOrReplaceUserInstance(config: config)
ChatManager.activeInstance?.delegate = self
ChatManager.activeInstance?.connect()
```

## Usage 
```swift
ChatManager.activeInstance?.getThreads(.init(), completion: { response in
    if let response.result {
        // Write your code here.
    }
}
```
<br/>
<br/>

## [Documentation](https://hamed8080.gitlab.io/chat/documentation/Chat/)
For more information about how to use Chat SDK visit [Documentation](https://hamed8080.gitlab.io/Chat/documentation/chat/) 
<br/>
<br/>

## [Developer Application](https://github.com/hamed8080/ChatApplication) 
For more example and usage you can use [developer implementation app](https://pubgi.fanapsoft.ir/chat/ios/chatapplication)
<br/>
<br/>

## Contributing to Chat
Please see the [contributing guide](/CONTRIBUTING.md) for more information.

<!-- Copyright (c) 2021-2022 Apple Inc and the Swift Project authors. All Rights Reserved. -->
