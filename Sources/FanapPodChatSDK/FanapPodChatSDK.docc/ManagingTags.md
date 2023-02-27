# Managing Tags

Tags are like folder for managing threads. You could Add, delete, edit and add/remove tag participans.

### Tag List
For retrieving the list of tags use method ``Chat/tagList(_:completion:cacheResponse:uniqueIdResult:)`` like this:
```swift
Chat.sharedInstance.tagList() { tags, uniqueId, error in
    if let tags = tags{
        // Write your code
    }
}
```

### Create Tag
For adding a new tag use method ``Chat/createTag(_:completion:uniqueIdResult:)`` like this:
```swift
let req = CreateTagRequest(tagName: "Social")
Chat.sharedInstance.createTag(req) { tag, uniqueId, error in
    if let tag = tag{
        // Write your code
    }
}
```

### Edit Tag
For editing a tag of tags use method ``Chat/editTag(_:completion:uniqueIdResult:)`` like this:
```swift
let req = CreateTagRequest(id: 12, tagName: "Social")
Chat.sharedInstance.editTag(req) { tag, uniqueId, error in
    if let tag = tag{
        // Write your code
    }
}
```

### Delete Tag
For deleting a tag use method ``Chat/deleteTag(_:completion:uniqueIdResult:)`` like this:

>Tip: With deleting a tag the threads inside a tag remain untouched.
```swift
Chat.sharedInstance.deleteTag(.init(id: 12)) { tag, uniqueId, error in
    if let tag = tag{
        // Write your code
    }
}
```

### Add thread to a tag 
For adding a thread inside a tag use method ``Chat/addTagParticipants(_:completion:uniqueIdResult:)`` like this:

>Tip: Each thread can be added to multiple tags at the same time.
```swift
Chat.sharedInstance.addTagParticipants(.init(tagId: 12, threadsId: [123456])) { tagParticipant, uniqueId, error in
    if let tagParticipant = tagParticipant{
        // Write your code
    }
}
```

### Remove tag participants 
For removing tag participants from a tag a use method ``Chat/removeTagParticipants(_:completion:uniqueIdResult:)`` like this:
```swift
Chat.sharedInstance.removeTagParticipants(.init(tagId: 12, tagParticipants: [123456])) { tagParticipant, uniqueId, error in
    if let tagParticipant = tagParticipant{
        // Write your code
    }
}
```
