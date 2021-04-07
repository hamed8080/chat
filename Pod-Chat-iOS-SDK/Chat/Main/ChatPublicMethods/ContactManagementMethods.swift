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
    

    // MARK: - Add Contact
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
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (AddContactRequest)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! ContactModel)
	@available(*,deprecated , message:"Removed in XX.XX.XX version. use new version of method")
    public func addContact(inputModel addContactsInput:    AddContactRequest,
                           uniqueId:            @escaping (String) -> (),
                           completion:          @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to add contact with this parameters: \n \(addContactsInput)", context: "Chat")
        uniqueId(addContactsInput.uniqueId)
        
        sendAddContactRequest(withInputModel:   addContactsInput,
                              messageUniqueId:  addContactsInput.uniqueId)
        { (addContactModel) in
            self.addContactOnCache(withInputModel: addContactModel as! ContactModel)
            completion(addContactModel)
        }
        
    }
    
    private func sendAddContactRequest(withInputModel addContactsInput:    AddContactRequest,
                                       messageUniqueId:     String,
                                       completion:          @escaping callbackTypeAlias) {
        
        let url = "\(SERVICE_ADDRESSES.PLATFORM_ADDRESS)\(SERVICES_PATH.ADD_CONTACTS.rawValue)"
        let method: HTTPMethod      = HTTPMethod.post
        let headers: HTTPHeaders    = ["_token_": token, "_token_issuer_": "1"]
        
        var params: Parameters      = [:]
        params["firstName"]         = JSON(addContactsInput.firstName ?? "")
        params["lastName"]          = JSON(addContactsInput.lastName ?? "")
        params["email"]             = JSON(addContactsInput.email ?? "")
        if let username = addContactsInput.username {
            params["username"] = JSON(username)
        }
        if let cellphoneNumber = addContactsInput.cellphoneNumber {
            params["cellphoneNumber"] = JSON(cellphoneNumber)
        }
        if let ownerId = addContactsInput.ownerId {
            params["ownerId"] = JSON(ownerId)
        }
        params["typeCode"]          = JSON(addContactsInput.typeCode ?? generalTypeCode)
        params["uniqueId"]          = JSON(messageUniqueId)
        
        Networking.sharedInstance.requesttWithJSONresponse(from:            url,
                                                           withMethod:      method,
                                                           withHeaders:     headers,
                                                           withParameters:  params)
        { (jsonResponse) in
            let contactsModel = ContactModel(messageContent: jsonResponse as! JSON)
            completion(contactsModel)
        }
    }
    
    
    /// AddContacts:
    /// it will add an array of contacts in one request
    ///
    /// By calling this function, HTTP request of type (ADD_CONTACTS) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "AddContactsRequest" to this function
    ///
    /// Outputs:
    /// - It has 3 callbacks as responses.
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (AddContactsRequest)
    /// - parameter uniqueIds:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! ContactModel)
//	@available(*,deprecated , message:"Removed in XX.XX.XX version. use new version of method")
    public func addContacts(inputModel addContactsInput:    AddContactsRequest,
                            uniqueIds:           @escaping ([String]) -> (),
                            completion:          @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to add contact with this parameters: \n \(addContactsInput)", context: "Chat")
        uniqueIds(addContactsInput.uniqueIds)
        
        sendAddContactsRequest(withInputModel: addContactsInput)
        { (addContactModel) in
            self.addContactOnCache(withInputModel: addContactModel as! ContactModel)
            completion(addContactModel)
        }
    }
    
    @available(*,deprecated , message:"Removed in XX.XX.XX version. use new version of method")
    private func sendAddContactsRequest(withInputModel addContactsInput:    AddContactsRequest,
                                        completion:          @escaping callbackTypeAlias) {
        
        var url = "\(SERVICE_ADDRESSES.PLATFORM_ADDRESS)\(SERVICES_PATH.ADD_CONTACTS.rawValue)"
        let method: HTTPMethod      = HTTPMethod.post
        let headers: HTTPHeaders    = ["_token_": token, "_token_issuer_": "1"]
        
        url += "?"
        let contactCount = addContactsInput.cellphoneNumbers.count
        for (index, _) in addContactsInput.cellphoneNumbers.enumerated() {
            url += "firstName=\(addContactsInput.firstNames[index])"
            url += "&lastName=\(addContactsInput.lastNames[index])"
            url += "&email=\(addContactsInput.emails[index])"
            url += "&uniqueId=\(addContactsInput.uniqueIds[index])"
//            url += "&cellphoneNumber=\(addContactsInput.cellphoneNumbers[index])"
            
            if (addContactsInput.cellphoneNumbers.count > 0) {
                url += "&cellphoneNumber=\(addContactsInput.cellphoneNumbers[index])"
            } else if (addContactsInput.usernames.count > 0) {
                url += "&username=\(addContactsInput.usernames[index])"
            }
            if (index != contactCount - 1) {
                url += "&"
            }
        }
        url += "&typeCode=\(addContactsInput.typeCode ?? generalTypeCode)"
        
        let textAppend = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? url
        Networking.sharedInstance.requesttWithJSONresponse(from:            textAppend,
                                                           withMethod:      method,
                                                           withHeaders:     headers,
                                                           withParameters:  nil)
        { (jsonResponse) in
            let contactsModel = ContactModel(messageContent: jsonResponse as! JSON)
            completion(contactsModel)
        }
    }
    
    @available(*,deprecated , message:"Removed in XX.XX.XX version. use new version of method")
    private func addContactOnCache(withInputModel contactModel: ContactModel) {
        if self.enableCache {
            Chat.cacheDB.saveContact(withContactObjects: contactModel.contacts)
        }
    }
        
    
    
    // MARK: - Get Contacts
    // ToDo: filtering by "name" works well on the Cache but not by the Server!!!
    /// GetContacts:
    /// it returns list of contacts
    ///
    /// By calling this function, a request of type 13 (GET_CONTACTS) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "GetContactsRequest" to this function
    ///
    /// Outputs:
    /// - It has 3 callbacks as responses.
    ///
    /// - parameter inputModel:         (input) you have to send your parameters insid this model. (GetContactsRequest)
    /// - parameter getCacheResponse:   (input) specify if you want to get cache response for this request (Bool?)
    /// - parameter uniqueId:           (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion:         (response) it will returns the response that comes from server to this request. (Any as! GetContactsModel)
    /// - parameter cacheResponse:      (response) there is another response that comes from CacheDB to the user, if user has set 'enableCache' vaiable to be true. (GetContactsModel)
	@available(*,deprecated , message:"Removed in XX.XX.XX version. use new version of method")
    public func getContacts(inputModel getContactsInput:    GetContactsRequest,
                            getCacheResponse:               Bool?,
                            uniqueId:           @escaping ((String) -> ()),
                            completion:         @escaping callbackTypeAlias,
                            cacheResponse:      @escaping (GetContactsModel) -> ()) {
        
        log.verbose("Try to request to get Contacts with this parameters: \n \(getContactsInput)", context: "Chat")
        uniqueId(getContactsInput.uniqueId)
        
        getContactsCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.GET_CONTACTS.intValue(),
                                            content:            "\(getContactsInput.convertContentToJSON())",
                                            messageType:        nil,
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           getContactsInput.typeCode ?? generalTypeCode,
                                            uniqueId:           getContactsInput.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          [(GetContactsCallback(parameters: chatMessage), getContactsInput.uniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
        
        // if cache is enabled by user, it will return cache result to the user
        if (getCacheResponse ?? enableCache) {
            var isAscending = true
            if let ord = getContactsInput.order, (ord == Ordering.descending.rawValue) {
                isAscending = false
            }
            if let cacheContacts = Chat.cacheDB.retrieveContacts(ascending:         isAscending,
                                                                 cellphoneNumber:   nil,
                                                                 count:             getContactsInput.count ?? 50,
                                                                 email:             getContactsInput.email,
//                                                                 firstName:         nil,
                                                                 id:                getContactsInput.contactId,
//                                                                 lastName:          nil,
                                                                 offset:            getContactsInput.offset ?? 0,
                                                                 search:            getContactsInput.query,
                                                                 timeStamp:         cacheTimeStamp,
                                                                 uniqueId:          nil) {
                cacheResponse(cacheContacts)
            }
        }
        
    }
    
    
    // MARK: - Get Contact Not Seen Duration
    /// GetContactNotSeenDuration:
    /// contact not seen duration time
    ///
    /// By calling this function, a request of type 47 (GET_NOT_SEEN_DURATION) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "GetNotSeenDurationRequest" to this function
    ///
    /// Outputs:
    /// - It has 2 callbacks as responses.
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (GetNotSeenDurationRequest)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! NotSeenDurationModel)
	@available(*,deprecated , message:"Removed in XX.XX.XX version. use new version of method")
    public func contactNotSeenDuration(inputModel notSeenDurationInput: GetNotSeenDurationRequest,
                                       uniqueId:        @escaping (String) -> (),
                                       completion:      @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to get  user notSeenDuration with this parameters: \n \(notSeenDurationInput)", context: "Chat")
        uniqueId(notSeenDurationInput.uniqueId)
        
        getContactNotSeenDurationCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.GET_NOT_SEEN_DURATION.intValue(),
                                            content:            "\(notSeenDurationInput.convertContentToJSON())",
                                            messageType:        nil,
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           notSeenDurationInput.typeCode ?? generalTypeCode,
                                            uniqueId:           notSeenDurationInput.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          [(GetContactNotSeenDurationCallback(), notSeenDurationInput.uniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
    }
    
    
    
    // MARK: - Remove Contact
    /// RemoveContact:
    /// it will remove a contact
    ///
    /// By calling this function, HTTP request of type (REMOVE_CONTACTS) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "RemoveContactsRequest" to this function
    ///
    /// Outputs:
    /// - It has 3 callbacks as responses.
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (RemoveContactsRequest)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! RemoveContactModel)
	@available(*,deprecated , message:"Removed in XX.XX.XX version. use new version of method")
    public func removeContact(inputModel removeContactsInput:  RemoveContactsRequest,
                              uniqueId:             @escaping (String) -> (),
                              completion:           @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to remove contact with this parameters: \n \(removeContactsInput)", context: "Chat")
        uniqueId(removeContactsInput.uniqueId)
        
        sendRemoveContactRequest(withInputModel: removeContactsInput)
        { (removeContactModel) in
            self.removeContactFromCache(withInputModel: removeContactModel as! RemoveContactModel,
                                        withContactId:  [removeContactsInput.contactId])
            completion(removeContactModel)
        }
        
    }
    
    @available(*,deprecated , message:"Removed in XX.XX.XX version. use new version of method")
    private func sendRemoveContactRequest(withInputModel removeContactsInput:  RemoveContactsRequest,
                                          completion:           @escaping callbackTypeAlias) {
        
        let url = "\(SERVICE_ADDRESSES.PLATFORM_ADDRESS)\(SERVICES_PATH.REMOVE_CONTACTS.rawValue)"
        let method: HTTPMethod = HTTPMethod.post
        let headers: HTTPHeaders = ["_token_": token, "_token_issuer_": "1"]
        
        var params: Parameters = [:]
        params["id"] = JSON(removeContactsInput.contactId)
        params["typeCode"] = JSON(removeContactsInput.typeCode ?? generalTypeCode)
        
        Networking.sharedInstance.requesttWithJSONresponse(from:            url,
                                                           withMethod:      method,
                                                           withHeaders:     headers,
                                                           withParameters:  params)
        { (response) in
            let contactModel = RemoveContactModel(messageContent: response as! JSON)
            completion(contactModel)
        }
    }
    
    @available(*,deprecated , message:"Removed in XX.XX.XX version. use new version of method")
    private func removeContactFromCache(withInputModel removeContact: RemoveContactModel, withContactId: [Int]) {
        if self.enableCache {
            if (removeContact.result) {
                Chat.cacheDB.deleteContact(withContactIds: withContactId)
            }
        }
    }
    
    
    // MARK: - Search Contacts
    /// SearchContact:
    /// search contact and returns a list of contact.
    ///
    /// By calling this function, HTTP request of type (SEARCH_CONTACTS) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "SearchContactsRequest" to this function
    ///
    /// Outputs:
    /// - It has 3 callbacks as responses.
    ///
    /// - parameter inputModel:         (input) you have to send your parameters insid this model. (SearchContactsRequest)
    /// - parameter getCacheResponse:   (input) specify if you want to get cache response for this request (Bool?)
    /// - parameter uniqueId:           (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion:         (response) it will returns the response that comes from server to this request. (Any as! GetContactsModel)
    /// - parameter cacheResponse:      (response) there is another response that comes from CacheDB to the user, if user has set 'enableCache' vaiable to be true. (GetContactsModel)
	@available(*,deprecated , message:"Removed in XX.XX.XX version. use new version of method")
    public func searchContacts(inputModel searchContactsInput:  SearchContactsRequest,
                               getCacheResponse:                Bool?,
                               uniqueId:            @escaping ((String) -> ()),
                               completion:          @escaping callbackTypeAlias,
                               cacheResponse:       @escaping (GetContactsModel) -> ()) {
        
        log.verbose("Try to request to search contact with this parameters: \n \(searchContactsInput)", context: "Chat")
        
        let getContactInput = GetContactsRequest(contactId:         searchContactsInput.contactId,
                                                 count:             searchContactsInput.count,
                                                 cellphoneNumber:   searchContactsInput.cellphoneNumber,
                                                 email:             searchContactsInput.email,
                                                 offset:            searchContactsInput.offset,
                                                 order:             searchContactsInput.order,
                                                 query:             searchContactsInput.query,
                                                 summery:           searchContactsInput.summery,
                                                 typeCode:          searchContactsInput.typeCode,
                                                 uniqueId:          searchContactsInput.uniqueId)
        self.getContacts(inputModel: getContactInput, getCacheResponse: getCacheResponse, uniqueId: { (searchContactUniqueId) in
            uniqueId(searchContactUniqueId)
        }, completion: { (response) in
            completion(response)
        }) { (cache) in
            cacheResponse(cache)
        }
        
        
//        uniqueId(searchContactsInput.uniqueId)
//        if (getCacheResponse ?? enableCache) {
//            if let cacheContacts = Chat.cacheDB.retrieveContacts(ascending:         true,
//                                                                 cellphoneNumber:   searchContactsInput.cellphoneNumber,
//                                                                 count:             searchContactsInput.size ?? 50,
//                                                                 email:             searchContactsInput.email,
//                                                                 firstName:         searchContactsInput.firstName,
//                                                                 id:                searchContactsInput.id,
//                                                                 lastName:          searchContactsInput.lastName,
//                                                                 offset:            searchContactsInput.offset ?? 0,
//                                                                 search:            searchContactsInput.query,
//                                                                 timeStamp:         cacheTimeStamp,
//                                                                 uniqueId:          nil) {
//                cacheResponse(cacheContacts)
//            }
//        }
//
//        sendSearchContactRequest(withInputModel: searchContactsInput)
//        { (contactModel) in
//            self.addContactOnCache(withInputModel: contactModel as! ContactModel)
//            let contactEventModel = ContactEventModel(type: ContactEventTypes.CONTACTS_SEARCH_RESULT_CHANGE, contacts: (contactModel as! ContactModel).contacts, contactsLastSeenDuration: nil)
//            self.delegate?.contactEvents(model: contactEventModel)
//            completion(contactModel)
//        }
        
    }
    
//    private func sendSearchContactRequest(withInputModel searchContactsInput:  SearchContactsRequest,
//                                          completion:           @escaping callbackTypeAlias) {
//
//        let url = "\(SERVICE_ADDRESSES.PLATFORM_ADDRESS)\(SERVICES_PATH.SEARCH_CONTACTS.rawValue)"
//        let method: HTTPMethod = HTTPMethod.post
//        let headers: HTTPHeaders = ["_token_": token, "_token_issuer_": "1"]
//        var params: Parameters = [:]
//        params["size"] = JSON(searchContactsInput.size ?? 50)
//        params["offset"] = JSON(searchContactsInput.offset ?? 0)
//        params["typeCode"] = JSON(searchContactsInput.typeCode ?? generalTypeCode)
//        if let firstName = searchContactsInput.firstName {
//            params["firstName"] = JSON(firstName)
//        }
//        if let lastName = searchContactsInput.lastName {
//            params["lastName"] = JSON(lastName)
//        }
//        if let cellphoneNumber = searchContactsInput.cellphoneNumber {
//            params["cellphoneNumber"] = JSON(cellphoneNumber)
//        }
//        if let email = searchContactsInput.email {
//            params["email"] = JSON(email)
//        }
//        if let query_ = searchContactsInput.query {
//            params["q"] = JSON(query_)
//        }
//        if let ownerId = searchContactsInput.ownerId {
//            params["ownerId"] = JSON(ownerId)
//        }
//        if let id = searchContactsInput.id {
//            params["id"] = JSON(id)
//        }
//
//        Networking.sharedInstance.requesttWithJSONresponse(from:            url,
//                                                           withMethod:      method,
//                                                           withHeaders:     headers,
//                                                           withParameters:  params)
//        { (response) in
//            let contactModel = ContactModel(messageContent: response as! JSON)
//            completion(contactModel)
//        }
//
//    }
    
    
    
    private func sendUpdateContactRequest(withInputModel updateContactsInput:  UpdateContactsRequest,
                                          andUniqueId:          String,
                                          completion:           @escaping callbackTypeAlias) {
        
        let url = "\(SERVICE_ADDRESSES.PLATFORM_ADDRESS)\(SERVICES_PATH.UPDATE_CONTACTS.rawValue)"
        let method: HTTPMethod = HTTPMethod.post
        let headers: HTTPHeaders = ["_token_": token, "_token_issuer_": "1"]
        
        var params: Parameters = [:]
        params["id"]                = JSON(updateContactsInput.id)
        params["firstName"]         = JSON(updateContactsInput.firstName)
        params["lastName"]          = JSON(updateContactsInput.lastName)
        params["cellphoneNumber"]   = JSON(updateContactsInput.cellphoneNumber)
        params["email"]             = JSON(updateContactsInput.email)
        params["username"]          = JSON(updateContactsInput.username)
        params["typeCode"]          = JSON(updateContactsInput.typeCode ?? generalTypeCode)
        params["uniqueId"]          = JSON(andUniqueId)
        
        Networking.sharedInstance.requesttWithJSONresponse(from:            url,
                                                           withMethod:      method,
                                                           withHeaders:     headers,
                                                           withParameters:  params)
        { (response) in
            let contactModel = ContactModel(messageContent: response as! JSON)
            completion(contactModel)
        }
    }
    
    
    
    // MARK: Sync Contact
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
//	@available(*,deprecated , message:"Removed in XX.XX.XX version. use new version of method")
    public func syncContacts(uniqueIds:     @escaping ([String]) -> (),
                             completion:    @escaping callbackTypeAlias) {
        log.verbose("Try to request to sync contact", context: "Chat")
        
        // save contacts on the Cache
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
        
        
        // retrieve not synced contacts and sync them
        var firstNames:         [String] = []
        var lastNames:          [String] = []
        var cellPhones:         [String] = []
        var emails:             [String] = []
        var contactUniqueIds:   [String] = []
        
        func appendContactToArrayToUpdate(atIndex: Int) {
            firstNames.append(firstNameArray[atIndex])
            lastNames.append(lastNameArray[atIndex])
            cellPhones.append(cellphoneNumberArray[atIndex])
            emails.append(emailArray[atIndex])
            contactUniqueIds.append(generateUUID())
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
        
        if cellPhones.count > 0 {
            let addContactsModel = AddContactsRequestModel(cellphoneNumbers:    cellPhones,
                                                           emails:              emails,
                                                           firstNames:          firstNames,
                                                           lastNames:           lastNames,
                                                           typeCode:            nil,
                                                           uniqueIds:       contactUniqueIds)
                    
            addContacts(inputModel: addContactsModel, uniqueIds: { (resUniqueIds) in
                uniqueIds(resUniqueIds)
            }) { (myResponse) in

                Chat.cacheDB.savePhoneBookContacts(contacts: addContactsModel)
                completion(myResponse)
            }
        } else {
            let contactModel = ContactModel(contentCount: 0, messageContent: [], hasError: false, errorMessage: "", errorCode: 0)
            completion(contactModel)
        }
        
        
    }
    
    
    
    // MARK: - Update Contact
    /// UpdateContact:
    /// it will update an existing contact
    ///
    /// By calling this function, HTTP request of type (UPDATE_CONTACTS) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "UpdateContactsRequest" to this function
    ///
    /// Outputs:
    /// - It has 3 callbacks as responses.
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (UpdateContactsRequest)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! ContactModel)
	@available(*,deprecated , message:"Removed in XX.XX.XX version. use new version of method")
    public func updateContact(inputModel updateContactsInput:  UpdateContactsRequest,
                              uniqueId:             @escaping (String) -> (),
                              completion:           @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to update contact with this parameters: \n \(updateContactsInput)", context: "Chat")
        uniqueId(updateContactsInput.uniqueId)
        
        sendUpdateContactRequest(withInputModel: updateContactsInput, andUniqueId: updateContactsInput.uniqueId)
        { (contactModel) in
            self.addContactOnCache(withInputModel: contactModel as! ContactModel)
            completion(contactModel)
        }
        
    }
    
    
    
}

