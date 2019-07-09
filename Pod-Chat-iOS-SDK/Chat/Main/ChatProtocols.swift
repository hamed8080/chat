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
    
    func chatConnect()
    func chatDisconnect()
    func chatReconnect()
    func chatReady(withUserInfo: User)
    func chatState(state: Int)
    
    func chatError(errorCode: Int, errorMessage: String, errorResult: Any?)
    
    func contactEvents(type: ContactEventTypes, result: Any)
    func threadEvents(type: ThreadEventTypes, result: Any)
    func messageEvents(type: MessageEventTypes, result: Any)
    func botEvents(type: BotEventTypes, result: Any)
    func fileUploadEvents(type: FileUploadEventTypes, result: Any)
    func systemEvents(type: SystemEventTypes, result: Any)
    
}





