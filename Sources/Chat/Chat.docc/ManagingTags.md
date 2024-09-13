# Managing Tags

Tags are like folder for managing threads. You could Add, delete, edit and add/remove tag participans.

### Tag List
For retrieving the list of tags use method ``Chat/TagProtocol/all()`` like this:
```swift
ChatManager.activeInstance?.tag.all()
```

### Create Tag
For adding a new tag use method ``Chat/TagProtocol/create(_:)`` like this:
```swift
let req = CreateTagRequest(tagName: "Social")
ChatManager.activeInstance?.tag.create(req)
```

### Edit Tag
For editing a tag of tags use method ``Chat/TagProtocol/edit(_:)`` like this:
```swift
let req = CreateTagRequest(id: 12, tagName: "Social")
ChatManager.activeInstance?.tag.edit(req)
```

### Delete Tag
For deleting a tag use method ``Chat/TagProtocol/delete(_:)`` like this:

>Tip: With deleting a tag the threads inside a tag remain untouched.
```swift
let req = DeleteTagRequest(id: tagId)
ChatManager.activeInstance?.tag.delete(req)
```

### Add thread to a tag 
For adding a thread inside a tag use method ``Chat/TagProtocol/add(_:)`` like this:

>Tip: Each thread can be added to multiple tags at the same time.
```swift
let req = AddTagParticipantsRequest(tagId: tagId, threadsId: [threadId])
ChatManager.activeInstance?.tag.add(req)
```

### Remove tag participants 
For removing tag participants from a tag a use method ``Chat/TagProtocol/remove(_:)`` like this:
```swift
let req = RemoveTagParticipantsRequest(tagId: tagId, tagParticipants: [threadId])
ChatManager.activeInstance?.tag.remove(.init)
```
