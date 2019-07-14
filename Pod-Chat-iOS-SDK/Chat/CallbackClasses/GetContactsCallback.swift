//
//  GetContactsCallback.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 3/18/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON
import SwiftyBeaver
import FanapPodAsyncSDK

extension Chat {
    
    public func chatDelegateGetContacts(getContact: JSON) {
        var returnData: JSON = [:]
        
        let hasError = getContact["hasError"].boolValue
        let errorMessage = getContact["errorMessage"].stringValue
        let errorCode = getContact["errorCode"].intValue
        
        returnData["hasError"] = JSON(hasError)
        returnData["errorMessage"] = JSON(errorMessage)
        returnData["errorCode"] = JSON(errorCode)
        
        if (!hasError) {
            let result = getContact["result"]
            let count = result["contentCount"].intValue
            let offset = result["nextOffset"].intValue
            
            let messageContent: [JSON] = getContact["result"].arrayValue
            let contentCount = getContact["contentCount"].intValue
            
            // save data comes from server to the Cache
            var contacts = [Contact]()
            for item in messageContent {
                let myContact = Contact(messageContent: item)
                contacts.append(myContact)
            }
            Chat.cacheDB.saveContact(withContactObjects: contacts)
            
            let getContactsModel = GetContactsModel(messageContent: messageContent, contentCount: contentCount, count: count, offset: offset - count, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
            
//            delegate?.contactEvents(type: ContactEventTypes.getContact, result: getContactsModel)
        }
    }
    
    public class GetContactsCallback: CallbackProtocol {
        var sendParams: SendChatMessageVO
        init(parameters: SendChatMessageVO) {
            self.sendParams = parameters
        }
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            log.verbose("GetContactsCallback", context: "Chat")
            
//            Chat.sharedInstance.chatDelegateGetContacts(getContact: sendParams)
            
            var returnData: JSON = [:]
            
            let hasError = response["hasError"].boolValue
            let errorMessage = response["errorMessage"].stringValue
            let errorCode = response["errorCode"].intValue
            
            returnData["hasError"] = JSON(hasError)
            returnData["errorMessage"] = JSON(errorMessage)
            returnData["errorCode"] = JSON(errorCode)
            
            if (!hasError) {
//                let content = sendParams["content"]
                let content = sendParams.content.convertToJSON()
                let count = content["count"].intValue
                let offset = content["offset"].intValue
                
                let messageContent: [JSON] = response["result"].arrayValue
                let contentCount = response["contentCount"].intValue
                
                //                // save data comes from server to the Cache
                //                var contacts = [Contact]()
                //                for item in messageContent {
                //                    let myContact = Contact(messageContent: item)
                //                    contacts.append(myContact)
                //                }
                //                Chat.cacheDB.saveContactObjects(contacts: contacts)
                
                let getContactsModel = GetContactsModel(messageContent: messageContent, contentCount: contentCount, count: count, offset: offset, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
                
                success(getContactsModel)
            }
        }
    }
    
}
