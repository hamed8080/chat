//
//  ChatDelegates.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 1/30/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import Foundation



public protocol ChatDelegates: class {
    
    func chatConnect()
    func chatDisconnect()
    func chatReconnect()
    func chatReady(withUserInfo: User)
    func chatState(state: AsyncStateType)
    func callError(error:CallError)
    
    func chatError(errorCode: Int, errorMessage: String, errorResult: Any?)
    
    func botEvents(model: BotEventModel)
    func contactEvents(model: ContactEventModel)
    func fileUploadEvents(model: FileUploadEventModel)
    func messageEvents(model: MessageEventModel)
    func systemEvents(model: SystemEventModel)
    func threadEvents(model: ThreadEventModel)
    func userEvents(model: UserEventModel)
    
}
