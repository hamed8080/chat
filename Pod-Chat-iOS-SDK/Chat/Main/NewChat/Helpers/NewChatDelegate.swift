//
//  NewChatDelegate.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 11/1/21.
//

import Foundation
import FanapPodAsyncSDK

public protocol NewChatDelegate:ChatDelegates{
        
    func chatState(state:ChatState, currentUser:User?, error:ChatError?)    
    func chatError(error:ChatError)
    
    func botEvents(model: BotEventModel)
    func contactEvents(model: ContactEventModel)
    func fileUploadEvents(model: FileUploadEventModel)
    func messageEvents(model: MessageEventModel)
    func systemEvents(model: SystemEventModel)
    func threadEvents(model: ThreadEventModel)
    func userEvents(model: UserEventModel)
}
