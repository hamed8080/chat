# Managing Users
Manage users such as get a list of roles and so more.

### Get user roles in a thread.

For getting the list of roles of the current user in a thread call the method ``Chat/getCurrentUserRoles(_:completion:cacheResponse:uniqueIdResult:)`` like this:

```swift
Chat.sharedInstance.getCurrentUserRoles(.init(threadId: 123456)) { roles, uniqueId, error in
    // Write your code
}
```


### Set a user roles

For setting roles of a user if you are owner of a thread use the method ``Chat/setRoles(_:_:uniqueIdResult:)`` like this:

```swift
let usersRoles:[UserRoleRequest] = [.init(userId: userId, roles: [.THREAD_ADMIN , .EDIT_MESSAGE_OF_OTHERS])]
Chat.sharedInstance.setRoles(.init(userRoles: usersRoles, threadId: 123456)) { usersRoles, uniqueId, error in
    // Write your code
}
```

### Remove roles for a participant

For removing a set of roles of a user if you are owner of a thread use the method ``Chat/removeRoles(_:_:uniqueIdResult:)`` like this:

```swift
let usersRoles:[UserRoleRequest] = [.init(userId: userId, roles: [.THREAD_ADMIN , .EDIT_MESSAGE_OF_OTHERS])]
Chat.sharedInstance.removeRoles(.init(userRoles: usersRoles, threadId: 123456)) { removedRoles, uniqueId, error in
    // Write your code
}
```

### Set Auditor to a participant of a thread

For set a user auditor of a thread, use the method ``Chat/setAuditor(_:_:uniqueIdResult:)`` like this:

```swift
let usersRoles:[UserRoleRequest] = [.init(userId: userId, roles: [.THREAD_ADMIN , .EDIT_MESSAGE_OF_OTHERS])]
Chat.sharedInstance.setAuditor(.init(userRoles: usersRoles, threadId: 123456)) { useRoles, uniqueId, error in
    // Write your code
}
```


### Remove Auditor roles from participants of a thread

For remove auditor roles of a thread participant, use the method ``Chat/removeAuditor(_:_:uniqueIdResult:)`` like this:

```swift
let usersRoles:[UserRoleRequest] = [.init(userId: userId, roles: [.THREAD_ADMIN , .EDIT_MESSAGE_OF_OTHERS])]
Chat.sharedInstance.removeAuditor(.init(userRoles: usersRoles, threadId: 123456)) { useRoles, uniqueId, error in
    // Write your code
}
```
