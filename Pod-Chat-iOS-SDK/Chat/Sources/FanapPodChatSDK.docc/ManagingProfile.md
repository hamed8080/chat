# Managing Profile
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
