//
//  ContactManagementMethods.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 3/21/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import FanapPodAsyncSDK
import SwiftyJSON
import Alamofire
import Contacts

// MARK: - Public Methods -
// MARK: - Contact Management

extension Chat {
    
    // MARK: - Get/Search Contacts
    
    // ToDo: filtering by "name" works well on the Cache but not by the Server!!!
    
    /// GetContacts:
    /// it returns list of contacts
    ///
    /// By calling this function, a request of type 13 (GET_CONTACTS) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "GetContactsRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 3 callbacks as responses.
    ///
    /// - parameter inputModel:     (input) you have to send your parameters insid this model. (GetContactsRequestModel)
    /// - parameter uniqueId:       (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion:     (response) it will returns the response that comes from server to this request. (Any as! GetContactsModel)
    /// - parameter cacheResponse:  (response) there is another response that comes from CacheDB to the user, if user has set 'enableCache' vaiable to be true. (GetContactsModel)
    public func getContacts(inputModel getContactsInput:   GetContactsRequestModel,
                            uniqueId:           @escaping ((String) -> ()),
                            completion:         @escaping callbackTypeAlias,
                            cacheResponse:      @escaping (GetContactsModel) -> ()) {
        /*
         *  -> set the "completion" to the "getContactsCallbackToUser" variable
         *      (when the expected answer comes from server, getContactsCallbackToUser will call, and the "complition" of this func will execute)
         *  -> get getContactsInput and create the content JSON of it:
         *      + content:
         *          - size:     Int
         *          - offset:   Int
         *          - name:     String?
         *  -> convert the JSON content to String
         *  -> create "SendChatMessageVO" and put the String content inside its content
         *  -> create "SendAsyncMessageVO" and put "SendChatMessageVO" inside its content
         *  -> send the "SendAsyncMessageVO" to Async
         *  -> configure that when answer comes from server, "GetContactsCallback()" is the responsable func to do the rest
         *  -> send a request to Cache and return the Cahce response on the "cacheResponse" callback
         *
         */
        
        log.verbose("Try to request to get Contacts with this parameters: \n \(getContactsInput)", context: "Chat")
        
        getContactsCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.GET_CONTACTS.rawValue,
                                            content:            "\(getContactsInput.convertContentToJSON())",
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           getContactsInput.typeCode ?? generalTypeCode,
                                            uniqueId:           getContactsInput.typeCode ?? generateUUID(),
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callback:           GetContactsCallback(parameters: chatMessage),
                                callbacks:          nil,
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil) { (getContactUniqueId) in
            uniqueId(getContactUniqueId)
        }
        
        // if cache is enabled by user, it will return cache result to the user
        if enableCache {
            if let cacheContacts = Chat.cacheDB.retrieveContacts(ascending:         true,
                                                                 cellphoneNumber:   nil,
                                                                 count:             getContactsInput.count ?? 50,
                                                                 email:             nil,
                                                                 firstName:         nil,
                                                                 id:                nil,
                                                                 lastName:          nil,
                                                                 offset:            getContactsInput.offset ?? 0,
                                                                 search:            getContactsInput.query,
                                                                 timeStamp:         cacheTimeStamp,
                                                                 uniqueId:          nil) {
                cacheResponse(cacheContacts)
            }
        }
        
    }
    
    
    /// SearchContact:
    /// search contact and returns a list of contact.
    ///
    /// By calling this function, HTTP request of type (SEARCH_CONTACTS) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "SearchContactsRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 3 callbacks as responses.
    ///
    /// - parameter inputModel:     (input) you have to send your parameters insid this model. (SearchContactsRequestModel)
    /// - parameter uniqueId:       (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion:     (response) it will returns the response that comes from server to this request. (Any as! GetContactsModel)
    /// - parameter cacheResponse:  (response) there is another response that comes from CacheDB to the user, if user has set 'enableCache' vaiable to be true. (GetContactsModel)
    public func searchContacts(inputModel searchContactsInput: SearchContactsRequestModel,
                               uniqueId:            @escaping ((String) -> ()),
                               completion:          @escaping callbackTypeAlias,
                               cacheResponse:       @escaping (GetContactsModel) -> ()) {
        /**
         *  -> if Cache was enabled, get the data from Cache and send it to client as "cacheResponse" callback
         *  -> send the HTTP request to server to get the response from it
         *      -> send the server respons to Cache and update it's values
         *      -> send the server answer to client by using "completion" callback
         *
         */
        log.verbose("Try to request to search contact with this parameters: \n \(searchContactsInput)", context: "Chat")
        
        let requestUniqueId = searchContactsInput.uniqueId ?? generateUUID()
        uniqueId(requestUniqueId)
        
        if enableCache {
            if let cacheContacts = Chat.cacheDB.retrieveContacts(ascending:         true,
                                                                 cellphoneNumber:   searchContactsInput.cellphoneNumber,
                                                                 count:             searchContactsInput.size ?? 50,
                                                                 email:             searchContactsInput.email,
                                                                 firstName:         searchContactsInput.firstName,
                                                                 id:                nil,
                                                                 lastName:          searchContactsInput.lastName,
                                                                 offset:            searchContactsInput.offset ?? 0,
                                                                 search:            nil,
                                                                 timeStamp:         cacheTimeStamp,
                                                                 uniqueId:          nil) {
                cacheResponse(cacheContacts)
            }
        }
        
        sendSearchContactRequest(withInputModel: searchContactsInput)
        { (contactModel) in
            self.addContactOnCache(withInputModel: contactModel as! ContactModel)
            let contactEventModel = ContactEventModel(type: ContactEventTypes.CONTACTS_SEARCH_RESULT_CHANGE, contacts: (contactModel as! ContactModel).contacts)
            self.delegate?.contactEvents(model: contactEventModel)
            completion(contactModel)
        }
        
    }
    
    private func sendSearchContactRequest(withInputModel searchContactsInput:  SearchContactsRequestModel,
                                          completion:           @escaping callbackTypeAlias) {
        /**
         *  -> create parameters to send HTTP request:
         *
         *  + method:   POST
         *  + headers:
         *      - _token_:          String
         *      - _token_issuer_:   "1"
         *  + params:  (get searchContactsInput and create the parameters from it)
         *      - size:                        Int
         *      - offset:                      Int
         *      - firstName:               String?
         *      - lastName:               String?
         *      - cellphoneNumber:  String?
         *      - email:                      String?
         *      - uniqueId:                 String?
         *
         */
        
        let url = "\(SERVICE_ADDRESSES.PLATFORM_ADDRESS)\(SERVICES_PATH.SEARCH_CONTACTS.rawValue)"
        let method: HTTPMethod = HTTPMethod.post
        let headers: HTTPHeaders = ["_token_": token, "_token_issuer_": "1"]
        var params: Parameters = [:]
        params["size"] = JSON(searchContactsInput.size ?? 50)
        params["offset"] = JSON(searchContactsInput.offset ?? 0)
        if let firstName = searchContactsInput.firstName {
            params["firstName"] = JSON(firstName)
        }
        if let lastName = searchContactsInput.lastName {
            params["lastName"] = JSON(lastName)
        }
        if let cellphoneNumber = searchContactsInput.cellphoneNumber {
            params["cellphoneNumber"] = JSON(cellphoneNumber)
        }
        if let email = searchContactsInput.email {
            params["email"] = JSON(email)
        }
        if let typeCode_ = searchContactsInput.typeCode {
            params["typeCode"] = JSON(typeCode_)
        }
        
        Networking.sharedInstance.requesttWithJSONresponse(from:            url,
                                                           withMethod:      method,
                                                           withHeaders:     headers,
                                                           withParameters:  params)
        { (response) in
            let contactModel = ContactModel(messageContent: response as! JSON)
            completion(contactModel)
        }
        
    }
    
    
    
    
    // MARK: - Add/Update/Remove Contact
    
    /// AddContact:
    /// it will add a contact
    ///
    /// By calling this function, HTTP request of type (ADD_CONTACTS) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "AddContactRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 3 callbacks as responses.
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (AddContactRequestModel)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! ContactModel)
    public func addContact(inputModel addContactsInput:    AddContactRequestModel,
                           uniqueId:            @escaping (String) -> (),
                           completion:          @escaping callbackTypeAlias) {
        /**
         *  -> send the HTTP request to server to get the response from it
         *      -> send the server respons to Cache and update it's values
         *      -> send the server answer to client by using "completion" callback
         *
         */
        log.verbose("Try to request to add contact with this parameters: \n \(addContactsInput)", context: "Chat")
        
        let messageUniqueId: String = addContactsInput.uniqueId ?? generateUUID()
        uniqueId(messageUniqueId)
        
        sendAddContactRequest(withInputModel: addContactsInput,
                              messageUniqueId:  messageUniqueId)
        { (addContactModel) in
            self.addContactOnCache(withInputModel: addContactModel as! ContactModel)
            completion(addContactModel)
        }
        
    }
    
    
    /// AddContacts:
    /// it will add an array of contacts in one request
    ///
    /// By calling this function, HTTP request of type (ADD_CONTACTS) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "AddContactsRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 3 callbacks as responses.
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (AddContactsRequestModel)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! ContactModel)
    public func addContacts(inputModel addContactsInput:    AddContactsRequestModel,
                            uniqueId:            @escaping (String) -> (),
                            completion:          @escaping callbackTypeAlias) {
        /**
         *  -> send the HTTP request to server to get the response from it
         *      -> send the server respons to Cache and update it's values
         *      -> send the server answer to client by using "completion" callback
         *
         */
        log.verbose("Try to request to add contact with this parameters: \n \(addContactsInput)", context: "Chat")
        
        let messageUniqueId: String = addContactsInput.uniqueId ?? generateUUID()
        uniqueId(messageUniqueId)
        
        sendAddContactsRequest(withInputModel:    addContactsInput,
                               messageUniqueId:     messageUniqueId)
        { (addContactModel) in
            self.addContactOnCache(withInputModel: addContactModel as! ContactModel)
            completion(addContactModel)
        }
    }
    
    
    private func sendAddContactRequest(withInputModel addContactsInput:    AddContactRequestModel,
                                       messageUniqueId:     String,
                                       completion:          @escaping callbackTypeAlias) {
        /**
         *
         *  -> create parameters to send HTTP request:
         *
         *  + method:   POST
         *  + headers:
         *      - _token_:          String
         *      - _token_issuer_:   "1"
         *  + params:  (get searchContactsInput and create the parameters from it)
         *      - firstName:        String?
         *      - lastName:         String?
         *      - cellphoneNumber:  String?
         *      - email:            String?
         *      - uniqueId:         String?
         *
         */
        
        let url = "\(SERVICE_ADDRESSES.PLATFORM_ADDRESS)\(SERVICES_PATH.ADD_CONTACTS.rawValue)"
        let method: HTTPMethod      = HTTPMethod.post
        let headers: HTTPHeaders    = ["_token_": token, "_token_issuer_": "1"]
        
        var params: Parameters      = [:]
        params["firstName"]         = JSON(addContactsInput.firstName ?? "")
        params["lastName"]          = JSON(addContactsInput.lastName ?? "")
        params["cellphoneNumber"]   = JSON(addContactsInput.cellphoneNumber ?? "")
        params["email"]             = JSON(addContactsInput.email ?? "")
        params["uniqueId"]          = JSON(messageUniqueId)
        if let typeCode_ = addContactsInput.typeCode {
            params["typeCode"] = JSON(typeCode_)
        }
        
        Networking.sharedInstance.requesttWithJSONresponse(from:            url,
                                                           withMethod:      method,
                                                           withHeaders:     headers,
                                                           withParameters:  params)
        { (jsonResponse) in
            let contactsModel = ContactModel(messageContent: jsonResponse as! JSON)
            completion(contactsModel)
        }
    }
    
    private func sendAddContactsRequest(withInputModel addContactsInput:    AddContactsRequestModel,
                                        messageUniqueId:     String,
                                        completion:          @escaping callbackTypeAlias) {
        /**
         *
         *  -> create parameters to send HTTP request:
         *
         *  + method:   POST
         *  + headers:
         *      - _token_:          String
         *      - _token_issuer_:   "1"
         *  + params:  (get searchContactsInput and create the parameters from it)
         *      - firstName:        [String]
         *      - lastName:         [String]
         *      - cellphoneNumber:  [String]
         *      - email:            [String]
         *      - uniqueId:         String?
         *
         */
        
        let url = "\(SERVICE_ADDRESSES.PLATFORM_ADDRESS)\(SERVICES_PATH.ADD_CONTACTS.rawValue)"
        let method: HTTPMethod      = HTTPMethod.post
        let headers: HTTPHeaders    = ["_token_": token, "_token_issuer_": "1"]
        
        var params: Parameters      = [:]
        params["firstName"]         = JSON(addContactsInput.firstNames)
        params["lastName"]          = JSON(addContactsInput.lastNames)
        params["cellphoneNumber"]   = JSON(addContactsInput.cellphoneNumbers)
        params["email"]             = JSON(addContactsInput.emails)
        params["uniqueId"]          = JSON(messageUniqueId)
        if let typeCode_ = addContactsInput.typeCode {
            params["typeCode"] = JSON(typeCode_)
        }
        
        Networking.sharedInstance.requesttWithJSONresponse(from:            url,
                                                           withMethod:      method,
                                                           withHeaders:     headers,
                                                           withParameters:  params)
        { (jsonResponse) in
            let contactsModel = ContactModel(messageContent: jsonResponse as! JSON)
            completion(contactsModel)
        }
    }
    
    private func addContactOnCache(withInputModel contactModel: ContactModel) {
        if self.enableCache {
            Chat.cacheDB.saveContact(withContactObjects: contactModel.contacts)
        }
    }
    
    /// UpdateContact:
    /// it will update an existing contact
    ///
    /// By calling this function, HTTP request of type (UPDATE_CONTACTS) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "UpdateContactsRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 3 callbacks as responses.
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (UpdateContactsRequestModel)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! ContactModel)
    public func updateContact(inputModel updateContactsInput:  UpdateContactsRequestModel,
                              uniqueId:             @escaping (String) -> (),
                              completion:           @escaping callbackTypeAlias) {
        /**
         *  -> create parameters to send HTTP request:
         *
         *  + method:   POST
         *  + headers:
         *      - _token_:          String
         *      - _token_issuer_:   "1"
         *  + params:  (get searchContactsInput and create the parameters from it)
         *      - id:               Int
         *      - firstName:        String
         *      - lastName:         String
         *      - cellphoneNumber:  String
         *      - email:            String
         *      - uniqueId:         String?
         *
         *  -> send the HTTP request to server to get the response from it
         *      -> send the server respons to Cache and update it's values
         *      -> send the server answer to client by using "completion" callback
         *
         */
        log.verbose("Try to request to update contact with this parameters: \n \(updateContactsInput)", context: "Chat")
        
        
        let messageUniqueId: String = updateContactsInput.uniqueId ?? generateUUID()
        uniqueId(messageUniqueId)
        
        sendUpdateContactRequest(withInputModel: updateContactsInput)
        { (contactModel) in
            self.addContactOnCache(withInputModel: contactModel as! ContactModel)
            completion(contactModel)
        }
        
    }
    
    private func sendUpdateContactRequest(withInputModel updateContactsInput:  UpdateContactsRequestModel,
                                          completion:           @escaping callbackTypeAlias) {
        
        let url = "\(SERVICE_ADDRESSES.PLATFORM_ADDRESS)\(SERVICES_PATH.UPDATE_CONTACTS.rawValue)"
        let method: HTTPMethod = HTTPMethod.post
        let headers: HTTPHeaders = ["_token_": token, "_token_issuer_": "1"]
        
        var params: Parameters = [:]
        params["id"]              = JSON(updateContactsInput.id)
        params["firstName"]       = JSON(updateContactsInput.firstName)
        params["lastName"]        = JSON(updateContactsInput.lastName)
        params["cellphoneNumber"] = JSON(updateContactsInput.cellphoneNumber)
        params["email"]           = JSON(updateContactsInput.email)
        if let typeCode_ = updateContactsInput.typeCode {
            params["typeCode"] = JSON(typeCode_)
        }
        
        Networking.sharedInstance.requesttWithJSONresponse(from:            url,
                                                           withMethod:      method,
                                                           withHeaders:     headers,
                                                           withParameters:  params)
        { (response) in
            let contactModel = ContactModel(messageContent: response as! JSON)
            completion(contactModel)
        }
    }
    
    
    /// RemoveContact:
    /// it will remove a contact
    ///
    /// By calling this function, HTTP request of type (REMOVE_CONTACTS) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "RemoveContactsRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 3 callbacks as responses.
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (RemoveContactsRequestModel)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! RemoveContactModel)
    public func removeContact(inputModel removeContactsInput:  RemoveContactsRequestModel,
                              uniqueId:             @escaping (String) -> (),
                              completion:           @escaping callbackTypeAlias) {
        /**
         *  -> send the HTTP request to server to get the response from it
         *      -> send the server respons to Cache and update it's values
         *      -> send the server answer to client by using "completion" callback
         *
         */
        log.verbose("Try to request to remove contact with this parameters: \n \(removeContactsInput)", context: "Chat")
        
        let requestUniqueId: String = removeContactsInput.uniqueId ?? generateUUID()
        uniqueId(requestUniqueId)
        
        sendRemoveContactRequest(withInputModel: removeContactsInput)
        { (removeContactModel) in
            self.removeContactFromCache(withInputModel: removeContactModel as! RemoveContactModel,
                                        withContactId:  [removeContactsInput.contactId])
            completion(removeContactModel)
        }
        
    }
    
    private func sendRemoveContactRequest(withInputModel removeContactsInput:  RemoveContactsRequestModel,
                                          completion:           @escaping callbackTypeAlias) {
        /**
         *  -> create parameters to send HTTP request:
         *
         *  + method:   POST
         *  + headers:
         *      - _token_:          String
         *      - _token_issuer_:   "1"
         *  + params:  (get removeContactInput and create the parameters from it)
         *      - contactId:        Int
         *      - uniqueId:         String?
         *
         **/
        let url = "\(SERVICE_ADDRESSES.PLATFORM_ADDRESS)\(SERVICES_PATH.REMOVE_CONTACTS.rawValue)"
        let method: HTTPMethod = HTTPMethod.post
        let headers: HTTPHeaders = ["_token_": token, "_token_issuer_": "1"]
        
        var params: Parameters = [:]
        params["id"] = JSON(removeContactsInput.contactId)
        if let typeCode_ = removeContactsInput.typeCode {
            params["typeCode"] = JSON(typeCode_)
        }
        
        Networking.sharedInstance.requesttWithJSONresponse(from:            url,
                                                           withMethod:      method,
                                                           withHeaders:     headers,
                                                           withParameters:  params)
        { (response) in
            let contactModel = RemoveContactModel(messageContent: response as! JSON)
            completion(contactModel)
        }
    }
    
    private func removeContactFromCache(withInputModel removeContact: RemoveContactModel, withContactId: [Int]) {
        if self.enableCache {
            if (removeContact.result) {
                Chat.cacheDB.deleteContact(withContactIds: withContactId)
            }
        }
    }
    
    
    // MARK: - Block/Unblock/GetBlockList Contact
    
    /// BlockContact:
    /// block a contact by its contactId.
    ///
    /// By calling this function, a request of type 7 (BLOCK) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "BlockContactsRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 3 callbacks as responses.
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (BlockContactsRequestModel)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! BlockedContactModel)
    public func blockContact(inputModel blockContactsInput:    BlockContactsRequestModel,
                             uniqueId:              @escaping (String) -> (),
                             completion:            @escaping callbackTypeAlias) {
        /*
         *  -> set the "completion" to the "blockCallbackToUser" variable
         *      (when the expected answer comes from server, blockCallbackToUser will call, and the "complition" of this func will execute)
         *  -> get blockContactsInput and create the content JSON of it:
         *      + content:
         *          - contactId:    Int?
         *          - threadId:     Int?
         *          - userId:       Int?
         *  -> convert the JSON content to String
         *  -> create "SendChatMessageVO" and put the String content inside its content
         *  -> create "SendAsyncMessageVO" and put "SendChatMessageVO" inside its content
         *  -> send the "SendAsyncMessageVO" to Async
         *  -> configure that when answer comes from server, "BlockContactCallbacks()" is the responsable func to do the rest
         *
         */
        log.verbose("Try to request to block user with this parameters: \n \(blockContactsInput)", context: "Chat")
        
        blockCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.BLOCK.rawValue,
                                            content:            "\(blockContactsInput.convertContentToJSON())",
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           blockContactsInput.typeCode ?? generalTypeCode,
                                            uniqueId:           blockContactsInput.uniqueId ?? generateUUID(),
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callback:           BlockContactCallbacks(),
                                callbacks:          nil,
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil) { (blockUniqueId) in
            uniqueId(blockUniqueId)
        }
        
    }
    
    
    /// GetBlockContactsList:
    /// it returns a list of the blocked contacts.
    ///
    /// By calling this function, a request of type 25 (GET_BLOCKED) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "GetBlockedContactListRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 3 callbacks as responses.
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (GetBlockedContactListRequestModel)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! GetBlockedContactListModel)
    public func getBlockedContacts(inputModel getBlockedContactsInput: GetBlockedContactListRequestModel,
                                   uniqueId:                @escaping (String) -> (),
                                   completion:              @escaping callbackTypeAlias) {
        /*
         *  -> set the "completion" to the "getBlockedCallbackToUser" variable
         *      (when the expected answer comes from server, getBlockedCallbackToUser will call, and the "complition" of this func will execute)
         *  -> get getBlockedContactsInput and create the content JSON of it:
         *      + content:
         *          - count:    Int?
         *          - offset:   Int?
         *  -> convert the JSON content to String
         *  -> create "SendChatMessageVO" and put the String content inside its content
         *  -> create "SendAsyncMessageVO" and put "SendChatMessageVO" inside its content
         *  -> send the "SendAsyncMessageVO" to Async
         *  -> configure that when answer comes from server, "GetBlockedContactsCallbacks()" is the responsable func to do the rest
         *
         */
        log.verbose("Try to request to get block users with this parameters: \n \(getBlockedContactsInput)", context: "Chat")
        
        getBlockedCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.GET_BLOCKED.rawValue,
                                            content:            "\(getBlockedContactsInput.convertContentToJSON())",
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           getBlockedContactsInput.typeCode ?? generalTypeCode,
                                            uniqueId:           getBlockedContactsInput.uniqueId ?? generateUUID(),
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callback:           GetBlockedContactsCallbacks(parameters: chatMessage),
                                callbacks:          nil,
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil) { (getBlockedUniqueId) in
            uniqueId(getBlockedUniqueId)
        }
        
    }
    
    
    /// UnblockContact:
    /// unblock a contact from blocked list.
    ///
    /// By calling this function, a request of type 8 (UNBLOCK) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "UnblockContactsRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 3 callbacks as responses.
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (UnblockContactsRequestModel)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! BlockedContactModel)
    public func unblockContact(inputModel unblockContactsInput:    UnblockContactsRequestModel,
                               uniqueId:                @escaping (String) -> (),
                               completion:              @escaping callbackTypeAlias) {
        /*
         *  -> set the "completion" to the "unblockCallbackToUser" variable
         *      (when the expected answer comes from server, unblockCallbackToUser will call, and the "complition" of this func will execute)
         *  -> get unblockContact and create the content JSON of it:
         *      + content:
         *          - contactId:    Int?
         *          - threadId:     Int?
         *          - userId:       Int?
         *  -> convert the JSON content to String
         *  -> create "SendChatMessageVO" and put the String content inside its content
         *  -> create "SendAsyncMessageVO" and put "SendChatMessageVO" inside its content
         *  -> send the "SendAsyncMessageVO" to Async
         *  -> configure that when answer comes from server, "UnblockContactCallbacks()" is the responsable func to do the rest
         *
         */
        log.verbose("Try to request to unblock user with this parameters: \n \(unblockContactsInput)", context: "Chat")
        
        unblockCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.UNBLOCK.rawValue,
                                            content:            "\(unblockContactsInput.convertContentToJSON())",
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          unblockContactsInput.blockId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           unblockContactsInput.typeCode ?? generalTypeCode,
                                            uniqueId:           unblockContactsInput.uniqueId ?? generateUUID(),
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callback:           UnblockContactCallbacks(),
                                callbacks:          nil,
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil) { (blockUniqueId) in
            uniqueId(blockUniqueId)
        }
        
    }
    
    
    // MARK: Sync Contact
    
    
//    public func syncContact2(uniqueId:      @escaping (String) -> (),
//                             completion:    @escaping callbackTypeAlias,
//                             cacheResponse: @escaping ([ContactModel]) -> ()) {
//        log.verbose("Try to request to sync contact", context: "Chat")
//
//        let myUniqueId = generateUUID()
//        uniqueId(myUniqueId)
//
//// use this to send addcontact reqeusst as an Array
////        var firstNameArray = [String]()
////        var lastNameArray = [String]()
////        var cellphoneNumberArray = [String]()
////        var emailArray = [String]()
//
//        var phoneContacts = [AddContactRequestModel]()
//
//        let store = CNContactStore()
//        store.requestAccess(for: .contacts) { (granted, error) in
//            if let _ = error {
//                return
//            }
//            if granted {
//                let keys = [CNContactGivenNameKey,
//                            CNContactFamilyNameKey,
//                            CNContactPhoneNumbersKey,
//                            CNContactEmailAddressesKey]
//                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
//                do {
//                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
//                        let firstName = contact.givenName
//                        let lastName = contact.familyName
//                        let phoneNumber = contact.phoneNumbers.first?.value.stringValue
//                        let emailAddress = contact.emailAddresses.first?.value
//
//                        let contact = AddContactRequestModel(cellphoneNumber:  phoneNumber,
//                                                              email:            emailAddress as String?,
//                                                              firstName:        firstName,
//                                                              lastName:         lastName,
//                                                              typeCode:         nil,
//                                                              uniqueId:         nil)
//                        phoneContacts.append(contact)
//                    })
//                } catch {
//
//                }
//            }
//
//        }
//
//
//        var contactArrayToSendUpdate = [AddContactRequestModel]()
//        func appendContactToArrayToUpdate(withContact contact: AddContactRequestModel) {
//            contactArrayToSendUpdate.append(contact)
//            if enableCache {
//                Chat.cacheDB.savePhoneBookContact(contact: contact)
//            }
//        }
//
//        if let cachePhoneContacts = Chat.cacheDB.retrievePhoneContacts() {
//            for contact in phoneContacts {
//                var findContactOnPhoneBookCache = false
//                for cacheContact in cachePhoneContacts {
//                    // if there is some number that is already exist on the both phone contact and phoneBookCache, check if there is any update, update the contact
//                    if contact.cellphoneNumber == cacheContact.cellphoneNumber {
//                        findContactOnPhoneBookCache = true
//                        if (cacheContact.email != contact.email) || (cacheContact.firstName != contact.firstName) || cacheContact.lastName != contact.lastName {
//                            appendContactToArrayToUpdate(withContact: contact)
//                        }
//                    }
//                }
//
//                if (!findContactOnPhoneBookCache) {
//                    appendContactToArrayToUpdate(withContact: contact)
//                }
//
//            }
//        } else {
//            // if there is no data on phoneBookCache, add all contacts from phone and save them on cache
//            for contact in phoneContacts {
//                appendContactToArrayToUpdate(withContact: contact)
//            }
//        }
//
//
//        for item in contactArrayToSendUpdate {
//            addContact(inputModel: item, uniqueId: { _ in
//            }) { (myResponse) in
//                completion(myResponse)
//            }
//        }
//
//    }
    
    
    
    /// SyncContact:
    /// sync contacts from the client contact with Chat contact.
    ///
    /// By calling this function, HTTP request of type (SEARCH_CONTACTS) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - this method does not have any input parameters, it actualy gets the device contact automatically
    ///
    /// Outputs:
    /// - It has 2 callbacks as responses.
    ///
    /// - parameter uniqueId:       (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion:     (response) it will returns the response that comes from server to this request. (Any as! [ContactModel])
    /// - parameter cacheResponse:  (response) there is another response that comes from CacheDB to the user, if user has set 'enableCache' vaiable to be true. ([ContactModel])
    public func syncContacts(uniqueId:      @escaping (String) -> (),
                             completion:    @escaping callbackTypeAlias,
                             cacheResponse: @escaping ([ContactModel]) -> ()) {
        log.verbose("Try to request to sync contact", context: "Chat")
        
        let myUniqueId = generateUUID()
        
        var firstNameArray = [String]()
        var lastNameArray = [String]()
        var cellphoneNumberArray = [String]()
        var emailArray = [String]()
        
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if let _ = error {
                return
            }
            if granted {
                let keys = [CNContactGivenNameKey,
                            CNContactFamilyNameKey,
                            CNContactPhoneNumbersKey,
                            CNContactEmailAddressesKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                do {
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                        firstNameArray.append(contact.givenName)
                        lastNameArray.append(contact.familyName)
                        cellphoneNumberArray.append(contact.phoneNumbers.first?.value.stringValue ?? "")
                        emailArray.append((contact.emailAddresses.first?.value as String?) ?? "")
                    })
                } catch {
                    
                }
            }
        }
        
        
        var firstNames: [String] = []
        var lastNames:  [String] = []
        var cellPhones: [String] = []
        var emails:     [String] = []
        
        func appendContactToArrayToUpdate(atIndex: Int) {
            firstNames.append(firstNameArray[atIndex])
            lastNames.append(lastNameArray[atIndex])
            cellPhones.append(cellphoneNumberArray[atIndex])
            emails.append(emailArray[atIndex])
        }
        
        if let cachePhoneContacts = Chat.cacheDB.retrievePhoneContacts() {
            for (index, _) in firstNameArray.enumerated() {
                var findContactOnPhoneBookCache = false
                for cacheContact in cachePhoneContacts {
                    // if there is some number that is already exist on the both phone contact and phoneBookCache, check if there is any update, update the contact
                    if cellphoneNumberArray[index] == cacheContact.cellphoneNumber {
                        findContactOnPhoneBookCache = true
                        if (cacheContact.email != emailArray[index]) || (cacheContact.firstName != firstNameArray[index]) || (cacheContact.lastName != lastNameArray[index]) {
                            appendContactToArrayToUpdate(atIndex: index)
                        }
                    }
                }
                
                if (!findContactOnPhoneBookCache) {
                    appendContactToArrayToUpdate(atIndex: index)
                }
                
            }
        } else {
            // if there is no data on phoneBookCache, add all contacts from phone and save them on cache
            for (index, _) in firstNameArray.enumerated() {
                appendContactToArrayToUpdate(atIndex: index)
            }
        }
        
        let addContactsModel = AddContactsRequestModel(cellphoneNumbers: cellPhones,
                                                       emails:          emails,
                                                       firstNames:      firstNames,
                                                       lastNames:       lastNames,
                                                       typeCode:        nil,
                                                       uniqueId:        myUniqueId)
        
        addContacts(inputModel: addContactsModel, uniqueId: { (resUniqueId) in
            uniqueId(resUniqueId)
        }) { (myResponse) in
            completion(myResponse)
        }
        
    }
    
    
    
}

