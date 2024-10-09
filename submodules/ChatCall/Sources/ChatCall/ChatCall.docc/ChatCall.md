# ``Chat``

@Metadata {
   @PageImage(purpose: icon, source: "icon.png", alt: "App icon.")
   @Available(iOS, introduced: "10.0")
   @Available(macOS, introduced: "12")    
}

With Chat SDK you can connect to the chat server without managing the socket state and send or receive messages.

## Overview
Chat SDK provides functionality to connect easily to the chat server, as well as, managing connections, such as reconnecting.

Behind the scene, it uses Async SDK to connect to the async socket server and after the socket get's `ChatState.asyncReady` the chat SDK start to get user information of the current user by its token, afterward, it will receive a user object. Then, it will tell you that Chat SDK is `ChatState.chatReady` unless it stays in either **ChatState.connecting** or **ChatState.closed**.  

Please check out the figure below to find out how the Chat SDK works behind the scene.
![How chat sdk works behind the scene.](chat-flow.png)

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:ManagingThreads>
- <doc:ManagingMessages>
- <doc:ManagingContacts>
- <doc:ManagingFiles>
- <doc:ManagingUsers>
- <doc:ManagingProfile>
- <doc:ManagingTags>
- <doc:ManagingBots>
- <doc:ManagingAssistants>
- <doc:ManagingMaps>

### Important classes
- ``Chat/Chat``
- ``ChatDelegate``
