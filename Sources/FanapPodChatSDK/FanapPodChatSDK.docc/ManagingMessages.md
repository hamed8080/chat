# Managing Messages
You could Add, delete, edit, reply, forward and so many more.

### Message States
![How chat sdk works behind the scene.](message-flow.png)

Each message has 5 phases to send to the opposite person or in a group thread.
1. Stage waiting to send it to the chat server but there isn't any response yet, so the message just has a uniqueId, not an ``Message/id``.
2. In this stage, the message is added to a queue in the cache with the power of **CoreData**, to live there for resending, if the message wasn't sent to the server.
3. In stage 3, the server receives the message and will respond with types ``ChatMessageVOTypes/sent`` and ``ChatMessageVOTypes/message`` at the same time.
4. When another person receives the message, it should send the **deliver** event to the sender, which is done behind the scene by the chat SDK.
5. When another person opens the thread and sees the message, it should send a seen with type ``ChatMessageVOTypes/seen`` response to the sender.

>Important: After a message has been sent to the server, it will be deleted automatically from the cache.

>Important: If the device is in runtime mode and the app wasn't terminated by the user or OS a queue exists to resend messages automatically when chat SDK is in ``ChatState/chatReady`` state again, by two second time interval one by one.


### Send Text Message

To send a simple text message insisde a thread call the method ``Chat/sendTextMessage(_:uniqueIdResult:onSent:onSeen:onDeliver:)`` like this:

```swift
Chat.sharedInstance.sendTextMessage(.init(threadId: 123456, textMessage: "Hello", messageType: .TEXT)) { uniqueId in
    // Write your code
} onSent: { sentResponse, uniqueId, error in
    // Write your code
} onSeen: { seenResponse, uniqueId, error in
    // Write your code
} onDeliver: { deliverresponse, uniqueId, error in
    // Write your code
}
```

### Edit Text Message

To edit a message call the method ``Chat/editMessage(_:completion:uniqueIdResult:)`` like this:

>Important: Editing a message requires that the message must be editable. You could check it through ``Message/editable``.

```swift
let req = EditMessageRequest(threadId: 123456, messageType: .TEXT, messageId: 4567890, textMessage: "Edited Text Message")
Chat.sharedInstance.editMessage(req) { message, uniqueId, error in
    if error == nil {
        // Write your code
    }
}
```

### Send Reply Message 

To send a reply text message insisde a thread call the method ``Chat/replyMessage(_:uniqueIdresult:onSent:onSeen:onDeliver:)`` like this:

```swift
Chat.sharedInstance.replyMessage(.init(threadId: 123456, repliedTo: 4567890, textMessage: "Hello", messageType: .TEXT)) { uniqueId in
    // Write your code
} onSent: { sentResponse, uniqueId, error in
    // Write your code
} onSeen: { seenResponse, uniqueId, error in
    // Write your code
} onDeliver: { deliverresponse, uniqueId, error in
    // Write your code
}
```


### Send Location Message 

To send a message with location cordinate you should send call the method ``Chat/sendLocationMessage(_:uploadProgress:downloadProgress:onSent:onSeen:onDeliver:uploadUniqueIdResult:messageUniqueIdResult:)`` like this:

```swift
let req = LocationMessageRequest(mapCenter: .init(lat: 37.33900249783756, lng: -122.00944807880965), threadId: 123456, userGroupHash: "XYZ....")
Chat.sharedInstance.sendLocationMessage(req) { uniqueId in
    // Write your code
} onSent: { sentResponse, uniqueId, error in
    // Write your code
} onSeen: { seenResponse, uniqueId, error in
    // Write your code
} onDeliver: { deliverresponse, uniqueId, error in
    // Write your code
}
```


### Forward Messages 

To forward messages to a thread you must prepare a list of messageIds and a threadId call the method ``Chat/forwardMessages(_:onSent:onSeen:onDeliver:uniqueIdsResult:)`` like this:

```swift
let msgIds = [123456, 78901,...]
let req = ForwardMessageRequest(threadId: 123456, messageIds: msgIds)
Chat.sharedInstance.forwardMessages(req) { uniqueId in
    // Write your code
} onSent: { sentResponse, uniqueId, error in
    // Write your code
} onSeen: { seenResponse, uniqueId, error in
    // Write your code
} onDeliver: { deliverresponse, uniqueId, error in
    // Write your code
}
```

### Get History

A list of messages of a thread for this reason call method ``Chat/getHistory(_:completion:cacheResponse:textMessageNotSentRequests:editMessageNotSentRequests:forwardMessageNotSentRequests:fileMessageNotSentRequests:uniqueIdResult:)`` like this:
>Important: Messages those didn't send properly will inform you of the appropriate closures.
```swift
let req = GetHistoryRequest(threadId: 123456, count: 100, offset: 0)
Chat.sharedInstance.getHistory(req) { messages, uniqueId, pagination, error in
    // Write your code
} cacheResponse: { messages, uniqueId, pagination, error in
    // Write your code
} 
```

### Get Hashtags

A list of messages which contains hashtags. Call method ``Chat/getHashtagList(_:completion:cacheResponse:uniqueIdResult:)`` like this:
```swift
let req = GetHistoryRequest(threadId: 123456 , hashtag: "ios")
Chat.sharedInstance.getHashtagList(req) { messages, uniqueId, pagination, error in
    // Write your code
}
```

### Pin A Message

For pin a message inside a thread. For checking the result use the property ``Message/pinned``. Call method ``Chat/pinMessage(_:completion:uniqueIdResult:)`` like this:

```swift
let req = PinUnpinMessageRequest(messageId: 123456)
Chat.sharedInstance.pinMessage(req) { pinMessage, uniqueId, error in
    // Write your code
}
```


### UNPin A Message

For unpin a message inside a thread. For checking the result use the property ``Message/pinned``. Call method ``Chat/pinMessage(_:completion:uniqueIdResult:)`` like this:

```swift
let req = PinUnpinMessageRequest(messageId: 123456)
Chat.sharedInstance.unpinMessage(req) { pinMessage, uniqueId, error in
    // Write your code
}
```


### Clear Thread Messages History

If you need to clear messages history of a thread just call ``Chat/clearHistory(_:completion:uniqueIdResult:)`` like this:

```swift
Chat.sharedInstance.clearHistory(.init(threadId: 123456)) { threadId, uniqueId, error in
    // Write your code
}
```


### Delete A Message

For deleting a message call method ``Chat/deleteMessage(_:completion:uniqueIdResult:)`` like this:

>Tip: For deleting a message for all other users set ``DeleteMessageRequest/deleteForAll`` to `true` in initializer.

>Important: A message only can be deleted when it's ``Message/deletable``.
```swift
Chat.sharedInstance.deleteMessage(.init(messageId: 123456)) { message, uniqueId, error in
    // Write your code
}
```

### Delete Multiple Messages

For deleting multiple messages call method ``Chat/deleteMultipleMessages(_:completion:uniqueIdResult:)`` like this:

```swift
let msgIds = [894560, 4567892, ...]
Chat.sharedInstance.deleteMultipleMessages(.init(threadId: 123456, messageIds: msgIds)) { messages, uniqueId, error in
    // Write your code
}
```

### Number of unread messages

For retrieving the number of unread messages count use the method ``Chat/deleteMultipleMessages(_:completion:uniqueIdResult:)`` like this:

```swift
Chat.sharedInstance.deleteMultipleMessages(.init(countMutedThreads: true)) { unreadCount, uniqueId, error in
    // Write your code
}
```


### Get the list of messages that you are mentioned

For retrieving the list of messages that you have mentioned in a thread use the method ``Chat/getMentions(_:completion:cacheResponse:uniqueIdResult:)`` like this:

```swift
Chat.sharedInstance.getMentions(.init(threadId: 123456, onlyUnreadMention: false)) { messages, uniqueId, pagination, error in
    // Write your code
}
```

### List of participants who delivered the message to them.

For retrieving the list of participants who the message delivered to them, use the method ``Chat/messageDeliveredToParticipants(_:completion:uniqueIdResult:)`` like this:

```swift
Chat.sharedInstance.messageDeliveryParticipants(.init(messageId: 123456)) { participants, uniqueId, pagination, error in
    // Write your code
}
```

### List of participants who have seen the message.

For retrieving the list of participants who the message delivered to them, use the method ``Chat/messageSeenByUsers(_:completion:uniqueIdResult:)`` like this:

```swift
Chat.sharedInstance.messageSeenByUsers(.init(messageId: 123456)) { participants, uniqueId, pagination, error in
    // Write your code
}
```

### List of participants who have seen the message.

For retrieving the list of participants who the message delivered to them, use the method ``Chat/messageSeenByUsers(_:completion:uniqueIdResult:)`` like this:

```swift
Chat.sharedInstance.messageSeenByUsers(.init(messageId: 123456)) { participants, uniqueId, pagination, error in
    // Write your code
}
```

### Send seen of a message.

For the time that your user opens a thread in your application, that is your responsibility to inform the other participants to tell them you have seen the message. For this matter, use the method ``Chat/seen(_:uniqueIdResult:)`` like this:

>Important: Sending a delivery of a message is Chat-SDK responsibility and it will happen automatically.
```swift
Chat.sharedInstance.seen(.init(messageId: 123456))
```

### Cancel a message.

Cancel a message happens when a message is not sent by the SDK and canceling it will delete it from a cache of SDK respectively. For this call the method ``Chat/cancelMessage(uniqueId:completion:)`` like this:

```swift
Chat.sharedInstance.cancelMessage(.init(uniqueId: "XYZ...")){ isCanceled, uniqueId, error in
    // Write your code
}
```


### Send user is typing.

For sending an event to participants of a thread that you are typing in a thread call the method ``Chat/snedStartTyping(threadId:)`` like this:

```swift
Chat.sharedInstance.snedStartTyping(threadId: 123456)
```


### Send user stop typing.

For sending an event to participants of a thread that you have stopped typing in a thread call the method ``Chat/sendStopTyping()`` like this:

```swift
Chat.sharedInstance.sendStopTyping()
```

### Tell the server user has logged out.

For sending an event to the server that the user with the device has logged out call the method ``Chat/logOut()`` like this:

```swift
Chat.sharedInstance.logOut()
```

### Send a signal event

For sending an event to the server that the user is doing some acitons call the method ``Chat/sendSignalMessage(req:)`` like this:

```swift
Chat.sharedInstance.sendSignalMessage(.init(signalType: .RECORD_VOICE, threadId: 123456))
```

### Export Messages in CSV

To export a messages of a thread inside a `CSV` file, call the method ``Chat/exportChat(_:_:uniqueIdResult:)`` like this:
>Important: Please remove the created file after you have finished the use of this file.

>Note: Every time you call this function it will remove the older file.

>Note: This function only can export up to 10000 message at each call.

```swift
let req = GetHistoryRequest(threadId: 123456, fromTime: UInt(startDate.millisecondsSince1970), toTime: UInt(endDate.millisecondsSince1970))
Chat.sharedInstance.exportChat(req){ url, uniqueId, error in
    // Write your code
}
```
