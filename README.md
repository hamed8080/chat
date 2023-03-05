# FanapPodChatSDK
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
- [x] Manage multiple accounts at the same time

## Installation

#### Swift Package Manager(SPM) 

Add in `Package.swift` or directly in `Xcode Project dependencies` section:

```swift
.package(url: "https://pubgi.fanapsoft.ir/chat/ios/fanappodchatsdk.git", .upToNextMinor(from: "1.2.0")),
```

#### [CocoaPods](https://cocoapods.org) 

Add in `Podfile`:

```ruby
pod 'FanapPodChatSDK'
```

## Intit 

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

## [Documentation](https://hamed8080.gitlab.io/fanappodchatsdk/documentation/fanappodchatsdk/)
For more information about how to use Chat SDK visit [Documentation](https://hamed8080.gitlab.io/fanappodchatsdk/documentation/fanappodchatsdk/) 
<br/>
<br/>

## [Developer Application](https://pubgi.fanapsoft.ir/chat/ios/chatapplication) 
For more example and usage you can use [developer implementation app](https://pubgi.fanapsoft.ir/chat/ios/chatapplication)
<br/>
<br/>

## Contributing to FanapPodChatSDK
Please see the [contributing guide](/CONTRIBUTING.md) for more information.

<!-- Copyright (c) 2021-2022 Apple Inc and the Swift Project authors. All Rights Reserved. -->
