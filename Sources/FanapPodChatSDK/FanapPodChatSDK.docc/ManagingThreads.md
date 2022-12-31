# Managing Threads

Managing threads create P2P, Group, Channel or delete edit and so many more. 


### Get Threads

Get threads list. Call the method ``Chat/getThreads(_:completion:cacheResponse:uniqueIdResult:)`` like this:
You can send request in pagination mode and set offset.

```swift
Chat.sharedInstance.getThreads(init(offset: 50)) { threads, uniqueId, pagination, error in
    if error == nil{
        // Write your code
    }
}cacheResponse{ threads, uniqueId, pagination, error in
    if threads = threads {
        // Write your code
    } 
}
```

For retriving data witouth calling network you could use ``CacheFactory/get(useCache:cacheType:completion:)``
It won't work unless you set `enableCache` to true in configuration.
```swift
let req = ThreadsRequest(count:50, offset: 0)
cache?.get(useCache: true, cacheType: .GET_THREADS(req)) { response in
    if let threads = response.cacheResponse as? [Conversation]{
        // Write your code
    }
}
```

### Create a thread
For creating a thread use method with a ``CreateThreadRequest`` ``Chat/createThread(_:completion:uniqueIdResult:)``.
Each thread contains a ``Conversation/type`` which determine if the thread is P2P, Group, Channel or e.g.

```swift
let invitee = Invitee(id: "\(123456)", idType: .CONTACT_ID)
Chat.sharedInstance.createThread(.init(invitees: [invitee], type: .NORMAL)) { thread, unqiueId, error in
    if let thread = thread {
        // Write your code
    }
}
```

### Create Thread with message
Createing a thread with a message with ``Chat/createThreadWithMessage(_:uniqueIdResult:onSent:onDelivery:onSeen:completion:)``.
```swift
let invitee = Invitee(id: "\(123456)", idType: .CONTACT_ID)
let textMessage = CreateThreadMessage(text: "Hello")
let req = CreateThreadWithMessage(invitees:[invitee], title: "", message: textMessage)
Chat.sharedInstance.createThreadWithMessage(req) { uniqueId in
    // Write your code
} onSent: { sentResponse, uniqueId, error in
    // Write your code
} onDelivery: { deliveryResponse, uniqueId, error in
    // Write your code
} onSeen: { seenResponse, uniqueId, error in
    // Write your code
} completion: { thread, uniqueId, error in
    // Write your code
}
```

### Create a thread with message and upload a file
For creating a thread with file use method with a ``CreateThreadRequest`` ``Chat/createThreadWithFileMessage(_:textMessage:uploadFile:uploadProgress:onSent:onSeen:onDeliver:createThreadCompletion:uploadUniqueIdResult:messageUniqueIdResult:)``.

>Tip: Most of the closures here are optional if you don't need one of them just don't pass it as a parameter.

```swift
let invitee = Invitee(id: "\(123456)", idType: .CONTACT_ID)
let req = CreateThreadRequest(invitees:[invitee], title: "")
let textMessage = SendTextMessageRequest(textMessage: "Hello", messageType: .POD_SPACE_PICTURE)
let uploadReq = UploadFileRequest(data: imageData)
Chat.sharedInstance.createThreadWithFileMessage(req, textMessage: textMessage, uploadFile: uploadReq) { uploadProgress, error in
    // Write your code
} onSent: { sentReponse, uniqueId, error in
    // Write your code
} onSeen: { seenResponse, uniqueId, error in
    // Write your code
} onDeliver: { deliverResponse, uniqueId, error in
    // Write your code
} createThreadCompletion: { thread, uniqueId, error in
    // Write your code
} uploadUniqueIdResult: { uniqueId in
    // Write your code
} messageUniqueIdResult: { uniqueId in
    // Write your code
}
```

### Add Participant or Participants
Add participants with contactIds, userName or coreUserId ``Chat/addParticipant(_:completion:uniqueIdResult:)``.
Each thread contains a ``Conversation/type`` which determine if the thread is P2P, Group, Channel or e.g.

```swift
let req = AddParticipantRequest(contactIds: [123456], threadId: 7890)
Chat.sharedInstance.addParticipant(req) { thread, uniqueId, error in
    if let thread = thread { 
        // Write your code
    }
}
```

### Delete Participants
Delete participants from a thread ``Chat/removeParticipants(_:completion:uniqueIdResult:)``.

```swift
Chat.sharedInstance.removeParticipants(.init(participantId: 123456, threadId: 456789)) { deletedParticipants, uniqueId, error in
    if let thread = thread {
        // Write your code
    }
}
```

### Join To a thread
Join to a public thread ``Chat/joinThread(_:completion:uniqueIdResult:)``.

```swift
Chat.sharedInstance.joinThread(.init(threadName: "MyPublicThreadName")) { thread, uniqueId, error in
    if let thread = thread {
        // Write your code
    }
}
```

### Close a thread
Admin of a thread can close a thread to prevent participants send a message. The Thread must be one of types: ``ThreadTypes/channel``, ``ThreadTypes/channelGroup``,  ``ThreadTypes/normal``.
Use mehod ``Chat/closeThread(_:completion:uniqueIdResult:)`` like below:

>Tip: Keep in mine ``ThreadTypes/normal`` must be a group, not a P2P thread.

```swift
Chat.sharedInstance.closeThread(.init(threadId: 123456)) { closedThreadId, uniqueId, error in
    if let closedThreadId = closedThreadId {
        // Write your code
    }
}
```

### Spam a thread
For marking a thread as an spam you sould use method ``Chat/spamPvThread(_:completion:uniqueIdResult:)`` like this:

>Important: With marking a thread as spam three events occur: 
1. An event of the creator of the thread got blocked.
2. An event for leaving the thread.
3. An event that mentions that the content of the thread was deleted.

```swift
Chat.sharedInstance.spamPvThread(.init(threadId: 123456)) { blockedContact, uniqueId, error in
    if let blockedContact = blockedContact {
        // Write your code
    }
}
```

### Update a thread
For updating title, description, image of a thread use ``Chat/updateThreadInfo(_:uniqueIdResult:uploadProgress:completion:)`` like this:

```swift
let req = UpdateThreadInfoRequest(description: "News about Tech", threadId: 123456, title: "Tech News")
Chat.sharedInstance.updateThreadInfo(req) { thread, uniqueId, error in
    if let thread = thread {
        // Write your code
    }
}
```

### Leave a thread
for leaving a thread use method  ``Chat/leaveThread(_:completion:uniqueIdResult:)`` like this:

>Tip: If set ``LeaveThreadRequest/clearHistory`` to `true` all content of that thread will be deleted for the user and even after joining again those content is not availanble. 

```swift
Chat.sharedInstance.leaveThread(.init(threadId: 123456, clearHistory: true)) { user, uniqueId, error in
    if let user = user {
        // Write your code
    }
}
```

### Replace admin and leave a thread
If you are the only admin of a thread and you have decided to leave the thread it's better to find a person as an admin you should call method,  ``Chat/leaveThreadSaftly(_:completion:newAdminCompletion:uniqueIdResult:)`` like this:

```swift
let req = SafeLeaveThreadRequest(threadId: 123456, participantId: 4567890)
Chat.sharedInstance.leaveThreadSaftly(req) { user, uniqueId, error in
    if let user = user {
        // Write your code
    }
}newAdminCompletion{ userRoles, uniqueId, error in
    // Write your code
}
```

### Delete a thread
If you have a ``Roles/ownership`` access for this thread you could completely delete the thread. ``Chat/deleteThread(_:completion:_:)``.

>Important: Following things will happen if you delete a thread:
- All members are deleted from the channel or group and will receive a message about it.
- All members of the thread will receive a message that contains who deleted the thread. 

```swift
Chat.sharedInstance.deleteThread(.init(threadId: 123456)) { threadId, unqiueId, error in
    if let threadId = threadId {
        // Write your code
    }
}
```

### All threads(Ids)
Getting the list of all threads by itself is not useful, if you set the summary of this request to true you will receive only the list of thread ids  `[Int]`  so the only filed that will set is ``Conversation/id``. 

```swift
Chat.sharedInstance.getAllThreads(.init(summary: true)) { threadIds, unqiueId, error in
    if let threadIds = threadIds {
        // Write your code
    }
}
```

### Public thread name
Before creating a public thread be sure that thread name is free and it's not occupied.You can check this matter with ``Chat/isThreadNamePublic(_:completion:uniqueIdResult:)``.

```swift
Chat.sharedInstance.isThreadNamePublic(.init(name: "Social")) { threadName, unqiueId, error in
    if let threadName = threadName {
        // Write your code
    }
}
```

### Mute a thread
For mute a thread to prevent receive notification use method ``Chat/muteThread(_:completion:uniqueIdResult:)``.

```swift
Chat.sharedInstance.muteThread(.init(threadId: 123456)) { threadId, unqiueId, error in
    if let threadId = threadId {
        // Write your code
    }
}
```

### Unmute a thread
For unmuteing a thread to receive notification agian use method ``Chat/unmuteThread(_:completion:uniqueIdResult:)``.

```swift
Chat.sharedInstance.unmuteThread(.init(threadId: 123456)) { threadId, unqiueId, error in
    if let threadId = threadId {
        // Write your code
    }
}
```

### Pin a thread
With pining a thread you could put it at the top of list ``Chat/pinThread(_:completion:uniqueIdResult:)``.

```swift
Chat.sharedInstance.pinThread(.init(threadId: 123456)) { threadId, unqiueId, error in
    if let threadId = threadId {
        // Write your code
    }
}
```

### UnPin a thread
Unpin a thread that was pinned before ``Chat/pinThread(_:completion:uniqueIdResult:)``.

```swift
Chat.sharedInstance.unpinThread(.init(threadId: 123456)) { threadId, unqiueId, error in
    if let threadId = threadId {
        // Write your code
    }
}
```

### Get Thread Participants
For getting list of participants of a thread use method ``Chat/getThreadParticipants(_:completion:cacheResponse:uniqueIdResult:)`` like this:

>Tip: For getting the list of admins inside a thread just pass `true` for ``ThreadParticipantsRequest/admin`` property in this request.
```swift
Chat.sharedInstance.getThreadParticipants(.init(threadId: 123456)) { participants, uniqueId, error in
    if let participants = participants{
        // Write your code
    }
}
```

### Get Thread Admin
For getting list of admins of a thread use method ``Chat/getThreadAdmins(_:completion:cacheResponse:uniqueIdResult:)`` like this:

```swift
Chat.sharedInstance.getThreadAdmins(.init(threadId: 123456)) { admins, uniqueId, error in
    if let admins = admins{
        // Write your code
    }
}
```

### Change Thread Type
For changing the type of a thread use method ``Chat/changeThreadType(_:completion:uniqueIdResult:)`` like this:
```swift
Chat.sharedInstance.changeThreadType(.init(threadId: 123456, type: .CHANNEL)) { admins, uniqueId, error in
    if let admins = admins{
        // Write your code
    }
}
```

### Mutual groups
For getting the list of threads that are mutuals between the current user and desired user, use method ``Chat/mutualGroups(_:_:cacheResponse:uniqueIdResult:)`` like this:
```swift
let user = Invitee(id: 123456, idType: CONTACT_ID)
Chat.sharedInstance.mutualGroups(.init(toBeUser: user)) { mutualThreads, uniqueId, pagination, error in
    // Write your code
}
```
