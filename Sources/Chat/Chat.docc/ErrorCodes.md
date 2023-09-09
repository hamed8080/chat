# Error Codes
List of all error codes locally in the chat SDK for server errors.

## Overview

The list of error codes with a description of why this error is raised.


## Local Errors

| Error Code  | Description                          |
| ------------ | ------------------------------------ | 
| `outOfStorage` | The device does not have enough storage so it may lead to unexpected behaviors. |
| `exportError` | Exporting messages has failed due to an error. |
| `networkError` | Network request errors, such as Map/Contact/Core REST API errors. |
| `errorRaedyChat` | The chat SDK can not make itself ready due to an error. |
| `asyncError` | The async SDK can not make itself ready due to an error. |

## Server Errors

| Error Code   | Description                          |
| ------------ | ------------------------------------ | 
| `999` | The most important server error, which usually needs support from the server maintainer! |
| `21` | The client is not authenticated and a new token is needed to retrieve. |
| `40` | The token is not authorized for this source. |
| `100` | The request is not valid and maybe it is not created properly. |
| `104` | The id is not a contact ID. |
| `118` | The user is blocked. |
| `121` | The message size exceeded 4096 bytes. |
| `125` | You have passed the maximum number of pin threads. |
| `208` | The user has been banned by the server for a amount of time. |
| `127` | The conversation has already pinned. |
| `129` | The unique name is needed for a public conversation. |
| `130` | The public conversation name exists, and you can not use this conversation name. |
| `131` | The participant has already joined the conversation. |
| `132` | To report a user you should provide a reason attached to the request. |
| `134` | The metadat is required for the message. |
| `138` | Invalid ID type for the Invitee. |
| `140` | The bot name is not valid. |
| `141` | The command is not owned by the bot. |
| `142` | The command is required for this bot. |
| `143` | The format of the command is not valid. |
| `146` | The bot has been already started. |
| `147` | The bot has been already stopped. |
| `201` | The conversation has been already closed. |
| `206` | Delete for all is not available. |
| `208` | Temporary banned. |
| `222` | Too many tag to create. You have passed the maximum number of tags. |
| `223` | Too many tag participnt to add. You have passed the maximum number of tag participant in a tag. |
| `313` | The conversation has already archived. |
| `400` | The time for adding a reaction is over. |

