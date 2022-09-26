//
//  ChatDelegate.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 11/1/21.
//

import Foundation
import FanapPodAsyncSDK

public protocol ChatDelegate: AnyObject {
        
    func chatState(state:ChatState, currentUser:User?, error:ChatError?)    
    func chatError(error:ChatError)
    func chatEvent(event:ChatEventType)
}

public enum ChatEventType{
    case Bot(BotEventTypes)
    case Contact(ContactEventTypes)
    case File(FileEventType)
    case System(SystemEventTypes)
    case Message(MessageEventTypes)
    case Thread(ThreadEventTypes)
    case User(UserEventTypes)
    case Assistant(AssistantEventModel)
    case Tag(TagEventModel)
}
