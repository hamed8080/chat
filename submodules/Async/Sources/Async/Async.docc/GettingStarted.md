# Getting Started

Create and connect to async server.

## Overview

With the help of the ``Async`` class, you could connect to the async server and the rest of the magic will happen automatically.

 
### Create Configuration

For connecting to the async server you must first of all pass a configuration to it, like the following code: 

```swift
let asyncConfig = AsyncConfig(socketAddress: "192.168.1.1", peerName: "peerName", appId: "PodChat")
let asyncClient = Async(config: asyncConfig, delegate: self)  
```

### Connecting to Async

Connecting to async server is not happening automatically you must tell it to connect, like the code the below:

```swift
asyncClient.createSocket()
```

### Connecting successfully

If everything goes well you should receive a ``AsyncSocketState/asyncReady`` state in the ``AsyncDelegate/asyncStateChanged(asyncState:error:)`` protocol.
```swift
public func asyncStateChanged(asyncState: AsyncSocketState, error: AsyncError?) {
    if asyncState == .ASYNC_READY{
        //doing your stuff.
    }
}
```

### Receiving messages

Whenever an event of the type of message arrives you can handle it with ``AsyncDelegate/asyncMessage(asyncMessage:)`` delegate method.
```swift
public func asyncMessage(asyncMessage: AsyncMessage){
    print(asyncMessage)
}
```

### Send a message

For sending a message make sure the async state is in ``AsyncSocketState/asyncReady`` state unless it async will queued the message and after connecting to the server it will send automatically.
```swift
if asyncClient.asyncSateModel == AsyncSocketState.ASYNC_READY{
    asyncClient.send(type: AsyncMessageTypes.MESSAGE, data: "Hello World!".data(using:.utf8)!)
}
```

### Debugging

For debugging a problem you should pass true in the configuration initializer like this, and it will print the logs to the console:
```swift
let asyncConfig = AsyncConfig(socketAddress: "192.168.1.1", peerName: "peerName", appId: "PodChat", isDebuggingLogEnabled: isDebuggingAsyncEnable)
```

