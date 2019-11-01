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
        
        var content: JSON = [:]
        
        content["size"]     = JSON(getContactsInput.count ?? 50)
        content["offset"]   = JSON(getContactsInput.offset ?? 0)
        
        if let query = getContactsInput.query {
            content["query"] = JSON(query)
        }
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.GET_CONTACTS.rawValue,
                                            content:            "\(content)",
                                            metaData:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           getContactsInput.typeCode ?? generalTypeCode,
                                            uniqueId:           getContactsInput.uniqueId ?? generateUUID(),
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
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'GetContactsRequestModel' to get the parameters, it'll use JSON
    /*
    public func getContacts(params: JSON?, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to get Contacts with this parameters: \n \(params ?? "params is empty!")", context: "Chat")
        
        var myTypeCode: String = generalTypeCode
        var content: JSON = ["count": 50, "offset": 0]
        if let parameters = params {
            if let count = parameters["count"].int {
                if count > 0 {
                    content["count"] = JSON(count)
                    content["size"] = JSON(count)
                }
            }
            
            if let offset = parameters["offset"].int {
                if offset > 0 {
                    content["offset"] = JSON(offset)
                }
            }
            
            if let name = parameters["name"].string {
                content["name"] = JSON(name)
            }
            
            if let typeCode = parameters["typeCode"].string {
                myTypeCode = typeCode
            }
        }
        
        let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.GET_CONTACTS.rawValue,
                                       "typeCode": myTypeCode,
                                       "content": content]
        sendMessageWithCallback(params: sendMessageParams,
                                callback: GetContactsCallback(parameters: sendMessageParams),
                                callbacks: nil,
                                sentCallback: nil,
                                deliverCallback: nil,
                                seenCallback: nil) { (getContactUniqueId) in
            uniqueId(getContactUniqueId)
        }
        getContactsCallbackToUser = completion
    }
    */
    
    
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
    // ToDo: remove or put uniqueId, typeCode
    // ToDo: server response is invalid
    public func searchContacts(searchContactsInput: SearchContactsRequestModel,
                               uniqueId:            @escaping (String) -> (),
                               completion:          @escaping callbackTypeAlias,
                               cacheResponse:       @escaping (GetContactsModel) -> ()) {
        /*
         *  -> create parameters to send HTTP request:
         *
         *  + method:   POST
         *  + headers:
         *      - _token_:          String
         *      - _token_issuer_:   "1"
         *  + params:  (get searchContactsInput and create the parameters from it)
         *      - size:             Int
         *      - offset:           Int
         *      - firstName:        String?
         *      - lastName:         String?
         *      - cellphoneNumber:  String?
         *      - email:            String?
         *      - uniqueId:         String?
         *
         *  -> if Cache was enabled, get the data from Cache and send it to client as "cacheResponse" callback
         *  -> send the HTTP request to server to get the response from it
         *      -> send the server respons to Cache and update it's values
         *      -> send the server answer to client by using "completion" callback
         *
         */
        log.verbose("Try to request to search contact with this parameters: \n \(searchContactsInput)", context: "Chat")
        
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
//        if let uniqueId = searchContactsInput.uniqueId {
//            params["uniqueId"] = JSON(uniqueId)
//        } else {
//            params["uniqueId"] = JSON(uniqueId)
//        }
        let requestUniqueId = searchContactsInput.uniqueId ?? generateUUID()
//        params["uniqueId"] = JSON(requestUniqueId)
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
                                                                 uniqueId:          requestUniqueId) {
                cacheResponse(cacheContacts)
            }
        }
        
        let url = "\(SERVICE_ADDRESSES.PLATFORM_ADDRESS)\(SERVICES_PATH.SEARCH_CONTACTS.rawValue)"
        let method: HTTPMethod = HTTPMethod.post
        let headers: HTTPHeaders = ["_token_": token, "_token_issuer_": "1"]
        
        
        Networking.sharedInstance.requesttWithJSONresponse(from:            url,
                                                           withMethod:      method,
                                                           withHeaders:     headers,
                                                           withParameters:  params) { (response) in
                                                            let contactsResult = ContactModel(messageContent: response as! JSON)
                                                            
                                                            if self.enableCache {
                                                                var contacts = [Contact]()
                                                                for contact in contactsResult.contacts {
                                                                    contacts.append(contact)
                                                                }
                                                                Chat.cacheDB.saveContact(withContactObjects: contacts)
                                                            }
                                                            
                                                            completion(contactsResult)
        }
        
        
//        Alamofire.request(url, method: method, parameters: params, headers: headers).responseJSON { (response) in
//            if response.result.isSuccess {
//                if let jsonValue = response.result.value {
//                    let jsonResponse: JSON = JSON(jsonValue)
//                    let contactsResult = ContactModel(messageContent: jsonResponse)
//
//                    if self.enableCache {
//                        var contacts = [Contact]()
//                        for contact in contactsResult.contacts {
//                            contacts.append(contact)
//                        }
//                        Chat.cacheDB.saveContact(withContactObjects: contacts)
//                    }
//
//                    completion(contactsResult)
//                }
//            } else {
//                if let error = response.error {
//                    let myJson: JSON = ["hasError":     true,
//                                        "errorCode":    6200,
//                                        "errorMessage": "\(CHAT_ERRORS.err6200.rawValue) \(error)",
//                                        "errorEvent":   error.localizedDescription]
//                    completion(myJson)
//                }
//            }
//        }
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'SearchContactsRequestModel' to get the parameters, it'll use JSON
    /*
    public func searchContacts(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to search contact with this parameters: \n \(params)", context: "Chat")
        
        var data: Parameters = [:]
        
        if let firstName = params["firstName"].string {
            data["firstName"] = JSON(firstName)
        }
        
        if let lastName = params["lastName"].string {
            data["lastName"] = JSON(lastName)
        }
        
        if let cellphoneNumber = params["cellphoneNumber"].string {
            data["cellphoneNumber"] = JSON(cellphoneNumber)
        }
        
        if let email = params["email"].string {
            data["email"] = JSON(email)
        }
        
        if let id = params["id"].int {
            data["id"] = JSON(id)
        }
        
        if let q = params["q"].string {
            data["q"] = JSON(q)
        }
        
        if let uniqueId = params["uniqueId"].string {
            data["uniqueId"] = JSON(uniqueId)
        }
        
        if let size = params["size"].int {
            data["size"] = JSON(size)
        } else { data["size"] = JSON(50) }
        
        if let offset = params["offset"].int {
            data["offset"] = JSON(offset)
        } else { data["offset"] = JSON(0) }
        
        if let typeCode = params["typeCode"].string {
            data["typeCode"] = JSON(typeCode)
        } else {
            data["typeCode"] = JSON(generalTypeCode)
        }
        
        
        let url = "\(SERVICE_ADDRESSES.PLATFORM_ADDRESS)\(SERVICES_PATH.SEARCH_CONTACTS.rawValue)"
        let method: HTTPMethod = HTTPMethod.post
        let headers: HTTPHeaders = ["_token_": token, "_token_issuer_": "1"]
        
        httpRequest(from: url, withMethod: method, withHeaders: headers, withParameters: data, dataToSend: nil, requestUniqueId: nil, isImage: nil, isFile: nil, completion: { (response) in
            let jsonRes: JSON = response as! JSON
            let contactsResult = ContactModel(messageContent: jsonRes)
            completion(contactsResult)
        }, progress: nil, idDownloadRequest: false, isMapServiceRequst: false) { _,_ in }
        
    }
    */
    
    
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
        /*
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
         *  -> send the HTTP request to server to get the response from it
         *      -> send the server respons to Cache and update it's values
         *      -> send the server answer to client by using "completion" callback
         *
         */
        log.verbose("Try to request to add contact with this parameters: \n \(addContactsInput)", context: "Chat")
        
        var params: Parameters = [:]
        
        params["firstName"]       = JSON(addContactsInput.firstName ?? "")
        params["lastName"]        = JSON(addContactsInput.lastName ?? "")
        params["cellphoneNumber"] = JSON(addContactsInput.cellphoneNumber ?? "")
        params["email"]           = JSON(addContactsInput.email ?? "")
        
        let messageUniqueId: String = generateUUID()
        params["uniqueId"] = JSON(messageUniqueId)
        uniqueId(messageUniqueId)
        
        let url = "\(SERVICE_ADDRESSES.PLATFORM_ADDRESS)\(SERVICES_PATH.ADD_CONTACTS.rawValue)"
        let method: HTTPMethod = HTTPMethod.post
        let headers: HTTPHeaders = ["_token_": token, "_token_issuer_": "1"]
        
        Networking.sharedInstance.requesttWithJSONresponse(from:            url,
                                                           withMethod:      method,
                                                           withHeaders:     headers,
                                                           withParameters:  params) { (response) in
                                                            let jsonResponse: JSON = JSON(response)
                                                            let messageContent: [JSON] = jsonResponse["result"].arrayValue
                                                            
                                                            if self.enableCache {
                                                                var contactsArr = [Contact]()
                                                                for item in messageContent {
                                                                    contactsArr.append(Contact(messageContent: item))
                                                                }
                                                                Chat.cacheDB.saveContact(withContactObjects: contactsArr)
                                                            }
                                                            let contactsResult = ContactModel(messageContent: jsonResponse)
                                                            completion(contactsResult)
        }
        
        
//        Alamofire.request(url, method: method, parameters: params, headers: headers).responseJSON { (response) in
//            if response.result.isSuccess {
//                if let jsonValue = response.result.value {
//                    let jsonResponse: JSON = JSON(jsonValue)
//                    let messageContent: [JSON] = jsonResponse["result"].arrayValue
//
//                    if self.enableCache {
//                        var contactsArr = [Contact]()
//                        for item in messageContent {
//                            contactsArr.append(Contact(messageContent: item))
//                        }
//                        Chat.cacheDB.saveContact(withContactObjects: contactsArr)
//                    }
//                    let contactsResult = ContactModel(messageContent: jsonResponse)
//                    completion(contactsResult)
//                }
//            } else {
//                if let error = response.error {
//                    let myJson: JSON = ["hasError":     true,
//                                        "errorCode":    6200,
//                                        "errorMessage": "\(CHAT_ERRORS.err6200.rawValue) \(error)",
//                                        "errorEvent":   error.localizedDescription]
//                    completion(myJson)
//                }
//            }
//        }
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'AddContactsRequestModel' to get the parameters, it'll use JSON
    /*
    public func addContact(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to add contact with this parameters: \n \(params)", context: "Chat")
        
        var data: Parameters = [:]
        
        if let firstName = params["firstName"].string {
            data["firstName"] = JSON(firstName)
        } else { data["firstName"] = JSON("") }
        
        if let lastName = params["lastName"].string {
            data["lastName"] = JSON(lastName)
        } else { data["lastName"] = JSON("") }
        
        if let cellphoneNumber = params["cellphoneNumber"].string {
            data["cellphoneNumber"] = JSON(cellphoneNumber)
        } else { data["cellphoneNumber"] = JSON("") }
        
        if let email = params["email"].string {
            data["email"] = JSON(email)
        } else { data["email"] = JSON("") }
        
        let messageUniqueId: String = generateUUID()
        data["uniqueId"] = JSON(messageUniqueId)
        uniqueId(messageUniqueId)
        
        let url = "\(SERVICE_ADDRESSES.PLATFORM_ADDRESS)\(SERVICES_PATH.ADD_CONTACTS.rawValue)"
        let method: HTTPMethod = HTTPMethod.post
        let headers: HTTPHeaders = ["_token_": token, "_token_issuer_": "1"]
        
        httpRequest(from: url, withMethod: method, withHeaders: headers, withParameters: data, dataToSend: nil, requestUniqueId: messageUniqueId, isImage: nil, isFile: nil, completion: { (response) in
            let jsonRes: JSON = response as! JSON
            let contactsResult = ContactModel(messageContent: jsonRes)
            completion(contactsResult)
        }, progress: nil, idDownloadRequest: false, isMapServiceRequst: false) { _,_ in }
        
    }
    */
    
    
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
        /*
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
        
        var params: Parameters = [:]
        
        params["id"]              = JSON(updateContactsInput.id)
        params["firstName"]       = JSON(updateContactsInput.firstName)
        params["lastName"]        = JSON(updateContactsInput.lastName)
        params["cellphoneNumber"] = JSON(updateContactsInput.cellphoneNumber)
        params["email"]           = JSON(updateContactsInput.email)
        
        let messageUniqueId: String = generateUUID()
        params["uniqueId"] = JSON(messageUniqueId)
        
        let url = "\(SERVICE_ADDRESSES.PLATFORM_ADDRESS)\(SERVICES_PATH.UPDATE_CONTACTS.rawValue)"
        let method: HTTPMethod = HTTPMethod.post
        let headers: HTTPHeaders = ["_token_": token, "_token_issuer_": "1"]
        
        Networking.sharedInstance.requesttWithJSONresponse(from:            url,
                                                           withMethod:      method,
                                                           withHeaders:     headers,
                                                           withParameters:  params) { (response) in
                                                            let contactsResult = ContactModel(messageContent: response as! JSON)
                                                            
                                                            if self.enableCache {
                                                                Chat.cacheDB.saveContact(withContactObjects: contactsResult.contacts)
                                                            }
                                                            
                                                            completion(contactsResult)
        }
        
//        Alamofire.request(url, method: method, parameters: params, headers: headers).responseJSON { (response) in
//            if response.result.isSuccess {
//                if let jsonValue = response.result.value {
//                    let jsonResponse: JSON = JSON(jsonValue)
//                    let contactsResult = ContactModel(messageContent: jsonResponse)
//
//                    if self.enableCache {
//                        Chat.cacheDB.saveContact(withContactObjects: contactsResult.contacts)
//                    }
//
//                    completion(contactsResult)
//                }
//            } else {
//                if let error = response.error {
//                    let myJson: JSON = ["hasError":     true,
//                                        "errorCode":    6200,
//                                        "errorMessage": "\(CHAT_ERRORS.err6200.rawValue) \(error)",
//                                        "errorEvent":   error.localizedDescription]
//                    completion(myJson)
//                }
//            }
//        }
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'UpdateContactsRequestModel' to get the parameters, it'll use JSON
    /*
    public func updateContact(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to update contact with this parameters: \n \(params)", context: "Chat")
        
        var data: Parameters = [:]
        
        if let id = params["id"].int {
            data["id"] = JSON(id)
        } else {
            delegate?.chatError(errorCode: 999, errorMessage: "ID is required for Updating Contact!", errorResult: nil)
        }
        
        if let firstName = params["firstName"].string {
            data["firstName"] = JSON(firstName)
        } else {
            delegate?.chatError(errorCode: 999, errorMessage: "firstName is required for Updating Contact!", errorResult: nil)
        }
        
        if let lastName = params["lastName"].string {
            data["lastName"] = JSON(lastName)
        } else {
            delegate?.chatError(errorCode: 999, errorMessage: "lastName is required for Updating Contact!", errorResult: nil)
        }
        
        if let cellphoneNumber = params["cellphoneNumber"].string {
            data["cellphoneNumber"] = JSON(cellphoneNumber)
        } else {
            delegate?.chatError(errorCode: 999, errorMessage: "cellphoneNumber is required for Updating Contact!", errorResult: nil)
        }
        
        if let email = params["email"].string {
            data["email"] = JSON(email)
        } else {
            delegate?.chatError(errorCode: 999, errorMessage: "email is required for Updating Contact!", errorResult: nil)
        }
        
        let uniqueId: String = generateUUID()
        data["uniqueId"] = JSON(uniqueId)
        
        let url = "\(SERVICE_ADDRESSES.PLATFORM_ADDRESS)\(SERVICES_PATH.UPDATE_CONTACTS.rawValue)"
        let method: HTTPMethod = HTTPMethod.post
        let headers: HTTPHeaders = ["_token_": token, "_token_issuer_": "1"]
        
        httpRequest(from: url, withMethod: method, withHeaders: headers, withParameters: data, dataToSend: nil, requestUniqueId: uniqueId, isImage: nil, isFile: nil, completion: { (response) in
            let jsonRes: JSON = response as! JSON
            let contactsResult = ContactModel(messageContent: jsonRes)
            completion(contactsResult)
        }, progress: nil, idDownloadRequest: false, isMapServiceRequst: false) { _,_ in }
        
    }
    */
    
    
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
        /*
         *  -> create parameters to send HTTP request:
         *
         *  + method:   POST
         *  + headers:
         *      - _token_:          String
         *      - _token_issuer_:   "1"
         *  + params:  (get searchContactsInput and create the parameters from it)
         *      - id:               Int
         *      - uniqueId:         String?
         *
         *  -> send the HTTP request to server to get the response from it
         *      -> send the server respons to Cache and update it's values
         *      -> send the server answer to client by using "completion" callback
         *
         */
        log.verbose("Try to request to remove contact with this parameters: \n \(removeContactsInput)", context: "Chat")
        
        var params: Parameters = [:]
        
        params["id"] = JSON(removeContactsInput.id)
        
        let theUniqueId: String = generateUUID()
        params["uniqueId"] = JSON(theUniqueId)
        uniqueId(theUniqueId)
        
        let url = "\(SERVICE_ADDRESSES.PLATFORM_ADDRESS)\(SERVICES_PATH.REMOVE_CONTACTS.rawValue)"
        let method: HTTPMethod = HTTPMethod.post
        let headers: HTTPHeaders = ["_token_": token, "_token_issuer_": "1"]
        
        Networking.sharedInstance.requesttWithJSONresponse(from:            url,
                                                           withMethod:      method,
                                                           withHeaders:     headers,
                                                           withParameters:  params) { (response) in
                                                            let contactsResult = RemoveContactModel(messageContent: response as! JSON)
                                                            
                                                            if self.enableCache {
                                                                if (contactsResult.result) {
                                                                    Chat.cacheDB.deleteContact(withContactIds: [removeContactsInput.id])
                                                                }
                                                            }
                                                            
                                                            completion(contactsResult)
        }
        
//        Alamofire.request(url, method: method, parameters: params, headers: headers).responseJSON { (response) in
//            if response.result.isSuccess {
//                if let jsonValue = response.result.value {
//                    let jsonResponse: JSON = JSON(jsonValue)
//                    let contactsResult = RemoveContactModel(messageContent: jsonResponse)
//
//                    if self.enableCache {
//                        if (contactsResult.result) {
//                            Chat.cacheDB.deleteContact(withContactIds: [removeContactsInput.id])
//                        }
//                    }
//
//                    completion(contactsResult)
//                }
//            } else {
//                if let error = response.error {
//                    let myJson: JSON = ["hasError":     true,
//                                        "errorCode":    6200,
//                                        "errorMessage": "\(CHAT_ERRORS.err6200.rawValue) \(error)",
//                                        "errorEvent":   error.localizedDescription]
//                    completion(myJson)
//                }
//            }
//        }
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'RemoveContactsRequestModel' to get the parameters, it'll use JSON
    /*
    public func removeContact(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to remove contact with this parameters: \n \(params)", context: "Chat")
        
        var data: Parameters = [:]
        
        if let id = params["id"].int {
            data["id"] = JSON(id)
        } else {
            delegate?.chatError(errorCode: 999, errorMessage: "ID is required for Deleting Contact!", errorResult: nil)
        }
        
        let uniqueId: String = generateUUID()
        data["uniqueId"] = JSON(uniqueId)
        
        let url = "\(SERVICE_ADDRESSES.PLATFORM_ADDRESS)\(SERVICES_PATH.REMOVE_CONTACTS.rawValue)"
        let method: HTTPMethod = HTTPMethod.post
        let headers: HTTPHeaders = ["_token_": token, "_token_issuer_": "1"]
        
        httpRequest(from: url, withMethod: method, withHeaders: headers, withParameters: data, dataToSend: nil, requestUniqueId: uniqueId, isImage: nil, isFile: nil, completion: { (response) in
            let jsonRes: JSON = response as! JSON
            let contactsResult = RemoveContactModel(messageContent: jsonRes)
            completion(contactsResult)
        }, progress: nil, idDownloadRequest: false, isMapServiceRequst: false) { _,_ in }
        
    }
    */
    
    
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
        
        var content: JSON = [:]
        if let contactId = blockContactsInput.contactId {
            content["contactId"] = JSON(contactId)
        }
        if let threadId = blockContactsInput.threadId {
            content["threadId"] = JSON(threadId)
        }
        if let userId = blockContactsInput.userId {
            content["userId"] = JSON(userId)
        }
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.BLOCK.rawValue,
                                            content:            "\(content)",
                                            metaData:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           blockContactsInput.typeCode ?? generalTypeCode,
                                            uniqueId:           blockContactsInput.uniqueId ?? generateUUID(),
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
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'BlockContactsRequestModel' to get the parameters, it'll use JSON
    /*
    public func blockContact(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to block user with this parameters: \n \(params)", context: "Chat")
        
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.BLOCK.rawValue,
                                       "typeCode": params["typeCode"].string ?? generalTypeCode]
        
        var content: JSON = [:]
        
        if let contactId = params["contactId"].int {
            content["contactId"] = JSON(contactId)
        }
        
        sendMessageParams["content"] = JSON("\(content)")
        
        sendMessageWithCallback(params:         sendMessageParams,
                                callback:       BlockContactCallbacks(),
                                callbacks:      nil,
                                sentCallback:   nil,
                                deliverCallback: nil,
                                seenCallback:   nil) { (blockUniqueId) in
            uniqueId(blockUniqueId)
        }
        blockCallbackToUser = completion
    }
    */
    
    
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
        
        var content: JSON = [:]
        content["count"]    = JSON(getBlockedContactsInput.count ?? 50)
        content["offset"]   = JSON(getBlockedContactsInput.offset ?? 0)
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.GET_BLOCKED.rawValue,
                                            content:            "\(content)",
                                            metaData:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           getBlockedContactsInput.typeCode ?? generalTypeCode,
                                            uniqueId:           getBlockedContactsInput.uniqueId ?? generateUUID(),
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
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'GetBlockedContactListRequestModel' to get the parameters, it'll use JSON
    /*
    public func getBlockedContacts(params: JSON?, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to get block users with this parameters: \n \(params ?? "there isn't any parameter")", context: "Chat")
        
        var myTypeCode = generalTypeCode
        
        var content: JSON = ["count": 50, "offset": 0]
        if let parameters = params {
            
            if let count = parameters["count"].int {
                if count > 0 {
                    content.appendIfDictionary(key: "count", json: JSON(count))
                }
            }
            
            if let offset = parameters["offset"].int {
                if offset > 0 {
                    content.appendIfDictionary(key: "offset", json: JSON(offset))
                }
            }
            
            if let typeCode = parameters["typeCode"].string {
                myTypeCode = typeCode
            }
            
        }
        
        let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.GET_BLOCKED.rawValue,
                                       "typeCode": myTypeCode,
                                       "content": content]
        
        sendMessageWithCallback(params:         sendMessageParams,
                                callback:       GetBlockedContactsCallbacks(parameters: sendMessageParams),
                                callbacks:      nil,
                                sentCallback:   nil,
                                deliverCallback: nil,
                                seenCallback:   nil) { (getBlockedUniqueId) in
            uniqueId(getBlockedUniqueId)
        }
        getBlockedCallbackToUser = completion
    }
    */
    
    
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
        
        var content: JSON = [:]
        if let contactId = unblockContactsInput.contactId {
            content["contactId"] = JSON(contactId)
        }
        if let threadId = unblockContactsInput.threadId {
            content["threadId"] = JSON(threadId)
        }
        if let userId = unblockContactsInput.userId {
            content["userId"] = JSON(userId)
        }
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.UNBLOCK.rawValue,
                                            content:            "\(content)",
                                            metaData:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          unblockContactsInput.blockId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           unblockContactsInput.typeCode ?? generalTypeCode,
                                            uniqueId:           unblockContactsInput.uniqueId ?? generateUUID(),
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
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'UnblockContactsRequestModel' to get the parameters, it'll use JSON
    /*
    public func unblockContact(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to unblock user with this parameters: \n \(params)", context: "Chat")
        
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.UNBLOCK.rawValue,
                                       "typeCode": params["typeCode"].string ?? generalTypeCode]
        
        if let subjectId = params["blockId"].int {
            sendMessageParams["subjectId"] = JSON(subjectId)
        }
        
        sendMessageWithCallback(params:         sendMessageParams,
                                callback:       UnblockContactCallbacks(),
                                callbacks:      nil,
                                sentCallback:   nil,
                                deliverCallback: nil,
                                seenCallback:   nil) { (blockUniqueId) in
            uniqueId(blockUniqueId)
        }
        unblockCallbackToUser = completion
    }
    */
    
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
                                                              uniqueId:         nil)
                        phoneContacts.append(contact)
                    })
                } catch {
                    
                }
            }
            
        }
        
        
        var contactArrayToSendUpdate = [AddContactsRequestModel]()
        if let cachePhoneContacts = Chat.cacheDB.retrievePhoneContacts() {
            for contact in phoneContacts {
                var findContactOnPhoneBookCache = false
                for cacheContact in cachePhoneContacts {
                    // if there is some number that is already exist on the both phone contact and phoneBookCache, check if there is any update, update the contact
                    if contact.cellphoneNumber == cacheContact.cellphoneNumber {
                        findContactOnPhoneBookCache = true
                        if cacheContact.email != contact.email {
                            contactArrayToSendUpdate.append(contact)
                            if enableCache {
                                Chat.cacheDB.savePhoneBookContact(contact: contact)
                            }
                            
                        } else if cacheContact.firstName != contact.firstName {
                            contactArrayToSendUpdate.append(contact)
                            if enableCache {
                                Chat.cacheDB.savePhoneBookContact(contact: contact)
                            }
                            
                        } else if cacheContact.lastName != contact.lastName {
                            contactArrayToSendUpdate.append(contact)
                            if enableCache {
                                Chat.cacheDB.savePhoneBookContact(contact: contact)
                            }
                            
                        }
                        
                    }
                }
                
                if (!findContactOnPhoneBookCache) {
                    contactArrayToSendUpdate.append(contact)
                    if enableCache {
                        Chat.cacheDB.savePhoneBookContact(contact: contact)
                    }
                    
                }
                
            }
        } else {
            // if there is no data on phoneBookCache, add all contacts from phone and save them on cache
            for contact in phoneContacts {
                contactArrayToSendUpdate.append(contact)
                if enableCache {
                    Chat.cacheDB.savePhoneBookContact(contact: contact)
                }
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

