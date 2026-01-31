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

## Installation

#### Swift Package Manager(SPM) 
1- Go to your root project folder and clone the Chat SDK:
```git
git clone --branch 3.0.0 https://pubgi.sandpod.ir/chat/ios/chat
```
or
```git
git clone --branch 3.0.0 https://github.com/hamed8080/chat 
```
2- Add package path to your `Package.swift`:

```swift
.package(path: "path_to_sdk_folder/Chat")
```
The process is the same if you are using Xcode to manage Swift Packages. Simply go to the navigator, select the main project, and add the dependency locally.

## Update the Chat SDK
Chat SDK uses tag versioning in Git to update the SDK. Make sure to clone it with the correct tag. First, switch to the main branch, then manually switch to the latest tag version.

## Swicth to a version 
To use the Chat SDK, it is **mandatory** to use a specific tagged version of the SDK. If this guideline is not followed, you might unintentionally download beta or test versions of the SDK, which could lead to unexpected issues or instability.
How to Checkout a Tagged Version:
```git
git checkout 3.0.0
```

#### Xcode porject tab

If you are using Xcode to manage SPM projects, you should either drag and drop the entire downloaded folder of the Chat SDK into your project or use a local package by providing the path to the cloned SDK.

#### Cocoapods 

For installing the SDK through the Cocoapods please read [this](https://github.com/hamed8080/Cocoapods.md).

## How to use? 

```swift
let asyncConfig = AsyncConfigBuilder(spec: spec)
            .reconnectCount(Int.max)
            .reconnectOnClose(true)
            .appId("PodChat")
            .peerName(spec.server.serverName)
            .build()
let chatConfig = ChatConfigBuilder(spec: spec, asyncConfig)
            .token("YOUR_SSO_ACCESS_TOKEN")
            .enableCache(true)
            .msgTTL(800_000)
            .persistLogsOnServer(true)
            .appGroup(AppGroup.group)
            .mapApiKey("map_api_key")
            .typeCodes([.init(typeCode: "default", ownerId: nil)])
            .build()
ChatManager.instance.createOrReplaceUserInstance(config: config)
ChatManager.activeInstance?.delegate = self
ChatManager.activeInstance?.connect()
```

## What is Spec?
Spec comes from specification and it comprises of base addresses and their paths for the socket server and other servers. You can find one in ## [Spec](https://podspace.pod.ir/api/files/CYRTOUEOQPC6NWGJ). You have to parse it and pass it to the config. 
Why does this spec exist?
After a lot of consideration, we ended up extracting the base URLs of the Chat SDK outside of its core. With this approach, you can even change the socket address dynamically at runtime.

Another great example is that you can continue downloading a picture or video even if the base address of the pod server has changed.

## Send a Request to the server
```swift
let req = ThreadsRequest(count: 10, offset: 0, cache: false)
Task { @ChatGlobalActor in
    ChatManager.activeInstance?.conversation.get(req);
}
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

<!-- Copyright (c) 2021-2022 Dotin Inc and the Swift Project authors. All Rights Reserved. -->
