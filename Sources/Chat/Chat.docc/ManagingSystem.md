# Managing System
Manage system events.

### Send user is typing.
For sending an event to participants of a thread that you are typing in a thread call the method ``Chat/SystemProtocol/sendStartTyping(threadId:)`` like this:

```swift
ChatManager.activeInstance?.system.sendStartTyping(threadId: threadId)
```


### Send user stop typing.
For sending an event to participants of a thread that you have stopped typing in a thread call the method ``Chat/SystemProtocol/sendStopTyping()`` like this:

```swift
ChatManager.activeInstance?.system.sendStopTyping()
```

### Send a signal event
For sending an event to the server that the user is doing some acitons call the method ``Chat/SystemProtocol/sendSignalMessage(_:)`` like this:

```swift
let req = SendSignalMessageRequest(signalType: .RECORD_VOICE, threadId: 123456)
ChatManager.activeInstance?.system.sendSignalMessage(req)
```
