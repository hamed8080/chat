# Managing Users
Manage users such as get a list of roles and so more.

### Get user roles in a thread.
For getting the list of roles of the current user in a thread call the method ``Chat/UserProtocol/currentUserRoles(_:)`` like this:

```swift
let req = GeneralSubjectIdRequest(subjectId: threadId)
ChatManager.activeInstance?.user.currentUserRoles(req)
```

### Set a user roles
For setting roles of a user if you are owner of a thread use the method ``Chat/UserProtocol/set(_:)-9f5h7`` like this:

```swift
let usersRoles:[UserRoleRequest] = [.init(userId: userId, roles: [.THREAD_ADMIN , .EDIT_MESSAGE_OF_OTHERS])]
let req = RolesRequest(userRoles: [.init(userId: id, roles: userRoles)], threadId: threadId)
ChatManager.activeInstance?.user.set(req)
```

### Remove roles for a participant
For removing a set of roles of a user if you are owner of a thread use the method ``Chat/UserProtocol/remove(_:)-71zsk`` like this:

```swift
let usersRoles:[UserRoleRequest] = [.init(userId: userId, roles: [.THREAD_ADMIN , .EDIT_MESSAGE_OF_OTHERS])]
let req = RolesRequest(userRoles: usersRoles, threadId: 123456)
ChatManager.activeInstance?.user.remove(req)
```

### Set Auditor to a participant of a thread
For set a user auditor of a thread, use the method ``Chat/UserProtocol/set(_:)-1qwkb`` like this:

```swift
let usersRoles:[UserRoleRequest] = [.init(userId: userId, roles: [.THREAD_ADMIN , .EDIT_MESSAGE_OF_OTHERS])]
let req = threadId(userRoles: usersRoles, threadId: threadId)
ChatManager.activeInstance?.user.set(req)
```

### Remove Auditor roles from participants of a thread
For remove auditor roles of a thread participant, use the method ``Chat/UserProtocol/remove(_:)-63xy3`` like this:

```swift
let usersRoles:[UserRoleRequest] = [.init(userId: userId, roles: [.THREAD_ADMIN , .EDIT_MESSAGE_OF_OTHERS])]
let req = AuditorRequest(userRoles: usersRoles, threadId: threadId)
ChatManager.activeInstance?.user.remove(req)
```

### Tell the server user has been logged out.
For sending an event to the server that the user with the device has logged out call the method ``Chat/UserProtocol/logOut()`` like this:

```swift
ChatManager.activeInstance?.user.logOut()
```

### Get User Details
Fir getting details of the current user you could call method ``Chat/UserProtocol/userInfo(_:)`` like this:

```swift
let req = UserInfoRequest()
ChatManager.activeInstance?.user.userInfo(req)
```

### Update User Details
Fir updating details of the current user you could call method ``Chat/UserProtocol/set(_:)-6o86f`` like this:

```swift
let metaData = "{ "\birthDate\": \"26 Jun 1991\", \"constellation\": \"cancer\" }"
let req = UpdateChatProfile(bio: "Let's see my biography.", metadata: metaData)
ChatManager.activeInstance?.user.set(.init)
```
