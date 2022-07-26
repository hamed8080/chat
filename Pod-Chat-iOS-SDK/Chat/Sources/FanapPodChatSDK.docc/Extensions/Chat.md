# ``FanapPodChatSDK/Chat``

The chat server manages the async connection and the rest of the job for you, and you could send or receive messages or create a channel or group chat.


## Overview

The Chat class is the main class in the whole chat SDK, so you should take into consideration that this class is all that you need to connect and get your answer and it will tell you to result or maybe events that occur on the server with ``ChatDelegate``. 


## Managing Threads
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
CacheFactory.get(useCache: true, cacheType: .GET_THREADS(req)) { response in
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
Admin of a thread can close a thread to prevent participants send a message. The Thread must be one of types: ``ThreadTypes/CHANNEL``, ``ThreadTypes/CHANNEL_GROUP``,  ``ThreadTypes/NORMAL``.
Use mehod ``Chat/closeThread(_:completion:uniqueIdResult:)`` like below:

>Tip: Keep in mine ``ThreadTypes/NORMAL`` must be a group, not a P2P thread.

```swift
Chat.sharedInstance.closeThread(.init(threadId: 123456)) { closedThreadId, uniqueId, error in
    if let closedThreadId = closedThreadId {
        // Write your code
    }
}
```

### Spam a thread
For marking a thread as an spam you sould use method ``Chat/spamPvThread(_:completion:uniqueIdResult:)`` like this:

>Important: With marking a thread as spam three even occur: 
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
If you have a ``Roles/OWNERSHIP`` access for this thread you could completely delete the thread. ``Chat/deleteThread(_:completion:uniqueIdResult:)``.

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


## Managing Contacts
Managing contacts add, edit, delete, search, and more.

### Get Contacts

For retriving the list of contacts you need to call ``Chat/getContacts(_:completion:cacheResponse:uniqueIdResult:)`` like this:

You can set the size and offset if you would like to receive the list of contacts in lazy mode:

```swift
Chat.sharedInstance.getContacts(.init(count: 50, offset: 50)) { contacts, uniqueId, error in
    if error == nil{
        // Write your code
    }
}
```

### Get Blocked Contacts

For retriving the list of blocked contacts you need to call ``Chat/getBlockedContacts(_:completion:uniqueIdResult:)`` like this:

You can set the size and offset if you would like to receive the list of contacts in lazy mode:

```swift
Chat.sharedInstance.getBlockedContacts(.init(count: 50, offset: 50)) { contacts, uniqueId, error in
    if error == nil{
        // Write your code
    }
}
```

### Add Contact

For adding contacts you need to call ``Chat/addContact(_:completion:uniqueIdResult:)`` like this:

Add by cell phone number:
```swift
let req = AddContactRequest(cellphoneNumber: "+1XXXXXX", firstName: "firstName", lastName: "lastName")
```
Or add by email and user name:
```swift
let req = AddContactRequest(firstName:"firstName",lastName: "lastName", username: "userName")
```

```swift
Chat.sharedInstance.addContact(req) { contacts, uniqueId, error in
    if error == nil{
        // Write your code
    }
}
```


### Add Batch Contacts

For adding multiple contacts at once you'll need to call ``Chat/addContact(_:completion:uniqueIdResult:)`` like this:
```swift
let contact1 = AddContactRequest(cellphoneNumber: "+1XXXXXX", firstName: "firstName1", lastName: "lastName1")
let contact2 = AddContactRequest(cellphoneNumber: "+1XXXXXX", firstName: "firstName2", lastName: "lastName2")
let contacts = [contact1, contact2]
Chat.sharedInstance.addContacts(contacts) { contacts, uniqueId, error in
    if error == nil{
        // Write your code
    }
}
```

### Search For Contacts

For searching for contacts you need to call ``Chat/searchContacts(_:completion:cacheResponse:uniqueIdResult:)`` like this:
```swift
Chat.sharedInstance.searchContacts(.init(query: "John")) { contacts, uniqueId, pagination, error in
    if error == nil{
        // Write your code
    }
}
```

### Remove a contact

For deleting a contact you need to call ``Chat/removeContact(_:completion:uniqueIdResult:)`` like this:
```swift
Chat.sharedInstance.searchContacts(.init(query: "John")) { deletd, uniqueId, error in
    if deleted == true{
        // Write your code
    }
}
```

### Check last seen of the user

To get to know when was the last time a user was online you should use ``Chat/contactNotSeen(_:completion:uniqueIdResult:)`` like this:
```swift
Chat.sharedInstance.contactNotSeen(.init(userIds:[123456, 67890])) { users, uniqueId, error in
    if error == nil{
        // Write your code
    }
}
```

### Sync Contacts

Sync contact with server is done by using ``Chat/syncContacts(completion:uniqueIdsResult:)`` like this:
```swift
Chat.sharedInstance.syncContacts { contacts, uniqueId, error in
    if error == nil{
        // Write your code
    }
}
```

### Update contacts

To get to know when was the last time a user was online you should use ``Chat/updateContact(_:completion:uniqueIdsResult:)`` like this:
```swift
Chat.sharedInstance.updateContact { contacts, uniqueId, error in
    if error == nil{
        // Write your code
    }
}
```

### Block a contact

For blocking a contact you need to do it with one of userId, contactId or threadId ``Chat/blockContact(_:completion:uniqueIdResult:)`` like this:
```swift
Chat.sharedInstance.blockContact(.init(contactId:123456)) { blockedContact, uniqueId, error in
    if error == nil{
        // Write your code
    }
}
```

### UNBlock a blocked contact

For unblocking a contact you need to do it with one of userId, contactId or threadId ``Chat/unBlockContact(_:completion:uniqueIdResult:)`` like this:
```swift
Chat.sharedInstance.unBlockContact(.init(contactId:123456)) { blockedContact, uniqueId, error in
    if error == nil{
        // Write your code
    }
}
```


## Map and Locations
Converting lat, long to an address or searching through a map, or finding a route getting an image of lat, long. 


### Reverse a lat, long to an address

Reverse a latitude or longitude to a human readable address ``Chat/mapReverse(_:completion:uniqueIdResult:)`` like this:
```swift
Chat.sharedInstance.mapReverse(.init(lat: 37.33900249783756 , lng: -122.00944807880965)) { mapReverse, uniqueId, error in
    if error == nil{
        // Write your code
    }
}
```

### Search for Items inside an area

Search for items inside an area with lat and long you should use method ``Chat/mapSearch(_:completion:uniqueIdResult:)`` like this:
```swift
Chat.sharedInstance.mapSearch(.init(lat: 37.33900249783756 , lng: -122.00944807880965)) { mapItems, uniqueId, error in
    if error == nil{
        // Write your code
    }
}
```

### Finding route

Finding a route between two point. 
If you want to receive more than one route please set alternative to true.
Use method ``Chat/mapSearch(_:completion:uniqueIdResult:)`` like this:
```swift
let origin = Cordinate(lat: 37.33900249783756, lng: -122.00944807880965)
let destination = Cordinate(lat: 22.33900249783756, lng: -110.00944807880965)
Chat.sharedInstance.mapRouting(.init(alternative: true, origin: origin, destination: destination) ) { routes, uniqueId, error in
    if error == nil{
        // Write your code
    }
}
```

### Convert an cordinate to an image

Convert an location to an image use the method ``Chat/mapStaticImage(_:completion:uniqueIdResult:)`` like this:
```swift
let center = Cordinate(lat: 37.33900249783756, lng: -122.00944807880965)
let req = MapStaticImageRequest(center: center)
Chat.sharedInstance.mapStaticImage(req) { imageData, uniqueId, error in
    if let data = data, let image = UIImage(data: data){
        // Write your code
    }
}
```

## Managing Bots
For creating, add/remove command, user bots, start/stop.

### Create Bot

For creating a bot use method ``Chat/createBot(_:completion:uniqueIdResult:)`` like this:
```swift
Chat.sharedInstance.createBot(.init(botName: "MyBotName")) { bot, uniqueId, error in
    if let bot = bot{
        // Write your code
    }
}
```

### Adding Commands

For adding commands to a bot use method ``Chat/addBotCommand(_:completion:uniqueIdResult:)`` like this:
```swift
let commandList:[String] = ["/start", "/write", "/publish"]
let req = AddBotCommandRequest(botName: "MyBotName", commandList: commandList)
Chat.sharedInstance.addBotCommand(req) { botInfo, uniqueId, error in
    if let botInfo = botInfo{
        // Write your code
    }
}
```

### Removing Commands

For removing commands to a bot use method ``Chat/removeBotCommand(_:completion:uniqueIdResult:)`` like this:
```swift
let commandList:[String] = ["/start", "/write", "/publish"]
let req = RemoveBotCommandRequest(botName: "MyBotName", commandList: commandList)
Chat.sharedInstance.removeBotCommand(req) { botInfo, uniqueId, error in
    if let botInfo = botInfo{
        // Write your code
    }
}
```

### Add a bot to a thread

>Tip: For adding bot to a thread you must add it like a participant with method ``Chat/addParticipant(_:completion:uniqueIdResult:)`` like this:
```swift
Chat.sharedInstance.addParticipant(.init(userName: "MyBotName", threadId: 123456)) { thread, uniqueId, error in
    if let thread = thread{
        // Write your code
    }
}
```

### Start a bot

For starting a bot sue the method ``Chat/startBot(_:completion:uniqueIdResult:)`` like this:
```swift
Chat.sharedInstance.startBot(.init(botName: "MyBotName", threadId: 123456)) { botName, uniqueId, error in
    if let botName = botName{
        // Write your code
    }
}
```

### Stop a bot

For stopping a bot sue the method ``Chat/stopBot(_:completion:uniqueIdResult:)`` like this:
```swift
Chat.sharedInstance.stopBot(.init(botName: "MyBotName", threadId: 123456)) { botName, uniqueId, error in
    if let botName = botName{
        // Write your code
    }
}
```
## Managing User
Get current user details, update, set profile.

### Get User Details
Fir getting details of the current user you could call method ``Chat/getUserInfo(_:completion:cacheResponse:uniqueIdResult:)`` like this:

```swift
Chat.sharedInstance.getUserInfo(.init()) { user, uniqueId, error in
    if let user = user{
        // Write your code
    }
}
```

### Update User Details
Fir updating details of the current user you could call method ``Chat/setProfile(_:completion:uniqueIdResult:)`` like this:

```swift
let metaData = "{ "\birthDate\": \"26 Jun 1991\", \"constellation\": \"cancer\" }"
Chat.sharedInstance.setProfile(.init(bio: "Let's see my biography.", metadata: metaData)) { profile, uniqueId, error in
    if let profile = profile{
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

