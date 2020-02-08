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
    
    /*
     * GetContact Response comes from server
     *
     *  save data comes from server to the Cache if needed
     *  send Event to client if needed!
     *  call the "onResultCallback"
     *
     *  + Access:   - private
     *  + Inputs:
     *      - message:      ChatMessage
     *  + Outputs:
     *      - it doesn't have direct output,
     *          but on the situation where the response is valid,
     *          it will call the "onResultCallback" callback to getContacts function (by using "getContactsCallbackToUser")
     *
     */
    func responseOfGetContacts(withMessage message: ChatMessage) {
        log.verbose("Message of type 'GET_CONTACTS' recieved", context: "Chat")
        
        let returnData = CreateReturnData(hasError:         false,
                                          errorMessage:     "",
                                          errorCode:        0,
                                          result:           nil,
                                          resultAsArray:    message.content?.convertToJSON().array,
                                          resultAsString:   nil,
                                          contentCount:     message.contentCount,
                                          subjectId:        message.subjectId)
        
//        if enableCache {
//            var contacts = [Contact]()
//            for item in message.content?.convertToJSON() ?? [:] {
//                let myContact = Contact(messageContent: item.1)
//                contacts.append(myContact)
//            }
//            Chat.cacheDB.saveContact(withContactObjects: contacts)
//        }
        
        if Chat.map[message.uniqueId] != nil {
            let callback: CallbackProtocol = Chat.map[message.uniqueId]!
            callback.onResultCallback(uID:      message.uniqueId,
                                      response: returnData,
                                      success:  { (successJSON) in
                self.getContactsCallbackToUser?(successJSON)
            }) { _ in }
            Chat.map.removeValue(forKey: message.uniqueId)
        }
        
    }
    
    
    public class GetContactsCallback: CallbackProtocol {
        var sendParams: SendChatMessageVO
        init(parameters: SendChatMessageVO) {
            self.sendParams = parameters
        }
        
        func onResultCallback(uID:      String,
                              response: CreateReturnData,
                              success:  @escaping callbackTypeAlias,
                              failure:  @escaping callbackTypeAlias) {
            log.verbose("GetContactsCallback", context: "Chat")
            
            if let arrayContent = response.resultAsArray as? [JSON] {
                let content = sendParams.content?.convertToJSON()
                
                if Chat.sharedInstance.enableCache {
                    var contacts = [Contact]()
                    for item in (response.resultAsArray as? [JSON]) ?? [] {
                        let myContact = Contact(messageContent: item)
                        contacts.append(myContact)
                    }
                    
//                    handleServerAndCacheDifferential(sendParams: sendParams, serverResponse: contacts)
                    let contactEventModel = ContactEventModel(type: ContactEventTypes.CONTACTS_LIST_CHANGE, contacts: contacts)
                    Chat.sharedInstance.delegate?.contactEvents(model: contactEventModel)
                    Chat.cacheDB.saveContact(withContactObjects: contacts)
                }
                
                let getContactsModel = GetContactsModel(messageContent: arrayContent,
                                                        contentCount:   response.contentCount,
                                                        count:          content?["size"].intValue ?? 0,
                                                        offset:         content?["offset"].intValue ?? 0,
                                                        hasError:       response.hasError,
                                                        errorMessage:   response.errorMessage,
                                                        errorCode:      response.errorCode)
                success(getContactsModel)
            }
        }
        
        /*
        private func handleServerAndCacheDifferential(sendParams: SendChatMessageVO, serverResponse: [Contact]) {
            
            if let content = sendParams.content?.convertToJSON() {
                let getCntactsInput = GetContactsRequestModel(json: content)
                if let cacheContactResult = Chat.cacheDB.retrieveContacts(ascending:        true,
                                                                          cellphoneNumber:  nil,
                                                                          count:            getCntactsInput.count ?? 50,
                                                                          email:            nil,
                                                                          firstName:        nil,
                                                                          id:               nil,
                                                                          lastName:         nil,
                                                                          offset:           getCntactsInput.offset ?? 0,
                                                                          search:           getCntactsInput.query,
                                                                          timeStamp:        Chat.sharedInstance.cacheTimeStamp,
                                                                          uniqueId:         nil) {
                    // check if there was any contact on the server response that wasn't on the cache, send them as New Contact Event to the client
                    for contact in serverResponse {
                        var foundCntc = false
                        for cacheContact in cacheContactResult.contacts {
                            if (contact.id == cacheContact.id) {
                                foundCntc = true
                                break
                            }
                        }
                        // meands this contact was not on the cache response
                        if !foundCntc {
                            Chat.sharedInstance.delegate?.contactEvents(type: ContactEventTypes.CONTACT_NEW, contacts: [contact])
                        }
                    }
                    
                    // check if there was any contact on the cache response that wasn't on the server response, send them as Delete Contact Event to the client
                    for cacheContact in cacheContactResult.contacts {
                        var foundCntc = false
                        for contact in serverResponse {
                            if (cacheContact.id == contact.id) {
                                foundCntc = true
                                break
                            }
                        }
                        // meands this contact was not on the server response
                        if !foundCntc {
                            Chat.sharedInstance.delegate?.contactEvents(type: ContactEventTypes.CONTACT_DELETE, contacts: [cacheContact])
                        }
                    }
                    
                }
            }
        }
        */
        
    }
    
}
