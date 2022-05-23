//
//  ChatDelegate.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 11/1/21.
//

import Foundation
import FanapPodAsyncSDK

public protocol ChatDelegate:class{
        
    func chatState(state:ChatState, currentUser:User?, error:ChatError?)    
    func chatError(error:ChatError)
    func chatEvent(event:ChatEventType)
}

public enum ChatEventType{
    case Bot(BotEventModel)
    case Contact(ContactEventModel)
    case File(FileEventModel)
    case System(SystemEventModel)
    case Message(MessageEventModel)
    case Thread(ThreadEventModel)
    case User(UserEventModel)
    case Assistant(AssistantEventModel)
    case Tag(TagEventModel)
    case Call(CallEventModel)
}
