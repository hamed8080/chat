# Managing Contacts
Managing contacts add, edit, delete, search, and more.


### Get Contacts
For retriving the list of contacts you need to call ``Chat/ContactProtocol/get(_:)`` like this:

You can set the size and offset if you would like to receive the list of contacts in lazy mode:

```swift
let req = ContactsRequest(count: 50, offset: 50)
ChatManager.activeInstance?.contact.get(req)
```

### Get Blocked Contacts
For retriving the list of blocked contacts you need to call ``Chat/ContactProtocol/getBlockedList(_:)-3duud`` like this:

You can set the size and offset if you would like to receive the list of contacts in lazy mode:

```swift
let req = BlockedListRequest(count: 50, offset: 50)
ChatManager.activeInstance?.contact.getBlockedList(req)
```

### Add Contact
For adding contacts you need to call ``Chat/ContactProtocol/add(_:)`` like this:

Add by cell phone number:
```swift
let req = AddContactRequest(cellphoneNumber: "+1XXXXXX", firstName: "firstName", lastName: "lastName")
```
Or add by email and user name:
```swift
let req = AddContactRequest(firstName:"firstName",lastName: "lastName", username: "userName")
```

```swift
ChatManager.activeInstance?.contact.add(req)
```

### Add Batch Contacts
For adding multiple contacts at once you'll need to call ``Chat/ContactProtocol/addAll(_:)`` like this:
```swift
let contact1 = AddContactRequest(cellphoneNumber: "+1XXXXXX", firstName: "firstName1", lastName: "lastName1")
let contact2 = AddContactRequest(cellphoneNumber: "+1XXXXXX", firstName: "firstName2", lastName: "lastName2")
let contacts = [contact1, contact2]
ChatManager.activeInstance?.contact.addAll(contacts)
```

### Search For Contacts
For searching for contacts you need to call ``Chat/ContactProtocol/search(_:)`` like this:
```swift
let req = ContactsRequest(query: "John")
ChatManager.activeInstance?.contact.search(req)
```

### Remove a contact
For deleting a contact you need to call ``Chat/ContactProtocol/remove(_:)`` like this:
```swift
let req = RemoveContactsRequest(query: "John")
ChatManager.activeInstance?.contact.remove(req)
```

### Check last seen of the user
To get to know when was the last time a user was online you should use ``Chat/ContactProtocol/notSeen(_:)`` like this:
```swift
let req = NotSeenDurationRequest(userIds:[id1, id2])
ChatManager.activeInstance?.contact.notSeen(req)
```

### Sync Contacts
Sync contact with server is done by using ``Chat/ContactProtocol/sync()`` like this:
```swift
ChatManager.activeInstance?.contact.sync()
```

### Update contacts
For updaing a contact you should use the same method ``Chat/ContactProtocol/add(_:)`` like this, and it will update the contact if it can find a match, otherwise it will add it as a new contact:
```swift
let req = AddContactRequest(firstName: "firstName", lastName: "lastName", username: "userName")
ChatManager.activeInstance?.contact.add(req)
```

### Block a contact
For blocking a contact you need to do it with one of userId, contactId or threadId ``Chat/ContactProtocol/block(_:)`` like this:
```swift
let req = BlockRequest(contactId: contactId)
ChatManager.activeInstance?.contact.block(req)
```

### UNBlock a blocked contact
For unblocking a contact you need to do it with one of userId, contactId or threadId ``Chat/ContactProtocol/unBlock(_:)`` like this:
```swift
let req = UnBlockRequest(contactId: contactId)
ChatManager.activeInstance?.contact.unBlock(req)
```
