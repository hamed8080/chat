# Managing Bots
For creating, add/remove command, user bots, start/stop.

![How chat bots work behind the scene.](bot-flow.png)

### Create Bot

For creating a bot use method ``Chat/createBot(_:completion:uniqueIdResult:)`` like this:
```swift
Chat.sharedInstance.createBot(.init(botName: "MyBotName")) { bot, uniqueId, error in
    if let bot = bot{
        // Write your code
    }
}
```

### Adding Commands

For adding commands to a bot use method ``Chat/addBotCommand(_:completion:uniqueIdResult:)`` like this:
```swift
let commandList:[String] = ["/start", "/write", "/publish"]
let req = AddBotCommandRequest(botName: "MyBotName", commandList: commandList)
Chat.sharedInstance.addBotCommand(req) { botInfo, uniqueId, error in
    if let botInfo = botInfo{
        // Write your code
    }
}
```

### Removing Commands

For removing commands to a bot use method ``Chat/removeBotCommand(_:completion:uniqueIdResult:)`` like this:
```swift
let commandList:[String] = ["/start", "/write", "/publish"]
let req = RemoveBotCommandRequest(botName: "MyBotName", commandList: commandList)
Chat.sharedInstance.removeBotCommand(req) { botInfo, uniqueId, error in
    if let botInfo = botInfo{
        // Write your code
    }
}
```

### Add a bot to a thread

>Tip: For adding bot to a thread you must add it like a participant with method ``Chat/addParticipant(_:completion:uniqueIdResult:)`` like this:
```swift
Chat.sharedInstance.addParticipant(.init(userName: "MyBotName", threadId: 123456)) { thread, uniqueId, error in
    if let thread = thread{
        // Write your code
    }
}
```

### Start a bot

For starting a bot sue the method ``Chat/startBot(_:completion:uniqueIdResult:)`` like this:
```swift
Chat.sharedInstance.startBot(.init(botName: "MyBotName", threadId: 123456)) { botName, uniqueId, error in
    if let botName = botName{
        // Write your code
    }
}
```

### Stop a bot

For stopping a bot sue the method ``Chat/stopBot(_:completion:uniqueIdResult:)`` like this:
```swift
Chat.sharedInstance.stopBot(.init(botName: "MyBotName", threadId: 123456)) { botName, uniqueId, error in
    if let botName = botName{
        // Write your code
    }
}
```
