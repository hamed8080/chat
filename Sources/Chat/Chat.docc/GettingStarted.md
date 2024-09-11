# Getting Started
Getting started with the Chat SDK and some tips and tricks to configure it properly. 

## Overview
How to configure the Chat SDK to integrate with your application.

## Configuration
To configure the Chat SDK you have got to provide an AsyncConfig along with a ChatConfig and pass the AsyncConfig as a parameter in the config builder as the figure shows:
>Note: The configuration for call and log is not required.


```swift
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

let asyncConfig = try! AsyncConfigBuilder()
    .socketAddress("SOCKET_ADDRESS")
    .reconnectCount(Int.max)
    .reconnectOnClose(true)
    .appId("APP_ID")
    .peerName("PEER_NAME")
    .loggerConfig(asyncLoggerConfig)
    .build()

let chatConfig = ChatConfigBuilder(asyncConfig)
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

## Listening to an event
Chat SDK is not based on whether closures or completion handlers and notification, it is an event-based SDK.
When you initiate a request you should listen to an event by a delegate that we provided for you like:

```swift
final class ChatDelegateImplementation: ChatDelegate  {
    func chatState(state: ChatState, currentUser: User?, error _: ChatError?) {
        print("chat status: \(state)")
    }

    func chatEvent(event: ChatEventType) {
        print(dump(event))
        NotificationCenter.post(event: event)
    }
}
```

>Tip: Each request you make implicitly generates a unique ID, and upon receiving a response from the Chat Server, you will get a corresponding unique ID.

>Tip: To distinguish responses as mentioned above, you need to use the unique ID. Keep in mind that there is a chance you might end up receiving more than one event from the Chat Server with the same unique ID.

>Tip: For the sake of brevity, we will not repeat the event types for the receive event delegate. You should know that there is a ThreadEventTypes enum where you can just receive the desired event.

>Tip: Place the delegate in the initial lines of code in your application, and from there, post a notification to other parts of the system or use your own delegate mechanism.
