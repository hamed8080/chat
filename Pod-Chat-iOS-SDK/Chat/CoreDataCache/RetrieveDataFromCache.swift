//
//  RetrieveDataFromCache.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 3/18/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import CoreData


// MARK: - Functions that will retrieve data from CoreData Cache

extension Cache {
    
    // MARK: - retrieve UserInfo:
    /// Retrieve UserInfo:
    /// retrieve UserInfo from cacheDB and return the result to the caller
    ///
    /// fetch CMUser from Cache
    /// if it found any data of UserInfo in the Cache DB., it will return that,
    /// otherwise it will return nil. (means cache has no data(CMUser object) on itself)
    ///
    /// Inputs:
    /// ther is no need to send any params to this method
    ///
    /// Outputs:
    /// It returns "UserInfoModel" model as output
    ///
    /// - parameters:
    ///     none
    ///
    /// - Returns:
    ///     UserInfoModel?
    ///
    public func retrieveUserInfo() -> UserInfoModel? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMUser")
        do {
            if let result = try context.fetch(fetchRequest) as? [CMUser] {
                switch result.first {
                case let (.some(first)):
                    let user = User(cellphoneNumber: first.cellphoneNumber,
                                    coreUserId:     first.coreUserId as? Int,
                                    email:          first.email,
                                    id:             first.id as? Int,
                                    image:          first.image,
                                    lastSeen:       first.lastSeen as? Int,
                                    name:           first.name,
                                    receiveEnable:  first.receiveEnable as? Bool,
                                    sendEnable:     first.sendEnable as? Bool,
                                    username:       first.username,
                                    chatProfileVO:  Profile(bio: first.bio, metadata: first.metadata))
                    let userInfoModel = UserInfoModel(userObject: user, hasError: false, errorMessage: "", errorCode: 0)
                    return userInfoModel
                    
                default: return nil
                }
            } else {
                return nil
            }
        } catch {
            fatalError("Error on fetching list of CMUser")
        }
    }
    
    // MARK: - retrieve CurrentUserRoles:
    /// Retrieve CurrentUserRoles:
    /// retrieve CurrentUserRoles from cacheDB and return the result to the caller
    ///
    /// fetch CMCurrentUserRoles from Cache
    /// if it found any data of UserInfo in the Cache DB., it will return that,
    /// otherwise it will return nil. (means cache has no data(CMCurrentUserRoles object) on itself)
    ///
    /// Inputs:
    /// ther is no need to send any params to this method
    ///
    /// Outputs:
    /// It returns "UserInfoModel" model as output
    ///
    /// - parameters:
    ///     - onThreadId:   id of the thread. (Int)
    ///
    /// - Returns:
    ///     GetCurrentUserRolesModel?
    ///
    public func retrieveCurrentUserRoles(onThreadId threadId: Int) -> GetCurrentUserRolesModel? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMCurrentUserRoles")
        fetchRequest.predicate = NSPredicate(format: "threadId == %i", threadId)
        do {
            if let result = try context.fetch(fetchRequest) as? [CMCurrentUserRoles] {
                switch result.first {
                case let (.some(object)):
                    var userRoles: [Roles] = []
                    if let myRoles = object.roles {
                        for item in myRoles.roles {
                            if let role = Roles(rawValue: item) {
                                userRoles.append(role)
                            }
                        }
                    }
                    let currentUserRolesModel = GetCurrentUserRolesModel(userRoles:     userRoles,
                                                                         hasError:      false,
                                                                         errorMessage:  "",
                                                                         errorCode:     0)
                    return currentUserRolesModel
                    
                default: return nil
                }
            } else {
                return nil
            }
        } catch {
            fatalError("Error on fetching list of CMCurrentUserRoles")
        }
    }
    
    
    
    // MARK: - retrieve Contacts:
    /// Retrieve Contacts:
    /// retrieve Contacts from cacheDB and return the result to the caller
    ///
    /// - first, it will fetch the Objects from CoreData (Cache DB).
    /// - then based on the client request, it will find the objects that the client wants to get,
    /// and then it will return it as 'GetContactsModel' to the client.
    /// - (if it found any object, it will return that, otherwise it will return nil. (means cache has no data(CMContact object) on itself))
    ///
    /// Inputs:
    /// ther is no need to send any params to this method
    ///
    /// Outputs:
    /// It returns "GetContactsModel" model as output
    ///
    /// - parameters:
    ///     - ascending:        on what order do you want to get the response? (Bool)
    ///     - cellphoneNumber:  if you want to search Contact with specific cellphone number, you should fill this parameter (String?)
    ///     - count:            how many Contacts do you spect to return (Int)
    ///     - email:            if you want to search Contact with specific email address, you should fill this parameter (String?)
    ///     - firstName:        if you want to search Contact with specific first name, you should fill this parameter (String?)
    ///     - id:               if you want to search Contact with specific contact id, you should fill this parameter (Int?)
    ///     - lastName:         if you want to search Contact with specific last name, you should fill this parameter (String?)
    ///     - offset:           from what offset do you want to get the Cache response (Int)
    ///     - search:           if you want to search some term on every content of the Contact (like as: cellphoneNumber, email, firstName, lastName), you should fill this parameter (String?)
    ///     - timeStamp:        the only way to delete contact, is to check if there is a long time that some contact is not updated, we will delete it. this it the timeStamp to check (Int)
    ///     - uniqueId:         this f**king parameter is not related to the Object! this related to the request! anyway just pass it as nil! (String?)
    ///
    /// - Returns:
    ///     GetContactsModel?
    ///
    public func retrieveContacts(ascending:         Bool,
                                 cellphoneNumber:   String?,
                                 count:             Int,
                                 email:             String?,
                                 firstName:         String?,
                                 id:                Int?,
                                 lastName:          String?,
                                 offset:            Int,
                                 search:            String?,
                                 timeStamp:         Int,
                                 uniqueId:          String?) -> GetContactsModel? {
        /*
         * first of all, try to delete all the Contacts that has not been updated for a long time (check it from timeStamp)
         * after that, we will fetch on the Cache
         */
        deleteContacts(byTimeStamp: timeStamp)
        
        
        /*
         *  -> if 'id' or 'uniqueId' property have been set:
         *      we only have to predicate of them and answer exact response
         *
         *  -> in the other situation:
         *      -> make this properties AND together: 'firstName', 'lastName', 'cellphoneNumber', 'email'
         *      -> then with the response of the AND, make OR with 'search' property
         *
         *  -> if { 'id' }
         *  -> else { 'uniqueId' }
         *  -> else { ('cellphoneNumber' && 'firstName' && 'lastName' && 'email') || ('search') }
         *
         *  -> then we create the output model and return it.
         *
         */
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMContact")
        
        let theOnlyPredicate: NSPredicate?
        if let theId = id {
            theOnlyPredicate = NSPredicate(format: "id == %i", theId)
            fetchRequest.predicate = theOnlyPredicate
        } else if let theUniqueId = uniqueId {
            theOnlyPredicate = NSPredicate(format: "uniqueId == %@", theUniqueId)
            fetchRequest.predicate = theOnlyPredicate
        } else {
            
            var andPredicateArr = [NSPredicate]()
            if let theCellphoneNumber = cellphoneNumber {
                if (theCellphoneNumber != "") {
                    let theCellphoneNumberPredicate = NSPredicate(format: "cellphoneNumber CONTAINS[cd] %@", theCellphoneNumber)
                    andPredicateArr.append(theCellphoneNumberPredicate)
                }
            }
            if let theFirstName = firstName {
                if (theFirstName != "") {
                    let theFirstNamePredicate = NSPredicate(format: "firstName CONTAINS[cd] %@", theFirstName)
                    andPredicateArr.append(theFirstNamePredicate)
                }
            }
            if let theLastName = lastName {
                if (theLastName != "") {
                    let theLastNamePredicate = NSPredicate(format: "lastName CONTAINS[cd] %@", theLastName)
                    andPredicateArr.append(theLastNamePredicate)
                }
            }
            if let theEmail = email {
                if (theEmail != "") {
                    let theEmailPredicate = NSPredicate(format: "email CONTAINS[cd] %@", theEmail)
                    andPredicateArr.append(theEmailPredicate)
                }
            }
            
            var orPredicatArray = [NSPredicate]()
            
            if (andPredicateArr.count > 0) {
                let andPredicateCompound = NSCompoundPredicate(type: .and, subpredicates: andPredicateArr)
                orPredicatArray.append(andPredicateCompound)
            }
            
            if let searchStatement = search {
                if (searchStatement != "") {
                    let theSearchPredicate = NSPredicate(format: "cellphoneNumber CONTAINS[cd] %@ OR email CONTAINS[cd] %@ OR firstName CONTAINS[cd] %@ OR lastName CONTAINS[cd] %@", searchStatement, searchStatement, searchStatement, searchStatement)
                    orPredicatArray.append(theSearchPredicate)
                }
            }
            
            if (orPredicatArray.count > 0) {
                let predicateCompound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: orPredicatArray)
                fetchRequest.predicate = predicateCompound
            }
        }
        
        let firstNameSort   = NSSortDescriptor(key: "firstName", ascending: ascending)
        let lastNameSort    = NSSortDescriptor(key: "lastName", ascending: ascending)
        fetchRequest.sortDescriptors = [lastNameSort, firstNameSort]
        
        do {
            if let result = try context.fetch(fetchRequest) as? [CMContact] {
                
                var insideCount = 0
                var cmContactObjectArr = [CMContact]()
                
                for (index, item) in result.enumerated() {
                    if (index >= offset) && (insideCount < count) {
                        cmContactObjectArr.append(item)
                        insideCount += 1
                    }
                }
                
                var contactsArr = [Contact]()
                for item in cmContactObjectArr {
                    contactsArr.append(item.convertCMObjectToObject())
                }
                
                let getContactModelResponse = GetContactsModel(contactsObject:  contactsArr,
                                                               contentCount:    result.count,
                                                               count:           count,
                                                               offset:          offset,
                                                               hasError:        false,
                                                               errorMessage:    "",
                                                               errorCode:       0)
                
                return getContactModelResponse
                
            } else {
                return nil
            }
        } catch {
            fatalError("Error on fetching list of CMContact")
        }
    }
    
    
    
    // MARK: - retrieve PhoneContacts:
    /// Retrieve PhoneContacts:
    /// retrieve PhoneContacts from cacheDB and return the result to the caller
    ///
    /// fetch PhoneContact from Cache DB.
    /// if it found any object, it will return that
    /// otherwise it will return nill. (means there is no data(PhoneContact object) inside the Cache)
    ///
    /// Inputs:
    /// - ther is no need to send any params to this method
    ///
    /// Outputs:
    /// - It returns an array of "Contact"  as output
    ///
    /// - parameters:
    ///     none
    ///
    /// - returns:
    ///     [Contact]?
    public func retrievePhoneContacts() -> [Contact]? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PhoneContact")
        do {
            if let result = try context.fetch(fetchRequest) as? [PhoneContact] {
                if (result.count > 0) {
                    
                    var contactsArr = [Contact]()
                    for item in result {
                        let contact = Contact(blocked:          nil,
                                              cellphoneNumber:  item.cellphoneNumber,
                                              email:            item.email,
                                              firstName:        item.firstName,
                                              hasUser:          false,
                                              id:               nil,
                                              image:            nil,
                                              lastName:         item.lastName,
                                              linkedUser:       nil,
                                              notSeenDuration:  nil,
                                              timeStamp:        nil,
//                                              uniqueId:         nil,
                                              userId:           nil)
                        contactsArr.append(contact)
                    }
                    
                    return contactsArr
                }
            }
        } catch {
            
        }
        return nil
    }
    
    
    // TODO: Have to implement search in threads by using 'name' and also 'threadIds' properties!
    // MARK: - retrieve Threads:
    /// Retrieve Threads:
    /// retrieve Threads from cacheDB and return the result to the caller
    ///
    /// - fetch CMConversation from Cahce DB
    /// - if it found any object, it will return that,
    /// - otherwise it will return nil. (means cache has no data(CMConversation) on itself).
    ///
    /// Inputs:
    /// there are some parameters that user has to send some of them
    ///
    /// Outputs:
    /// It returns a Model of "GetThreadsModel"  as output
    ///
    /// - parameters:
    ///     - ascending:  on what order do you want to get the response? (Bool)
    ///     - count:      how many Thread do you spect to return (Int)
    ///     - name:       (String?)
    ///     - offset:     from what offset do you want to get the Cache response (Int)
    ///     - threadIds:  ([Int]?)
    ///     - timeStamp:  the only way to delete Thread, is to check if there is a long time that some contact is not updated, we will delete it. this it the timeStamp to check (Int)
    ///
    /// - returns:
    ///     GetThreadsModel?
    ///
    public func retrieveThreads(ascending:  Bool,
                                count:      Int,
                                name:       String?,
                                offset:     Int,
                                threadIds:  [Int]?) -> GetThreadsModel? {
        
        var getThreadModelResponse: GetThreadsModel?
        
        var (threads, contentCount) = retrieveTheThreads(ascending: ascending, count: count, name: name, offset: offset, threadIds: threadIds)
        
        if (count < 1000) {
            var conversations = [Conversation]()
            let pinnedThreadsArray = retrievePinThreads(ascending: ascending)
            
            
            var extraItems = pinnedThreadsArray?.count ?? 0
            for (index, item) in (threads ?? []).enumerated() {
                for thrd in pinnedThreadsArray ?? [] {
                    if (item.id == thrd.id) {
                        threads?.remove(at: (index - ((pinnedThreadsArray?.count ?? 0) - extraItems)))
                        extraItems -= 1
                    }
                }
            }
            for item in pinnedThreadsArray ?? [] {
                conversations.append(item)
            }
            for item in threads ?? [] {
                conversations.append(item)
            }
            
            if (extraItems > 0) && (pinnedThreadsArray?.count ?? 0 > 0) {
                for _ in (1...(pinnedThreadsArray?.count ?? 1)) {
                    conversations.removeLast()
                }
            }
            
            
            getThreadModelResponse = GetThreadsModel(conversationObjects:   conversations,
                                                     contentCount:          contentCount ?? 0,
                                                     count:                 count,
                                                     offset:                offset,
                                                     hasError:              false,
                                                     errorMessage:          "",
                                                     errorCode:             0)
            
        }
        
        return getThreadModelResponse
    }
    
    public func retrieveNewThreads(count:   Int,
                                   offset:  Int) -> GetThreadsModel? {
        
        var returnModel: GetThreadsModel?
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMConversation")
        fetchRequest.predicate = NSPredicate(format: "unreadCount > %i", 0)
        do {
            if let result = try context.fetch(fetchRequest) as? [CMConversation] {
                var threadObjects = [Conversation]()
                var insideCount = 0
                for (index, item) in result.enumerated() {
                    if (index >= offset) && (insideCount <= count) {
                        threadObjects.append(item.convertCMObjectToObject(showInviter: true, showLastMessageVO: true, showParticipants: false, showPinMessage: true))
                        insideCount += 1
                    }
                }
                
                returnModel = GetThreadsModel(conversationObjects:  threadObjects,
                                              contentCount:         result.count,
                                              count:                threadObjects.count,
                                              offset:               offset,
                                              hasError:             false,
                                              errorMessage:         "",
                                              errorCode:            0)
            }
        } catch {
            fatalError("Error on fetching list of CMConversation that has unreadCounts")
        }
        
        return returnModel
    }
    
    func retrieveTheThreads(ascending:  Bool,
                            count:      Int,
                            name:       String?,
                            offset:     Int,
                            threadIds:  [Int]?) -> (threads: [Conversation]?, contentCount: Int?)/*GetThreadsModel?*/ {
        /*
         *  -> make this propertues OR toghether: 'title', 'descriptions', 'id'(for every id inside 'threadIds input'
         *  -> sort the result by the 'time' as 'ascending input'
         *
         *  -> ('title' || 'descriptions' || 'id'(for every id inside 'threadIds input'))
         *
         *  -> then we create the output model and return it.
         *
         */
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMConversation")
        
        // use this array to make "logical OR" for threads
        var orFetchPredicatArray = [NSPredicate]()
        // put the search statement on the predicate to search throut the Conversations(Threads)
        if let searchStatement = name {
            if (searchStatement != "") {
                let searchTitle = NSPredicate(format: "title CONTAINS[cd] %@", searchStatement)
                let searchDescriptions = NSPredicate(format: "descriptions CONTAINS[cd] %@", searchStatement)
                orFetchPredicatArray.append(searchTitle)
                orFetchPredicatArray.append(searchDescriptions)
            }
        }
        
        // loop through the threadIds Arr that the user seends, and fill the 'fetchPredicatArray' property to predicate
        if let searchThreadId = threadIds {
            for i in searchThreadId {
                let threadIdPredicate = NSPredicate(format: "id == %i", i)
                orFetchPredicatArray.append(threadIdPredicate)
            }
        }
        
        if (orFetchPredicatArray.count == 1) {
            fetchRequest.predicate = orFetchPredicatArray.first!
        } else if (orFetchPredicatArray.count > 1) {
            let predicateCompound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: orFetchPredicatArray)
            fetchRequest.predicate = predicateCompound
        }
        
        // sort the result by the time
        let sortByTime = NSSortDescriptor(key: "time", ascending: ascending)
        fetchRequest.sortDescriptors = [sortByTime]
        
        do {
            if let result = try context.fetch(fetchRequest) as? [CMConversation] {
                var insideCount = 0
                var cmConversationObjectArr = [CMConversation]()
                for (index, item) in result.enumerated() {
                    if (index >= offset) && (insideCount < count) {
                        cmConversationObjectArr.append(item)
                        insideCount += 1
                    }
                }
                
                var conversationArr = [Conversation]()
                for item in cmConversationObjectArr {
                    let conversationObject = item.convertCMObjectToObject(showInviter: true, showLastMessageVO: true, showParticipants: false, showPinMessage: true)
                    conversationArr.append(conversationObject)
                }
                return (conversationArr, result.count)
            } else {
                return (nil, nil)
            }
        } catch {
            fatalError("Error on fetching list of CMConversation")
        }
    }
    
    func retrievePinThreads(ascending:  Bool) -> [Conversation]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMConversation")
        
        let theOnlyPredicate: NSPredicate?
        theOnlyPredicate = NSPredicate(format: "pin == %@", NSNumber(value: true))
        fetchRequest.predicate = theOnlyPredicate
        
        // sort the result by the time
        let sortByTime = NSSortDescriptor(key: "time", ascending: ascending)
        fetchRequest.sortDescriptors = [sortByTime]
        
        do {
            if let result = try context.fetch(fetchRequest) as? [CMConversation] {
                
                var conversationArr = [Conversation]()
                for item in result {
                    let conversationObject = item.convertCMObjectToObject(showInviter: true, showLastMessageVO: true, showParticipants: false, showPinMessage: true)
                    conversationArr.append(conversationObject)
                }
                return conversationArr
                
            } else {
                return nil
            }
        } catch {
            fatalError("Error on fetching list of CMConversation")
        }
    }
    
    
    // MARK: - retrieve ThreadParticipants:
    /// Retrieve ThreadParticipants:
    /// retrieve ThreadParticipants from cacheDB and return the result to the caller
    ///
    /// fetch CMConversation from Cahce DB
    /// if it found any object, it will get its Participants and return them,
    /// otherwise it will return nil. (means cache has no data(CMConversation) on itself).
    ///
    /// Inputs:
    /// - there are some parameters that user has to send some of them
    ///
    /// Outputs:
    /// - It returns a Model of "GetThreadParticipantsModel"  as output
    ///
    /// - parameters:
    ///     - admin:      if you want to only get admins, you have send this parameter as 'true'. (Bool?)
    ///     - ascending:  on what order do you want to get the response? (Bool)
    ///     - count:      how many ThreadParticipants do you spect to return (Int)
    ///     - offset:     from what offset do you want to get the Cache response (Int)
    ///     - threadIds:  ([Int]?)
    ///     - timeStamp:  the only way to delete ThreadParticipants, is to check if there is a long time that some participants is not updated, we will delete it. this it the timeStamp to check (Int)
    ///
    /// - returns:
    ///     GetThreadParticipantsModel?
    ///
    public func retrieveThreadParticipants(admin:       Bool?,
                                           ascending:   Bool,
                                           count:       Int,
                                           offset:      Int,
                                           threadId:    Int,
                                           timeStamp:   Int) -> GetThreadParticipantsModel? {
        /*
         * first of all, try to delete all the Participants that has not been updated for a long time (check it from timeStamp)
         * after that, we will fetch on the Cache
         *
         */
        deleteThreadParticipants(inThread: threadId, byTimeStamp: timeStamp)
        
        var getThreadParticipantModelResponse: GetThreadParticipantsModel?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMParticipant")
        let threadPredicate = NSPredicate(format: "threadId == %i", threadId)
        fetchRequest.predicate = threadPredicate
        
        let nameSort   = NSSortDescriptor(key: "contactName", ascending: ascending)
        let lastNameSort    = NSSortDescriptor(key: "lastName", ascending: ascending)
        let firstNameSort    = NSSortDescriptor(key: "firstName", ascending: ascending)
        fetchRequest.sortDescriptors = [nameSort, lastNameSort, firstNameSort]
        
        do {
            if let result = try context.fetch(fetchRequest) as? [CMParticipant] {
                if (result.count > 0) {
                    var insideCount = 0
                    var cmParticipantObjectArr = [CMParticipant]()
                    
                    for (index, item) in result.enumerated() {
                        
                        if (index >= offset) && (insideCount < count) {
                            cmParticipantObjectArr.append(item)
                            insideCount += 1
                        }
                    }
                    
                    var participantsArr = [Participant]()
                    for item in cmParticipantObjectArr {
                        participantsArr.append(item.convertCMObjectToObject())
                    }
                    getThreadParticipantModelResponse = GetThreadParticipantsModel(participantObjects:  participantsArr,
                                                                                   contentCount:        result.count,
                                                                                   count:               count,
                                                                                   offset:              offset,
                                                                                   hasError:            false,
                                                                                   errorMessage:        "",
                                                                                   errorCode:           0)
                }
            }
        } catch {
            fatalError("Error on fetching list of CMParticipant")
        }
        
        return getThreadParticipantModelResponse
    }
    
    
    
    // ToDo: check SaveThreadParticipant method on the cache and implement the correct implementation of admin roles on that function and remove this one
    func retrieveThreadAdmins(threadId: Int) -> UserRolesModel? {
        
        var userAdmin: UserRolesModel?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMParticipant")
        fetchRequest.predicate = NSPredicate(format: "threadId == %i", threadId)
        do {
            if let result = try context.fetch(fetchRequest) as? [CMParticipant] {
                if (result.count > 0) {
                    
                    var admins = [UserRole]()
                    
                    for participant in result {
                        if let roles = participant.roles {
                            admins.append(UserRole(userId:  participant.id as! Int,
                                                   name:    participant.name!,
                                                   roles:   roles))
                        }
                    }
                    
                    userAdmin = UserRolesModel(threadId:        threadId,
                                               userRolesObject: admins,
                                               hasError:        false,
                                               errorMessage:    "",
                                               errorCode:       0)
                    
                }
            }
        } catch {
            fatalError("Error on fetching list of CMParticipant")
        }
        
        return userAdmin
    }
    
    
    
    // MARK: - retrieve MessageHistory:
    public func retrieveAllUnreadMessageCount() -> Int {
        var countSum = 0
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMConversation")
        do {
            if let result = try context.fetch(fetchRequest) as? [CMConversation] {
                for thread in result {
                    let t = thread.convertCMObjectToObject(showInviter: false, showLastMessageVO: false, showParticipants: false, showPinMessage: false)
                    countSum += t.unreadCount ?? 0
                }
            }
        } catch {
            fatalError("Error on fetching list of CMMessage that are unreaded")
        }
        return countSum
    }
    
    /// Retrieve MessageHistory:
    /// retrieve MessageHistory from cacheDB and return the result to the caller
    ///
    /// - fetch CMMessage from Cahce DB
    /// - if it found any data from Cache DB, it will return that,
    /// - otherwise it will return nil. (means cache has no data(CMMessage) on itself).
    ///
    /// Inputs:
    /// there are some parameters that user has to send some of them
    ///
    /// Outputs:
    /// It returns a Model of "GetHistoryModel"  as output
    ///
    /// - parameters:
    ///     - count:      how many Messages do you spect to return (Int)
    ///     - fromTime:   filter the messages that sends after this time
    ///     - messageId:  if you want to search specific message with its messageId, fill this parameter
    ///     - offset:     from what offset do you want to get the Cache response (Int)
    ///     - order:      on what order do you want to get the response? "asc" or "desc". (String?)
    ///     - query:      if you want to search a specific term on the messages, fill this parameter. (String?)
    ///     - threadIds:  do you want to search messages on what threadId. (Int)
    ///     - fromTime:   filter the messages that sends before this time
    ///     - uniqueId:   if you want to search specific message with its uniqueId, fill this parameter
    ///
    /// - returns:
    ///     GetHistoryModel?
    ///
    public func retrieveMessageHistory(count:           Int,
                                       firstMessageId:  Int?,
                                       fromTime:        UInt?,
                                       lastMessageId:   Int?,
                                       messageId:       Int?,
                                       messageType:     Int?,
                                       offset:          Int,
                                       order:           String?,
                                       query:           String?,
                                       threadId:        Int,
                                       toTime:          UInt?,
                                       uniqueIds:       [String]?) -> GetHistoryModel? {
        /*
         first we have to make AND of these 2 properties: 'firstMessageId' AND 'lastMessageId'.
         then make them OR with 'query' property.
         ( (firstMessageId AND lastMessageId) OR query )
         after that, we will order them by the time, then based on the 'count' and 'offset' properties,
         we create the output model and return it.
         after all we only have to show messages that blongs to the 'threadId' property,
         so we AND the result of last operation with 'threadId' property.
         */
        let fetchRequest = retrieveMessageHistoryFetchRequest(fromTime:         fromTime,
                                                              messageId:        messageId,
                                                              messageType:      messageType,
                                                              order:            order,
                                                              query:            query,
                                                              threadId:         threadId,
                                                              toTime:           toTime,
                                                              uniqueIds:        uniqueIds)
        
        do {
            if let result = try context.fetch(fetchRequest) as? [CMMessage] {
                
                var foundGap = false
                if let gaps = retrieveMessageGaps(threadId: threadId) {
                    for gapItem in gaps {
                        for message in result {
                            if (gapItem == message.id as! Int) {
                                foundGap = true
                            }
                        }
                    }
                }
                
                if (!foundGap) {
                    var insideCount = 0
                    var cmMessageObjectArr = [CMMessage]()
                    
                    for (index, item) in result.enumerated() {
                        if (index >= offset) && (insideCount < count) {
                            cmMessageObjectArr.append(item)
                            insideCount += 1
                        }
                    }
                    
                    var messageArr = [Message]()
                    for item in cmMessageObjectArr {
                        messageArr.append(item.convertCMObjectToObject(showConversation: false, showForwardInfo: true, showParticipant: true, showReplyInfo: true))
                    }
                    
                    let getMessageModelResponse = GetHistoryModel(messageContent:   messageArr,
                                                                  contentCount:     result.count,
                                                                  count:            count,
                                                                  offset:           offset,
                                                                  hasError:         false,
                                                                  errorMessage:     "",
                                                                  errorCode:        0,
                                                                  threadId:         threadId)
                    return getMessageModelResponse
                } else {
                    return nil
                }
                
            } else {
                return nil
            }
        } catch {
            fatalError("Error on fetching list of CMMessage")
        }
    }
    
    /**
     * i used this method to create the NSFetchRequest on CMMessage Entity
     * every function that want to send a quesry on CMMessage Entity, will first call this function,
     * and this funciton will create the NSFetchRequest based on the input parameters to the caller
     */
    func retrieveMessageHistoryFetchRequest(fromTime:       UInt?,
                                            messageId:      Int?,
                                            messageType:    Int?,
                                            order:          String?,
                                            query:          String?,
                                            threadId:       Int?,
                                            toTime:         UInt?,
                                            uniqueIds:      [String]?) -> NSFetchRequest<NSFetchRequestResult> {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMMessage")
        
        // sort the result by the time
        let sortByTime = NSSortDescriptor(key:          "time",
                                          ascending:    (order == Ordering.ascending.rawValue) ? true: false)
        fetchRequest.sortDescriptors = [sortByTime]
        
        switch (messageId, uniqueIds, threadId, fromTime, toTime, query, messageType) {
            
        // if messageId is set, just search for message that has this exact messageId
        case let (.some(myMessageId), _, _, _, _, _, _):
            fetchRequest.predicate = NSPredicate(format: "id == %i", myMessageId)
            
        // if uniqueId is set, just search for message that has this exact uniqueId
        case let ( _, .some(myUniqueIds), _, _, _, _, _):
            var predicateArray = [NSPredicate]()
            for item in myUniqueIds {
                predicateArray.append(NSPredicate(format: "uniqueId == %@", item))
            }
            if (predicateArray.count == 1) {
                fetchRequest.predicate = predicateArray.first!
            } else if (predicateArray.count > 1) {
                let myAndCompoundPredicate = NSCompoundPredicate(type: .or, subpredicates: predicateArray)
                fetchRequest.predicate = myAndCompoundPredicate
            }
//            fetchRequest.predicate = NSPredicate(format: "uniqueId == %@", myUniqueId)
            
        // check if there was any parameter has been set, and put it's predicate statement on an array, then AND them all
        case let (.none, .none, threadId, fromTime, toTime, query, messageType):
            
            var predicateArray = [NSPredicate]()
            
            if let thId = threadId {
                predicateArray.append(NSPredicate(format: "threadId == %i", thId))
            }
            if let fTime = fromTime {
                predicateArray.append(NSPredicate(format: "time >= %i", fTime))
            }
            if let tTime = toTime {
                predicateArray.append(NSPredicate(format: "time <= %i", tTime))
            }
            if let searchQuery = query {
                if (searchQuery != "") {
                    predicateArray.append(NSPredicate(format: "message CONTAINS[cd] %@", searchQuery))
                }
            }
            if let tmessageType = messageType {
                predicateArray.append(NSPredicate(format: "messageType == %i", tmessageType))
            }
            
            if (predicateArray.count == 1) {
                fetchRequest.predicate = predicateArray.first!
            } else if (predicateArray.count > 1) {
                let myAndCompoundPredicate = NSCompoundPredicate(type: .and, subpredicates: predicateArray)
                fetchRequest.predicate = myAndCompoundPredicate
            }
            
        }
        
        return fetchRequest
    }
    
    
    /**
     * this method will get gaps on a specific threadId, and returns that messageIds
     */
    func retrieveMessageGaps(threadId: Int) -> [Int]? {
        /*
         *  -> search through the MessageGaps with the 'threadId'
         *  -> make the final result as array of MessageIds and pass it to the caller
         *
         */
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MessageGaps")
        
        // this predicate used to get gap messages that are in the specific thread using 'threadId' property
        let threadPredicate = NSPredicate(format: "threadId == %i", threadId)
        fetchRequest.predicate = threadPredicate
        
        do {
            if let result = try context.fetch(fetchRequest) as? [MessageGaps] {
                var msgIds: [Int] = []
                for msg in result {
                    msgIds.append((msg.messageId as? Int)!)
                }
                return msgIds
            } else {
                return nil
            }
        } catch {
            fatalError("Error on fetching list of MessageGaps")
        }
    }
    
    
    // MARK: - retrieve ImageObject:
    /// Retrieve ImageObject:
    ///
    /// - fetch CMImage from Cahce DB
    /// - if it found any object, it will return that,
    /// - otherwise it will return nil. (means cache has no relevent data(CMImage) on itself based on the input).
    ///
    /// first, it will fetch the Objects from CoreData.
    /// then based on the client request, it will find the objects that the client want to get,
    /// and then it will return it as 'UploadImageModel' model and its path (as String) to the client.
    ///
    /// Inputs:
    /// there are some parameters that user has to send some of them
    ///
    /// Outputs:
    /// It returns a Model of "GetHistoryModel"  as output
    ///
    /// - parameters:
    ///     - hashCode:      how many Messages do you spect to return (String)
    ///     - imageId:   filter the messages that sends after this time (Int)
    ///
    /// - returns:
    ///     (imageObject: ImageObject, imagePath: String)?
    ///
    public func retrieveImageObject(hashCode:   String) -> (imageObject: ImageObject, imagePath: String)? {
        /*
         *
         *  -> make this properties AND together: 'hashCode', 'id'
         *
         *  -> ('hashCode' && 'id')
         *
         *  -> create the UploadImageModel model
         *  -> get the imagePath
         *  -> return the UploadImageModel and imagePath as a tuple
         *
         */
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMImage")
        let searchImage = NSPredicate(format: "hashCode == %@", hashCode)
        fetchRequest.predicate = searchImage
        
        do {
            if let result = try context.fetch(fetchRequest) as? [CMImage] {
                
                if let firstObject = result.first {
                    let imageObject = firstObject.convertCMObjectToObject()
                    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                    let myImagePath = path + "/\(fileSubPath.Images)/" + "\(firstObject.hashCode ?? "default")"
                    
                    return (imageObject, myImagePath)
                } else {
                    return nil
                }
                
            } else {
                return nil
            }
        } catch {
            fatalError("Error on fetching list of CMImage")
        }
    }
    
    
    // MARK: - retrieve FileObject:
    /// Retrieve FileObject:
    ///
    /// - fetch CMImage from Cahce DB
    /// - if it found any object, it will return that,
    /// - otherwise it will return nil. (means cache has no relevent data(CMFile) on itself based on the input).
    ///
    /// first, it will fetch the Objects from CoreData.
    /// then based on the client request, it will find the objects that the client want to get,
    /// and then it will return it as 'UploadFileModel' model and its path (as String) to the client.
    ///
    /// Inputs:
    /// there are some parameters that user has to send some of them
    ///
    /// Outputs:
    /// It returns a Model of "GetHistoryModel"  as output
    ///
    /// - parameters:
    ///     - hashCode:      how many Messages do you spect to return (String)
    ///     - imageId:   filter the messages that sends after this time (Int)
    ///
    /// - returns:
    ///     (uploadFileModel: UploadFileModel, filePath: String)
    ///
    public func retrieveFileObject(hashCode:    String) -> (fileObject: FileObject, filePath: String)? {
        /*
         *
         *  -> make this properties AND together: 'hashCode', 'id'
         *
         *  -> ('hashCode' && 'id')
         *
         *  -> create the UploadFileModel model
         *  -> get the filePath
         *  -> return the UploadFileModel and filePath as a tuple
         *
         */
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMFile")
        let searchFile = NSPredicate(format: "hashCode == %@", hashCode)
        fetchRequest.predicate = searchFile
        
        do {
            if let result = try context.fetch(fetchRequest) as? [CMFile] {
                
                if let firstObject = result.first {
                    let fileObject = firstObject.convertCMObjectToObject()
                    
                    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                    let myFilePath = path + "/\(fileSubPath.Files)/" + "\(firstObject.hashCode ?? "default")"
                    
                    return (fileObject, myFilePath)
                } else {
                    return nil
                }
                
            } else {
                return nil
            }
        } catch {
            fatalError("Error on fetching list of CMFile")
        }
    }
    
    
    public func retrieveAllImagesSize() -> Int {
        
        var folderSize = 0
        // get your directory url
//        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/\(fileSubPath.Images)"
        let documentsDirectoryURL = URL(fileURLWithPath: path)
        
        // check if the url is a directory
        if (try? documentsDirectoryURL.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true {
            // lets get the folder files
            (try? FileManager.default.contentsOfDirectory(at: documentsDirectoryURL, includingPropertiesForKeys: nil))?.lazy.forEach {
                folderSize += (try? $0.resourceValues(forKeys: [.totalFileAllocatedSizeKey]))?.totalFileAllocatedSize ?? 0
            }
//            // format it using NSByteCountFormatter to display it properly
//            let  byteCountFormatter =  ByteCountFormatter()
//            byteCountFormatter.allowedUnits = .useBytes
//            byteCountFormatter.countStyle = .file
//            let folderSizeToDisplay = byteCountFormatter.string(for: folderSize) ?? ""
//            print(folderSizeToDisplay)  // "X,XXX,XXX bytes"
        }
        return folderSize
        
    }
    
    
    public func retrieveAllFilesSize() -> Int {
        
        var folderSize = 0
        // get your directory url
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/\(fileSubPath.Files)"
        let documentsDirectoryURL = URL(fileURLWithPath: path)
        
        // check if the url is a directory
        if (try? documentsDirectoryURL.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true {
            // lets get the folder files
            (try? FileManager.default.contentsOfDirectory(at: documentsDirectoryURL, includingPropertiesForKeys: nil))?.lazy.forEach {
                folderSize += (try? $0.resourceValues(forKeys: [.totalFileAllocatedSizeKey]))?.totalFileAllocatedSize ?? 0
            }
        }
        return folderSize
        
    }
    
    
}


