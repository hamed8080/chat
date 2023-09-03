# Getting Started
Getting started with Chat SDK and some tips and tricks and advice to configure it properly. 

## Overview

How to config chat sdk to work with your applicaiton.

## Configuration
To configure the chat SDK you should provide the async config along with chat config and pass the Async configuration as a parameter in the config builder as the figure shows:
>Note: Configuration for call and log are not necessary.


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
.build()
```

## Listening to an event
Chat SDK is not based on whether closures or completion handlers and notification, it is event-based.
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
```
>Tip: Put delegate in the first layer of your application and from there post a notification to other places or use your own delegate system.
