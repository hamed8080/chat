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
To send a simple text message insisde a thread call the method ``Chat/MessageProtocol/send(_:)-8kz5t`` like this:

```swift
let req = SendTextMessageRequest(threadId: threadId, textMessage: "Hello", messageType: .TEXT)
ChatManager.activeInstance?.message.send(req)
```

### Send a file message
To send a new message with uploading a file use the method ``Chat/MessageProtocol/send(_:_:)-s0vu`` like this:

```swift
let message = SendTextMessageRequest(threadId: 123456, textMessage: "Use This File", messageType: .POD_SPACE_FILE)
let uploadFile = UploadFileRequest(data: fileData, fileExtension: ".txt", fileName: "Test", mimeType: "text/plain" , userGroupHash: "XYZ....")
ChatManager.activeInstance?.message.send(replyMessage: message, uploadFile: uploadFile)
```

### Send an image message
To send a new image message use the method ``Chat/MessageProtocol/send(_:_:)-8yv5f`` like this:
```swift
let message = SendTextMessageRequest(threadId: threadId, textMessage: "Test text", messageType: .POD_SPACE_PICTURE)
let imageRequest = UploadImageRequest(data: imaageData, hC: height, wC: width , fileName: "Test.png", mimeType: "image/png" , userGroupHash: "XYZ..." )
ChatManager.activeInstance?.message.send(textMessage: message, uploadFile: imageRequest)
```

### Edit Text Message
To edit a message call the method ``Chat/MessageProtocol/edit(_:)`` like this:

>Important: Editing a message requires that the message must be editable. You could check it through ``Message/editable``.

```swift
let req = EditMessageRequest(threadId: threadId, messageType: .TEXT, messageId: messageId, textMessage: "Edited Text Message")
ChatManager.activeInstance?.message.edit(req)
```

### Send Reply Message 
To send a reply text message insisde a thread call the method ``Chat/MessageProtocol/reply(_:)`` like this:

```swift
let req = ReplyMessageRequest(threadId: threadId, repliedTo: repliedTo, textMessage: "Hello", messageType: .TEXT)
ChatManager.activeInstance?.message.reply(req)
```

### Reply with file
To reply to a message with uploading a file use the method ``Chat/MessageProtocol/reply(_:_:)-4dbh6`` like this:

```swift
let replyMsg = ReplyMessageRequest(threadId: 123456, repliedTo: 567890, textMessage: "Use This File", messageType: .POD_SPACE_FILE)
let uploadFile = UploadFileRequest(data: fileData, fileExtension: ".txt", fileName: "Test", mimeType: "text/plain" , userGroupHash: "XYZ....")
ChatManager.activeInstance?.message.reply(replyMessage: replyMsg, uploadFile: uploadFile)
```

### Send Location Message 
To send a message with location cordinate you should send call the method ``Chat/MessageProtocol/send(_:)-8qr0z`` like this:

```swift
let req = LocationMessageRequest(mapCenter: .init(lat: 37.33900249783756, lng: -122.00944807880965), threadId: threadId, userGroupHash: "XYZ....")
ChatManager.activeInstance?.message.send(req)
```

### Forward Messages 
To forward messages to a thread you must prepare a list of messageIds and a threadId call the method ``Chat/MessageProtocol/send(_:)-84dd1`` like this:

```swift
let msgIds = [123456, 78901,...]
let req = ForwardMessageRequest(threadId: threadId, messageIds: msgIds)
ChatManager.activeInstance?.message.send(req)
```

### Get History
A list of messages of a thread for this reason call method ``Chat/MessageProtocol/history(_:)`` like this:
>Important: Messages those didn't send properly will inform you of the appropriate closures.
```swift
let req = GetHistoryRequest(threadId: threadId, count: 100, offset: 0)
ChatManager.activeInstance?.message.history(req)
```

### Get Hashtags
A list of messages which contains hashtags. Call method ``Chat/MessageProtocol/history(_:)`` like this:
```swift
let req = GetHistoryRequest(threadId: threadId , hashtag: "ios")
ChatManager.activeInstance?.message.history(req)
```

### Pin a Message
For pin a message inside a thread. For checking the result use the property ``Message/pinned``. Call method ``Chat/MessageProtocol/pin(_:)`` like this:

```swift
let req = PinUnpinMessageRequest(messageId: messageId)
ChatManager.activeInstance?.message.pin(req)
```

### UNPin a Message
For unpin a message inside a thread. For checking the result use the property ``Message/pinned``. Call method ``Chat/MessageProtocol/unpin(_:)`` like this:

```swift
let req = PinUnpinMessageRequest(messageId: messageId)
ChatManager.activeInstance?.message.unpin(req)
```

### Clear Thread Messages History
If you need to clear messages history of a thread just call ``Chat/MessageProtocol/clear(_:)`` like this:

```swift
let req = GeneralSubjectIdRequest(threadId: threadId)
ChatManager.activeInstance?.message.clear(req)
```

### Delete a Message
For deleting a message call method ``Chat/MessageProtocol/delete(_:)-8n143`` like this:

>Tip: For deleting a message for all other users set ``DeleteMessageRequest/deleteForAll`` to `true` in initializer.

>Important: A message only can be deleted when it's ``Message/deletable``.
```swift
let req = DeleteMessageRequest(messageId: messageId)
ChatManager.activeInstance?.message.delete(req)
```

### Delete Multiple Messages
For deleting multiple messages call method ``Chat/MessageProtocol/delete(_:)-2gdjl`` like this:

```swift
let msgIds = [894560, 4567892, ...]
let req = BatchDeleteMessageRequest(threadId: threadId, messageIds: msgIds)
ChatManager.activeInstance?.message.delete(req)
```

### Get the list of messages that you are mentioned
For retrieving the list of messages that you have mentioned in a thread use the method ``Chat/MessageProtocol/mentions(_:)`` like this:

```swift
let req = MentionRequest(threadId: threadId, onlyUnreadMention: false)
ChatManager.activeInstance?.message.mentions(.init)
```

### List of participants who delivered the message to them.
For retrieving the list of participants who the message delivered to them, use the method ``Chat/MessageProtocol/deliveredToParricipants(_:)`` like this:

```swift
let req = MessageDeliveredUsersRequest(messageId: messageId)
ChatManager.activeInstance?.message.deliveredToParricipants(req)
```

### List of participants who have seen the message.
For retrieving the list of participants who the message delivered to them, use the method ``Chat/MessageProtocol/seenByParticipants(_:)`` like this:

```swift
let req = MessageSeenByUsersRequest(messageId: messageId)
ChatManager.activeInstance?.message.seenByParticipants(req)
```

### Send seen of a message.
For the time that your user opens a thread in your application, that is your responsibility to inform the other participants to tell them you have seen the message. For this matter, use the method ``Chat/MessageProtocol/seen(_:)`` like this:

>Important: Sending a delivery of a message is Chat-SDK responsibility and it will happen automatically.
```swift
let req = MessageSeenRequest(messageId: messageId)
ChatManager.activeInstance?.message.seen(req)
```

### Cancel a message.
Cancel a message happens when a message is not sent by the SDK and canceling it will delete it from a cache of SDK respectively. For this call the method ``Chat/MessageProtocol/cancel(uniqueId:)`` like this:

```swift
ChatManager.activeInstance?.message.cancel(uniqueId: "XYZ...")
```

### Export Messages in CSV
To export a messages of a thread inside a `CSV` file, call the method ``Chat/MessageProtocol/export(_:)`` like this:
>Important: Please remove the file after you have finished using it.

>Note: Every time you call this function it will remove the older file.

>Note: This function only can export up to 10000 message at each call.

```swift
let req = GetHistoryRequest(threadId: threadId,
                            fromTime: UInt(startDate.millisecondsSince1970),
                            toTime: UInt(endDate.millisecondsSince1970))
ChatManager.activeInstance?.message.export(req)
```
