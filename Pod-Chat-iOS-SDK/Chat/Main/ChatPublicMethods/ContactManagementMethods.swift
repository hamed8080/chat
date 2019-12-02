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
    
    /*
     * GetContacts:
     * it returns list of contacts
     *
     * By calling this function, a request of type 13 (GET_CONTACTS) will send throut Chat-SDK,
     * then the response will come back as callbacks to client whose calls this function.
     *
     *  + Access:   - Public
     *  + Inputs:
     *      this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     *      - count:    how many contact do you want to get with this request.      (Int)       -optional-  , if you don't set it, it would have default value of 50
     *      - offset:   offset of the contact number that start to count to show.   (Int)       -optional-  , if you don't set it, it would have default value of 0
     *      - name:     if you want to search on your contact, put it here.         (String)    -optional-  ,
     *      - typeCode:
     *
     *  + Outputs:
     *      It has 3 callbacks as response:
     *      1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     *      2- completion:  it will returns the response that comes from server to this request.    (GetContactsModel)
     *      3- cacheResponse:  there is another response that comes from CacheDB to the user, if user has set 'enableCache' vaiable to be true
     *
     */
    // ToDo: filtering by "name" works well on the Cache but not by the Server!!!
    public func getContacts(getContactsInput:   GetContactsRequestModel,
                            uniqueId:           @escaping (String) -> (),
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
                                            metaData:           nil,
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
    
    
    /*
     SearchContact:
     search contact and returns a list of contact.
     
     By calling this function, HTTP request of type (SEARCH_CONTACTS) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some prameters as inputs, in the format of JSON or Model (depends on the function that you would use) which are:
     - firstName:        firstName of the contacts that match with this parameter.       (String)    -optional-
     - lastName:         lastName of the contacts that match with this parameter.        (String)    -optional-
     - cellphoneNumber:  cellphoneNumber of the contacts that match with this parameter. (String)    -optional-
     - email:            email of the contacts that match with this parameter.           (String)    -optional-
     - uniqueId:         if you want, you can set the unique id of your request here     (String)    -optional-
     - size:             how many contact do you want to give with this request.         (Int)       -optional-  , if you don't set it, it would have default value of 50
     - offset:           offset of the contact number that start to count to show.       (Int)       -optional-  , if you don't set it, it would have default value of 0
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:  it will returns the response that comes from server to this request.    (ContactModel)
     */
    public func searchContacts(searchContactsInput: SearchContactsRequestModel,
                               uniqueId:            @escaping (String) -> (),
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
        
        sendSearchContactRequest(searchContactsInput: searchContactsInput)
        { (contactModel) in
            self.addContactOnCache(withContactModel: contactModel as! ContactModel)
            completion(contactModel)
        }
        
    }
    
    private func sendSearchContactRequest(searchContactsInput:  SearchContactsRequestModel,
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
    
    private func addContactOnCache(withContactModel contactModel: ContactModel) {
        if self.enableCache {
            Chat.cacheDB.saveContact(withContactObjects: contactModel.contacts)
        }
    }
    
    
    // MARK: - Add/Update/Remove Contact
    /*
     AddContact:
     it will add a contact
     
     By calling this function, HTTP request of type (ADD_CONTACTS) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some prameters as inputs, in the format of JSON or Model (depends on the function that you would use) which are:
     - firstName:       first name of the contact.      (String)    , at least one of 'firstName' or 'lastName' is necessery, the other one is optional.
     - lastName:        last name of the contact.       (String)    , at least one of 'firstName' or 'lastName' is necessery, the other one is optional.
     - cellphoneNumber: phone number of the contact.    (String)    , at least one of 'cellphoneNumber' or 'email' is necessery, the other one is optional.
     - email:           email of the contact.           (String)    , at least one of 'cellphoneNumber' or 'email' is necessery, the other one is optional.
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:  it will returns the response that comes from server to this request.    (ContactModel)
     */
    public func addContact(addContactsInput:    AddContactsRequestModel,
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
        
        sendAddContactRequest(addContactsInput: addContactsInput,
                              messageUniqueId:  messageUniqueId)
        { (addContactModel) in
            self.addContactOnCache(withContactModel: addContactModel as! ContactModel)
            completion(addContactModel)
        }
        
    }
    
    private func sendAddContactRequest(addContactsInput:    AddContactsRequestModel,
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
    
    
    /*
     UpdateContact:
     it will update an existing contact
     
     By calling this function, HTTP request of type (UPDATE_CONTACTS) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some prameters as inputs, in the format of JSON or Model (depends on the function that you would use) which are:
     - id:              id of the contact that you want to update its data.  (Int)
     - firstName:       first name of the contact.                           (String)
     - lastName:        last name of the contact.                            (String)
     - cellphoneNumber: phone number of the contact.                         (String)
     - email:           email of the contact.                                (String)
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:  it will returns the response that comes from server to this request.    (ContactModel)
     */
    public func updateContact(updateContactsInput:  UpdateContactsRequestModel,
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
        
        sendUpdateContactRequest(updateContactsInput: updateContactsInput)
        { (contactModel) in
            self.addContactOnCache(withContactModel: contactModel as! ContactModel)
            completion(contactModel)
        }
        
    }
    
    private func sendUpdateContactRequest(updateContactsInput:  UpdateContactsRequestModel,
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
    
    
    /*
     RemoveContact:
     remove a contact
     
     By calling this function, HTTP request of type (REMOVE_CONTACTS) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get one prameter as inputs, in the format of JSON or Model (depends on the function that you would use) which is:
     - id:              id of the contact that you want to remove it.   (Int)
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:  it will returns the response that comes from server to this request.    (RemoveContactModel)
     */
    public func removeContact(removeContactsInput:  RemoveContactsRequestModel,
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
        
        sendRemoveContactRequest(removeContactsInput: removeContactsInput)
        { (removeContactModel) in
            self.removeContactFromCache(removeContact:  removeContactModel as! RemoveContactModel,
                                        withContactId:  [removeContactsInput.contactId])
            completion(removeContactModel)
        }
        
    }
    
    private func sendRemoveContactRequest(removeContactsInput:  RemoveContactsRequestModel,
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
    
    private func removeContactFromCache(removeContact: RemoveContactModel, withContactId: [Int]) {
        if self.enableCache {
            if (removeContact.result) {
                Chat.cacheDB.deleteContact(withContactIds: withContactId)
            }
        }
    }
    
    
    // MARK: - Block/Unblock/GetBlockList Contact
    /*
     BlockContact:
     block a contact by its contactId.
     
     By calling this function, a request of type 7 (BLOCK) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some prameters as inputs, in the format of JSON or Model (depends on the function that you would use) which are:
     - contactId:    id of your contact that you want to remove it.      (Int)
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:  it will returns the response that comes from server to this request.    (BlockedContactModel)
     */
    public func blockContact(blockContactsInput:    BlockContactsRequestModel,
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
                                            metaData:           nil,
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
    
    
    /*
     GetBlockContactsList:
     it returns a list of the blocked contacts.
     
     By calling this function, a request of type 25 (GET_BLOCKED) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some prameters as inputs, in the format of JSON or Model (depends on the function that you would use) which are:
     - count:        how many contact do you want to give with this request.   (Int)
     - offset:       offset of the contact number that start to count to show.   (Int)
     - typeCode:
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:  it will returns the response that comes from server to this request.    (GetBlockedContactListModel)
     */
    public func getBlockedContacts(getBlockedContactsInput: GetBlockedContactListRequestModel,
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
                                            metaData:           nil,
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
    
    
    /*
     UnblockContact:
     unblock a contact from blocked list.
     
     By calling this function, a request of type 8 (UNBLOCK) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some prameters as inputs, in the format of JSON or Model (depends on the function that you would use) which are:
     - blockId:    id of your contact that you want to unblock it (remove this id from blocked list).  (Int)
     - typeCode:
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:  it will returns the response that comes from server to this request.    (BlockedContactModel)
     */
    public func unblockContact(unblockContactsInput:    UnblockContactsRequestModel,
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
                                            metaData:           nil,
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
    /*
     SyncContact:
     sync contacts from the client contact with Chat contact.
     
     By calling this function, HTTP request of type (SEARCH_CONTACTS) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function doesn't give any parameters as input
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:  it will returns the response for each contact creation.                 (ContactModel)
     */
    public func syncContacts(uniqueId:      @escaping (String) -> (),
                             completion:    @escaping callbackTypeAlias,
                             cacheResponse: @escaping ([ContactModel]) -> ()) {
        log.verbose("Try to request to sync contact", context: "Chat")
        
        let myUniqueId = generateUUID()
        uniqueId(myUniqueId)
        
// use this to send addcontact reqeusst as an Array
//        var firstNameArray = [String]()
//        var lastNameArray = [String]()
//        var cellphoneNumberArray = [String]()
//        var emailArray = [String]()
        
        var phoneContacts = [AddContactsRequestModel]()
        
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
                        let firstName = contact.givenName
                        let lastName = contact.familyName
                        let phoneNumber = contact.phoneNumbers.first?.value.stringValue
                        let emailAddress = contact.emailAddresses.first?.value
                        
                        let contact = AddContactsRequestModel(cellphoneNumber:  phoneNumber,
                                                              email:            emailAddress as String?,
                                                              firstName:        firstName,
                                                              lastName:         lastName,
                                                              typeCode:         nil,
                                                              uniqueId:         nil)
                        phoneContacts.append(contact)
                    })
                } catch {
                    
                }
            }
            
        }
        
        
        var contactArrayToSendUpdate = [AddContactsRequestModel]()
        func appendContactToArrayToUpdate(withContact contact: AddContactsRequestModel) {
            contactArrayToSendUpdate.append(contact)
            if enableCache {
                Chat.cacheDB.savePhoneBookContact(contact: contact)
            }
        }
        
        if let cachePhoneContacts = Chat.cacheDB.retrievePhoneContacts() {
            for contact in phoneContacts {
                var findContactOnPhoneBookCache = false
                for cacheContact in cachePhoneContacts {
                    // if there is some number that is already exist on the both phone contact and phoneBookCache, check if there is any update, update the contact
                    if contact.cellphoneNumber == cacheContact.cellphoneNumber {
                        findContactOnPhoneBookCache = true
                        if (cacheContact.email != contact.email) || (cacheContact.firstName != contact.firstName) || cacheContact.lastName != contact.lastName {
                            appendContactToArrayToUpdate(withContact: contact)
                        }
                    }
                }
                
                if (!findContactOnPhoneBookCache) {
                    appendContactToArrayToUpdate(withContact: contact)
                }
                
            }
        } else {
            // if there is no data on phoneBookCache, add all contacts from phone and save them on cache
            for contact in phoneContacts {
                appendContactToArrayToUpdate(withContact: contact)
            }
        }
        
        
        for item in contactArrayToSendUpdate {
            addContact(addContactsInput: item, uniqueId: { _ in
            }) { (myResponse) in
                completion(myResponse)
            }
        }
        
    }
    
    
    
}

