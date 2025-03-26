# Managing Threads

Managing threads, create P2P, Group, Channel or delete edit and so many more. 


### Get Threads
Get list of theads. Call the method ``Chat/ThreadProtocol/get(_:)`` like this:
You can send a request in pagination mode and set offset.

```swift
let req = ThreadsRequest(count: count, offset: offset)
ChatManager.activeInstance?.conversation.get(req)
```

### Create a thread
For creating a thread use the ``Chat/ThreadProtocol/create(_:)-64b7s`` method with an object of type ``CreateThreadRequest``.
Each thread contains a ``Conversation/type`` which determine if the thread is P2P, Group, Channel or e.g.

```swift
let invitee = Invitee(id: "\(id)", idType: .CONTACT_ID)
ChatManager.activeInstance?.conversation.create(.init(invitees: [invitee], type: .NORMAL))
```

### Create a Thread with a message
Createing a thread with a message with the method ``Chat/ThreadProtocol/create(_:)-3epo``.
```swift
let invitee = Invitee(id: "\(123456)", idType: .CONTACT_ID)
let textMessage = CreateThreadMessage(text: "Hello")
let req = CreateThreadWithMessage(invitees:[invitee], title: "", message: textMessage)
ChatManager.activeInstance?.conversation.create(req)
```

### Create a thread with a message and upload a file
For creating a thread with file use ``CreateThreadRequest`` method ``Chat/ThreadProtocol/create(_:)-64b7s``.

>Tip: Most of the closures here are optional if you don't need one of them just don't pass it as a parameter.

```swift
let invitee = Invitee(id: "\(123456)", idType: .CONTACT_ID)
let req = CreateThreadRequest(invitees:[invitee], title: "")
let textMessage = SendTextMessageRequest(textMessage: "Hello", messageType: .POD_SPACE_PICTURE, metadata: "{your_json_metadata}")
let uploadReq = UploadFileRequest(data: imageData)
ChatManager.activeInstance?.conversation.create(req)
```

### Add Participant or Participants
Add participants with contactIds, userName or coreUserId ``Chat/ParticipantProtocol/add(_:)``.
Each thread contains a ``Conversation/type`` which determine if the thread is P2P, Group, Channel or e.g.

```swift
let req = AddParticipantRequest(contactIds: [], threadId: threadId)
ChatManager.activeInstance?.conversation.participant.add(req)
```

### Delete Participants
Delete participants from a thread ``Chat/ParticipantProtocol/remove(_:)``.

```swift
let req = RemoveParticipantRequest(participantId: participantId, threadId: threadId)
ChatManager.activeInstance?.conversation.participant.remove(req)
```

### Join To a thread
Join to a public thread ``Chat/ThreadProtocol/join(_:)``.

```swift
let req = JoinPublicThreadRequest(threadName: publicName)
ChatManager.activeInstance?.conversation.join(req)
```

### Close a thread
Admin of a thread can close a thread to prevent participants send a message. The Thread must be one of types: ``ThreadTypes/channel``, ``ThreadTypes/channelGroup``,  ``ThreadTypes/normal``.
Use mehod ``Chat/ThreadProtocol/close(_:)`` like below:

>Tip: Keep in mind that ``ThreadTypes/normal`` must be a group, not a P2P conversation.

```swift
let req = GeneralSubjectIdRequest(subjectId: threadId)
ChatManager.activeInstance?.conversation.close(req)
```

### Spam a thread
For marking a thread spam, you sould use method ``Chat/ThreadProtocol/spam(_:)`` like this:

>Important: With marking a thread as spam three events occur: 
1. An event of the creator of the thread got blocked.
2. An event for leaving the thread.
3. An event that mentions that the content of the thread was deleted.

```swift
let req = GeneralSubjectIdRequest(subjectId: threadId)
ChatManager.activeInstance?.conversation.spam(req)
```

### Update a thread
For updating title, description, image of a thread use ``Chat/ThreadProtocol/updateInfo(_:)`` like this:

```swift
let req = UpdateThreadInfoRequest(description: "Description", threadId: threadId, title: "title")
ChatManager.activeInstance?.conversation.updateInfo(req)
```

### Leave a thread
for leaving a thread use method  ``Chat/ThreadProtocol/leave(_:)`` like this:

>Tip: If set ``LeaveThreadRequest/clearHistory`` to `true` all contents of the thread will be deleted for the user and even after joining again those contents will not be available. 

```swift
let req = LeaveThreadRequest(threadId: threadId, clearHistory: true)
ChatManager.activeInstance?.conversation.leave(req)
```

### Replace admin and leave a thread
If you are the only admin of a thread and you have decided to leave the thread it's better to find a person as an admin you should call method,  ``Chat/ThreadProtocol/leaveSafely(_:)`` like this:

```swift
let req = SafeLeaveThreadRequest(threadId: threadId, participantId: participantId)
Chat.sharedInstance.leaveSaftly(req)
```

### Delete a thread
If you have a ``Roles/ownership`` access of the thread you can completely delete the thread. ``Chat/ThreadProtocol/delete(_:)``.

>Important: Following things will happen if you delete a thread:
- All members are deleted from the channel or group and they will grtbvhvefcdwsareceive a message about it.
- All members of the thread will receive a message that contains who deleted the thread. 

```swift
let req = GeneralSubjectIdRequest(subjectId: threadId)
ChatManager.activeInstance?.conversation.delete(.init)
```

### All threads(Ids)
Getting the list of all threads by itself is not useful, if you set the summary of this request to true you will receive only the list of thread ids `[Int]`  so the only filed that will set is ``Conversation/id``. 

```swift
let req = init(summary: true)
ChatManager.activeInstance?.conversation.get(req)
```

### Public thread name
Before creating a public thread be sure that thread name is free and it's not occupied.You can check this matter with ``Chat/ThreadProtocol/isNameAvailable(_:)``.

```swift
let req = IsThreadNamePublicRequest(name: "Social")
ChatManager.activeInstance?.conversation.isNameAvailable(req)
```

### Mute a thread
For mute a thread to prevent receive notification use method ``Chat/ThreadProtocol/mute(_:)``.

```swift
let req = GeneralSubjectIdRequest(subjectId: threadId)
ChatManager.activeInstance?.conversation.mute(req)
```

### Unmute a thread
For unmuteing a thread to receive notification agian use method ``Chat/ThreadProtocol/unmute(_:)``.

```swift
let req = GeneralSubjectIdRequest(subjectId: threadId)
ChatManager.activeInstance?.conversation.unmute(req)
```

### Pin a thread
With pining a thread you could put it at the top of list ``Chat/ThreadProtocol/pin(_:)``.

```swift
let req = GeneralSubjectIdRequest(subjectId: threadId)
ChatManager.activeInstance?.conversation.pin(req)
```

### UnPin a thread
Unpin a thread that was pinned before ``Chat/ThreadProtocol/unpin(_:)``.

```swift
let req = GeneralSubjectIdRequest(subjectId: threadId)
ChatManager.activeInstance?.conversation.unpin(req)
```

### Get Thread Participants
For getting list of participants of a thread you first need to use inner property ``Chat/ThreadProtocol/participant`` and use method ``Chat/ParticipantProtocol/get(_:)`` like this:

>Tip: For getting the list of admins inside a thread just pass `true` for ``Chat/ThreadParticipantRequest/admin`` property in this request.
```swift
let req = ThreadParticipantRequest(threadId: threadId, admin: true)
Chat.sharedInstance.conversation.participant.get(req)
```

### Change Thread Type
For changing the type of a thread use method ``Chat/ThreadProtocol/changeType(_:)`` like this:
```swift
let req = (threadId: threadId, type: .CHANNEL)
ChatManager.activeInstance?.conversation.changeType(req)
```

### Mutual groups
For getting the list of threads that are mutuals between the current user and desired user, use method ``Chat/ThreadProtocol/mutual(_:)`` like this:
```swift
let req = MutualGroupsRequest(toBeUser: invitee, count: count, offset: offset)
ChatManager.activeInstance?.conversation.mutual(req)
```
