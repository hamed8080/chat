# Managing Reactions
Manage reactions over messages.

>Important: Reactions use an in-memory caching mechanism to prevent calling the server repeatedly.

>Important: All responses for reaction methods are based on **events** not **callbacks**.

### Current User Reaction

To get current user reaction over a message there is a method that you should call ``Chat/reaction(_:)`` like this:

```swift
ChatManager.activeInstance?.reaction(.init(messageId: 1268452305, conversationId: 3051881))
```

The result of this call will be emitted on ``reaction`` of an event method of type  ``ReactionEventTypes``.


### Add Reaction

For adding a reaction to a message simply call ``Chat/addReaction(_:)``:

```swift
ChatManager.activeInstance?.addReaction(.init(messageId: 1268452305, conversationId: 3051881, reaction: .like))
```

The result of this call will be emitted on ``add`` of an event method of type  ``ReactionEventTypes``.

### Remove Reaction

For removing a reaction from a message call ``Chat/deleteReaction(_:)``:

```swift
ChatManager.activeInstance?.deleteReaction(.init(reactionId: 6669, conversationId: 3051881))
```

The result of this call will be emitted on ``delete`` of an event method of type  ``ReactionEventTypes``.

### Replace Reaction

For replacing a reaction to a message simply call ``Chat/replaceReaction(_:)``:

```swift
ChatManager.activeInstance?.replaceReaction(.init(messageId: 1268452305, conversationId: 3051881, reactionId: 6669, reaction: .cry))
```

The result of this call will be emitted on ``replace`` of an event method of type  ``ReactionEventTypes``.

### Replace list

For fetching list of reactions of participants call ``Chat/getReactions(_:)``:

```swift
ChatManager.activeInstance?.getReactions(.init(messageId: 1268452305, conversationId: 3051881))
```

The result of this call will be emitted on ``list`` of an event method of type  ``ReactionEventTypes``.

### Reaction Summary

For fetching summary of reactions including count and sticker call ``Chat/reactionCount(_:)``:

```swift
ChatManager.activeInstance?.reactionCount(.init(messageIds: [1268452305], conversationId: 3051881))
```

The result of this call will be emitted on ``count`` of an event method of type  ``ReactionEventTypes``.
