# ``FanapPodChatSDK``
With Fanap Chat SDK you could connect to the chat server without managing the socket state and send or receive messages.

## Overview
Chat SDK provides the ability to connect easily to the chat server and manage the connection and reconnect whenever reconnecting is needed. 
Behind the scene it uses Async SDK to connect to async socket and after socket get's ``ChatState/ASYNC_READY`` the chat SDK start to get user information of the current have set token, after it received the user it tell you that chat sdk is ``ChatState/CHAT_READY`` unless is stay in one of ``ChatState/CONNECTING`` or ``ChatState/CLOSED``.  

Please check out the figure below to find out how the Chat SDK works behind the scene.
![How chat sdk works behind the scene.](chat-flow.png)

## Topics

### Essentials

- <doc:GettingStarted>
- ``Chat``

### Essentials

- ``ChatDelegate``
- ``CacheFactory``
- ``Conversation``
- ``Message``
