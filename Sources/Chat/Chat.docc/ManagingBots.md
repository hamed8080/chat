# Managing Bots
For creating, add/remove command, user bots, start/stop.

![How chat bots work behind the scene.](bot-flow.png)

### Create Bot

For creating a bot use method ``Chat/BotProtocol/create(_:)`` like this:
```swift
let req = CreateBotRequest(botName: botName)
ChatManager.activeInstance?.bot.create(req)
```

### Adding Commands

For adding commands to a bot use method ``Chat/BotProtocol/add(_:)`` like this:
```swift
let commandList:[String] = ["/start", "/write", "/publish"]
let req = AddBotCommandRequest(botName: "MyBotName", commandList: commandList)
ChatManager.activeInstance?.bot.add(req)
```

### Removing Commands

For removing commands to a bot use method ``Chat/BotProtocol/remove(_:)`` like this:
```swift
let commandList:[String] = ["/start", "/write", "/publish"]
let req = RemoveBotCommandRequest(botName: "MyBotName", commandList: commandList)
ChatManager.activeInstance?.bot.remove(req)
```

### Add a bot to a thread

>Tip: For adding bot to a thread you must add it like a participant with method ``Chat/ParticipantProtocol/add(_:)`` like this:
```swift
let req = AddParticipantRequest(userName: "MyBotName", threadId: threadId)
ChatManager.activeInstance?.conversation.participant.add(req)
```

### Start a bot

For starting a bot sue the method ``Chat/BotProtocol/start(_:)`` like this:
```swift
legt req = StartStopBotRequest(botName: "MyBotName", threadId: 123456)
ChatManager.activeInstance?.bot.start(req)
```

### Stop a bot

For stopping a bot sue the method ``Chat/BotProtocol/stop(_:)`` like this:
```swift
let req = StartStopBotRequest(botName: "MyBotName", threadId: 123456)
ChatManager.activeInstance?.bot.stop(req)
```
