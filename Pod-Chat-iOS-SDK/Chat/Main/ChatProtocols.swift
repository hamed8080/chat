//
//  ChatProtocols.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import FanapPodAsyncSDK
import SwiftyJSON


public typealias callbackTypeAlias = (Any) -> ()
public typealias callbackTypeAliasString = (String) -> ()
public typealias callbackTypeAliasFloat = (Float) -> ()


protocol CallbackProtocol: class {
    func onResultCallback(uID:      String,
                          response: CreateReturnData,
                          success:  @escaping callbackTypeAlias,
                          failure:  @escaping callbackTypeAlias)
}

protocol CallbackProtocolWith3Calls: class {
    func onSent(uID: String,    response: CreateReturnData, success: @escaping callbackTypeAlias)
    func onDeliver(uID: String, response: CreateReturnData, success: @escaping callbackTypeAlias)
    func onSeen(uID: String,    response: CreateReturnData, success: @escaping callbackTypeAlias)
}



