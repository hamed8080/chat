//
//  ChatProtocols.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

import SwiftyJSON


public typealias callbackTypeAlias = (Any) -> ()
public typealias callbackTypeAliasString = (String) -> ()
public typealias callbackTypeAliasFloat = (Float) -> ()

protocol CallbackProtocol: class {
    func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias)
}

protocol CallbackProtocolWith3Calls: class {
    func onSent(uID: String, response: JSON, success: @escaping callbackTypeAlias)
    func onDeliver(uID: String, response: JSON, success: @escaping callbackTypeAlias)
    func onSeen(uID: String, response: JSON, success: @escaping callbackTypeAlias)
}






public protocol ChatDelegates: class {
    
    func chatConnected()
    func chatDisconnect()
    func chatReconnect()
    func chatState(state: Int)
    func chatReady(withUserInfo: User)
    
    func userEvents(type: UserEventTypes, result: Any)
    func contactEvents(type: ContactEventTypes, result: Any)
    func chatDeliver(messageId: Int, ownerId: Int)
    func messageEvents(type: MessageEventTypes, result: Any)
    func threadEvents(type: ThreadEventTypes, result: Any)
    
//    func botEvents(type: String, result: JSON)
    
    func chatError(errorCode: Int, errorMessage: String, errorResult: Any?)
}





