# Managing Assistants
Adding a participant as an assistant.

>Important: A assitant is only work in P2P thread with two participant. You can not have an assistatnt in group or channel.

>Note: The server guarantee that it will add assistants to a P2P-thread automatically. 

### Register participants as assistants
To register participants as assistants use the method ``Chat/AssistantProtocol/register(_:)``
```swift
let invitee = Invitee(id: "\(id)", idType: .TO_BE_USER_ID)
let roles:[Roles] = [.READ_THREAD, .EDIT_THREAD, .ADD_RULE_TO_USER]
let assistant = Assistant(assistant: invitee, contactType: "default", roleTypes: roles)
let req = AssistantsRequest(assistants: [assistant])
ChatManager.activeInstance?.assistant.register(req)
```

>Important: To detect an assistant you should use **Assistant.participant.id** field.

### Deactivate assistants
To deactivate assistants use the method ``Chat/AssistantProtocol/deactive(_:)``
```swift
let req = DeactiveAssistantRequest(assistants: [assistant])
ChatManager.activeInstance?.assistant.deactive(req)
```

### Get list of assistants
To get a list of assistants for the current user, use the method ``Chat/AssistantProtocol/get(_:)``
```swift
let req = AssistantsRequest(contactType: "default")
ChatManager.activeInstance?.assistant.get(req)
```

### Get list of assistants actions
To get a list of actions that a assistant performed, use the method ``Chat/AssistantProtocol/history(_:)``
```swift
let req = AssistantsHistoryRequest()
ChatManager.activeInstance?.assistant.history(req)
```

### Get list of blocked assistants
To get a list of blocked assistants, use the method ``Chat/AssistantProtocol/blockedList(_:)``
```swift
let req = BlockedAssistantsRequest(count: 50, offset: 0)
ChatManager.activeInstance?.assistant.blockedList(req)
```

### Block assistants
To block assistants, use the method ``Chat/AssistantProtocol/block(_:)``
```swift
let req = BlockUnblockAssistantRequest(assistants: assistants)
ChatManager.activeInstance?.assistant.block(req)
```

### UNBlock assistants
To unblock assistants, use the method ``Chat/AssistantProtocol/unblock(_:)``
```swift
let req = BlockUnblockAssistantRequest(assistants: assistants)
ChatManager.activeInstance?.assistant.unblock(req)
```
