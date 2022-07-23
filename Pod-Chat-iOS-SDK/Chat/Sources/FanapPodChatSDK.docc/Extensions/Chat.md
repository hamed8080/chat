# ``FanapPodChatSDK/Chat``

The chat server manages the async connection and the rest of the job for you.


## Overview

The Chat class is the main class in the whole chat SDK, so you should take into consideration that this class is all that you need to connect and get your answer and it will tell you to result or maybe events that occur on the server with ``ChatDelegate``. 

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

Reverse a latitude or longitude to a human readable address ``Chat/mapReverse(_:completion:uniqueIdsResult:)`` like this:
```swift
Chat.sharedInstance.mapReverse(.init(lat: 37.33900249783756 , lng: -122.00944807880965)) { mapReverse, uniqueId, error in
    if error == nil{
        // Write your code
    }
}
```
