# Managing Assistants
Adding a participant as an assistant.

>Important: A assitant is only work in P2P thread with two participant. You can not have an assistatnt in group or channel.

>Note: The server guarantee that it will add assistants to a P2P-thread automatically. 

### Register participants as assistants
To register participants as assistants use the method ``Chat/registerAssistat(_:completion:uniqueIdResult:)``
```swift
let invitee = Invitee(id: 123456, idType: .TO_BE_USER_ID)
let roles:[Roles] = [.READ_THREAD, .EDIT_THREAD, .ADD_RULE_TO_USER]
let assistant = Assistant(assistant: invitee, contactType: "default", roleTypes: roles)
Chat.sharedInstance.registerAssistat(.init(assistants: [assistant])) { assistants, uniqueId, error in
    // Write your code
}
```
### Deactivate assistants
To deactivate assistants use the method ``Chat/deactiveAssistant(_:completion:uniqueIdResult:)``
```swift
Chat.sharedInstance.deactiveAssistant(.init(assistants: [assistant])) { assistants, uniqueId, error in
    // Write your code
}
```

### Get list of assistants
To get a list of assistants for the current user, use the method ``Chat/getAssistats(_:completion:cacheResponse:uniqueIdResult:)``
```swift
let req = AssistantsRequest(contactType: "default")
Chat.sharedInstance.getAssistats(req) {  assistants, uniqueId,pagination, error in
    // Write your code
}
```

### Get list of assistants actions
To get a list of actions that a assistant performed, use the method ``Chat/getAssistatsHistory(_:uniqueIdResult:)``
```swift
Chat.sharedInstance.getAssistatsHistory() { assistantActions, uniqueId, error in
    // Write your code
}
```

### Get list of blocked assistants
To get a list of blocked assistants, use the method ``Chat/getBlockedAssistants(_:_:cacheResponse:uniqueIdResult:)``
```swift
Chat.sharedInstance.getBlockedAssistants(.init(count: 50, offset: 0)) { blockedAssistants, uniqueId, pagination, error in
    // Write your code
}
```

### Block assistants
To block assistants, use the method ``Chat/blockAssistants(_:_:uniqueIdResult:)``
```swift
Chat.sharedInstance.blockAssistants(.init(assistants:assistants)) { blockedAssistants, uniqueId, pagination, error in
    // Write your code
}
```

### UNBlock assistants
To unblock assistants, use the method ``Chat/unblockAssistants(_:_:uniqueIdResult:)``
```swift
Chat.sharedInstance.unblockAssistants(.init(assistants:assistants)) { unblockedAssistants, uniqueId, pagination, error in
    // Write your code
}
```
