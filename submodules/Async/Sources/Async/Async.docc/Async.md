# ``Async``

@Metadata {
   @PageImage(purpose: icon, source: "icon.png", alt: "App icon.")
   @Available(iOS, introduced: "10.0")
   @Available(macOS, introduced: "12")    
}

With Async SDK you could connect to the async server without managing the socket state.


## Overview
Async SDK provides the ability to connect easily to the async server and manage the connection and reconnect whenever reconnecting is needed.

It contains utilities for facilitating the process and a ``AsyncDelegate`` that notifies events that occur in the socket.

With ``AsyncConfig`` you could tell how the async object behaves for more information please visit the initializer.

For debugging the async class you should pass true in the initializer of the ``AsyncConfig``.

After handshaking with the async server you could send or receive messages.
![How socket works behind the scene.](socket.png)

## Topics

### Essentials

- <doc:GettingStarted>
- ``Async/Async``

### Essentials

- ``AsyncDelegate``
- ``AsyncConfig``
- ``AsyncMessageTypes``
- ``AsyncSocketState``
- ``AsyncMessage``
- ``AsyncError``
