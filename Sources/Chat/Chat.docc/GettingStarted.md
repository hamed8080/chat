# Getting Started
Getting started with the Chat SDK and some tips and tricks to configure it properly. 

## Overview
How to configure the Chat SDK to integrate with your application.

## Configuration
To configure the Chat SDK you have got to provide an AsyncConfig along with a ChatConfig and pass the AsyncConfig as a parameter in the config builder as the figure shows:
>Note: The configuration for call and log is not required.
 

```swift
let spec = getSpec()

let callConfig = CallConfigBuilder()
    .callTimeout(20)
    .targetVideoWidth(640)
    .targetVideoHeight(480)
    .maxActiveVideoSessions(2)
    .targetFPS(15)
    .build()

let asyncLoggerConfig = LoggerConfig(
    prefix: "ASYNC_SDK",
    logServerURL: "LOG_SERVER_ADDRESS",
    logServerMethod: "PUT",
    persistLogsOnServer: true,
    isDebuggingLogEnabled: true,
    logServerRequestheaders: ["Authorization": "Basic \(LOG_SERVER_TOKEN)", "Content-Type": "application/json"]
)

let chatLoggerConfig = LoggerConfig(
    prefix: "CHAT_SDK",
    logServerURL: "LOG_SERVER_ADDRESS",
    logServerMethod: "PUT",
    persistLogsOnServer: true,
    isDebuggingLogEnabled: true,
    logServerRequestheaders: ["Authorization": "Basic \(LOG_SERVER_TOKEN)", "Content-Type": "application/json"]
)

let asyncConfig = try! AsyncConfigBuilder(spec: spec)
    .socketAddress("SOCKET_ADDRESS")
    .reconnectCount(Int.max)
    .reconnectOnClose(true)
    .appId("APP_ID")
    .peerName("PEER_NAME")
    .loggerConfig(asyncLoggerConfig)
    .build()

let chatConfig = ChatConfigBuilder(spec: spec, asyncConfig)
    .callConfig(callConfig)
    .token("SSO_TOKEN")
    .ssoHost("SSERVER_ADDRESS")
    .platformHost("CORE_PLATFORM_HOST_ADDRESS")
    .fileServer("FILE_SSERVER_ADDRESS")
    .enableCache(true)
    .mapApiKey("NESHAN_API_TOKEN")
    .typeCodes([.init(typeCode: "default", ownerId: nil)])
    .build()
```

## What is Spec?
Spec comes from specification and it comprises of base addresses and their paths for the socket server and other servers. You can find one in ## [Spec](https://podspace.pod.ir/api/files/CYRTOUEOQPC6NWGJ). You have to parse it and pass it to the config. 
Why does this spec exist?
After a lot of consideration, we ended up extracting the base URLs of the Chat SDK outside of its core. With this approach, you can even change the socket address dynamically at runtime.

Another great example is that you can continue downloading a picture or video even if the base address of the pod server has changed.

## Listening to an event
Chat SDK is not based on whether closures or completion handlers and notification, it is an event-based SDK.
When you initiate a request you should listen to an event by a delegate that we provided for you like:

```swift
final class ChatDelegateImplementation: ChatDelegate {
    func chatState(state: ChatState, currentUser: User?, error _: ChatError?) {
        print("chat status: \(state)")
    }

    func chatEvent(event: ChatEventType) {
        print(dump(event))
        NotificationCenter.post(event: event)
    }
}
```

>Tip: To get Chat SDK up and running you should provide a spec. Spec is a speccification where it contains URLS and paths to the API resources. The best way to create a one is to decode the original sample spec json file at this [link](https://github.com/hamed8080/bundle/blob/main/Spec.json)

>Tip: Each request you make implicitly generates a unique ID, and upon receiving a response from the Chat Server, you will get a corresponding unique ID.

>Tip: To distinguish responses as mentioned above, you need to use the unique ID. Keep in mind that there is a chance you might end up receiving more than one event from the Chat Server with the same unique ID.

>Tip: For the sake of brevity, we will not repeat the event types for the receive event delegate. You should know that there is a ThreadEventTypes enum where you can just receive the desired event.

>Tip: Place the delegate in the initial lines of code in your application, and from there, post a notification to other parts of the system or use your own delegate mechanism.

>Tip: Chat SDK requests and responses are designed to be value types, so when you pass them around, be careful about the mutations you have made to instances you received from the SDK.

## Swift 6 and Concurrency
Chat SDK version 3.0.0 is designed to work closely with Swift concurrency, so there is a learning curve when getting started with the new version.
Firstly, you cannot directly touch the Chat SDK or Async SDK classes because they are built from the ground up with a specific Swift Actor.

To call a method, you must explicitly switch to the Chat SDK context using ``ChatGlobalActor``. The code below demonstrates how to retrieve a list of conversations:

```swift
Task { @ChatGlobalActor in
    ChatManager.activeInstance?.conversation.get(req)
}
```

>Warning: Do not mark the class or method with ``ChatGlobalActor`` if it performs a heavy task or operation. 

>Important: Chat SDK is not bound to the MainActor. However, in the ChatCache SDK (one of its dependencies), we must bind to the MainActor due to its interaction with Core Data.

>Note: For brevity, we will show only the bare method call without wrapping the call site in a Task with @ChatGlobalActor.
