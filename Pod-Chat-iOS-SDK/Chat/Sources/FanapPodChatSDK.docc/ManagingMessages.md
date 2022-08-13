# Managing Messages
You could Add, delete, edit, reply, forward and so many more.

### Send Text Message

To send a simple text message insisde a thread call the method ``Chat/sendTextMessage(_:uniqueIdresult:onSent:onSeen:onDeliver:)`` like this:

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

A list of messages of a thread for this reason call method ``Chat/getHistory(_:completion:cacheResponse:textMessageNotSentRequests:editMessageNotSentRequests:forwardMessageNotSentRequests:fileMessageNotSentRequests:uploadFileNotSentRequests:uploadImageNotSentRequests:uniqueIdResult:)`` like this:
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
