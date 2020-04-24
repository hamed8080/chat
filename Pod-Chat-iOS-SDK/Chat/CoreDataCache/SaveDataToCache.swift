//
//  SaveDataToCache.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 3/18/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON
import MobileCoreServices

// MARK: - Functions that will save data on CoreData Cache

extension Cache {
    
    
    // MARK: - save UserInfo:
    /// Save UserInfo:
    /// by calling this function, it will save (or update) the UserInfo on the Cache.
    ///
    /// - fetch CMUser on the cache (check if there is any information about UserInfo on the cache)
    /// - if it found some data (CMUser object), it will update that CMUser object
    /// - otherwise it will create an CMUser object and save that on the cache
    ///
    /// Inputs:
    /// it get a "User" model as an input
    ///
    /// Outputs:
    /// it returns no output
    ///
    /// - parameters:
    ///     - withUserObject:   the userModel to save on Cache.(User)
    ///
    /// - Returns:
    ///     none
    ///
    public func saveUserInfo(withUserObject user: User) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMUser")
        do {
            if let result = try context.fetch(fetchRequest) as? [CMUser] {
                if (result.count > 0) {
                    result.first!.updateObject(with: user)
                    saveContext(subject: "Update UserInfo -update existing object-")
                    
                } else {
                    let theUserEntity = NSEntityDescription.entity(forEntityName: "CMUser", in: context)
                    let theUser = CMUser(entity: theUserEntity!, insertInto: context)
                    theUser.updateObject(with: user)
                    saveContext(subject: "Update UserInfo -create a new object-")
                }
            }
        } catch {
            fatalError("Error on fetching list of CMUser")
        }
    }
    
    
    // MARK: - save CurrentUserRoles:
    /// Save Current User Roles:
    /// by calling this function, it will save (or update) the User Roles on the Cache.
    ///
    /// Inputs:
    /// it gets array of "Roles" and the threadId as Int value, an inputs
    ///
    /// Outputs:
    /// it returns no output
    ///
    /// - parameters:
    ///     - withRoles:    the currentUserRoles to save on the Cache.([Roles])
    ///     - onThreadId:   id of the thread that user has this roles. (Int)
    ///
    /// - Returns:
    ///     none
    ///
    public func saveCurrentUserRoles(withRoles: [Roles], onThreadId threadId: Int) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMCurrentUserRoles")
        fetchRequest.predicate = NSPredicate(format: "threadId == %i", threadId)
        do {
            if let result = try context.fetch(fetchRequest) as? [CMCurrentUserRoles] {
                if (result.count > 0) {
                    result.first!.updateObject(with: withRoles, onThreadId: threadId)
                    saveContext(subject: "Update CurrentUserRoles -update existing object-")
                    
                } else {
                    let theCurrentUserRolesEntity = NSEntityDescription.entity(forEntityName: "CMCurrentUserRoles", in: context)
                    let theCurrentUserRoles = CMCurrentUserRoles(entity: theCurrentUserRolesEntity!, insertInto: context)
                    theCurrentUserRoles.updateObject(with: withRoles, onThreadId: threadId)
                    saveContext(subject: "Creat CurrentUserRoles -create a new object-")
                }
            }
        } catch {
            fatalError("Error on fetching list of CMUser")
        }
    }
    
    
    
    // MARK: - save Contact:
    /// Save Contact:
    /// by calling this function, it save (or update) contacts that comes from server, into the Cache.
    ///
    /// - for every Contact object on 'contacts' Input
    ///     - send the Contact object to 'updateCMContactEntity(withContactObject:_)' method
    ///         - this function will create the Contact object on the cache, of if it was exist, it will update its values
    ///
    ///
    /// Inputs:
    /// it gets an array of "Contact" model as an input
    ///
    /// Outputs:
    /// it returns no output
    ///
    /// - parameters:
    ///     - withContactObjects:   contacts to save on Cache. ([Contact])
    ///
    /// - Returns:
    ///     none
    ///
    public func saveContact(withContactObjects contacts: [Contact]) {
        for item in contacts {
            _ = updateCMContactEntity(withContactObject: item)
        }
    }
    
    
    
    // MARK: - save PhoneBook Contact:
    /// Save PhoneBook Contact:
    /// by calling this function, it save (or update) PhoneContact that comes from users phone, into the Cache.
    ///
    /// - fetch PhoneContact objects from 'PhoneContact' Entity
    /// - filter it by cellphoneNumber
    /// - if it found any PhoneContact object, it will update its values on the Cache
    /// - otherwise it will create new CMContact
    ///
    /// Inputs:
    /// it gets  "AddContactRequestModel" model as an input
    ///
    /// Outputs:
    /// it returns no output
    ///
    /// - parameters:
    ///     -  contact:     contacts to save on Cache. (AddContactRequestModel)
    ///
    /// - Returns:
    ///     none
    ///
//    public func savePhoneBookContact(contact myContact: AddContactRequestModel) {
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PhoneContact")
//        if let contactCellphoneNumber = myContact.cellphoneNumber {
//            fetchRequest.predicate = NSPredicate(format: "cellphoneNumber == %@", contactCellphoneNumber)
//            do {
//                if let result = try context.fetch(fetchRequest) as? [PhoneContact] {
//                    if (result.count > 0) {
//                        result.first!.updateObject(with: myContact)
//                        saveContext(subject: "Update PhoneContact -update existing object-")
//                    } else {
//                        let thePhoneContactEntity = NSEntityDescription.entity(forEntityName: "PhoneContact", in: context)
//                        let thePhoneContact = PhoneContact(entity: thePhoneContactEntity!, insertInto: context)
//                        thePhoneContact.updateObject(with: myContact)
//                        saveContext(subject: "Update PhoneContact -create new object-")
//                    }
//                }
//            } catch {
//                fatalError("Error on trying to find the contact from PhoneContact entity")
//            }
//        }
//    }
    
    
    
    // MARK: - save Thread:
    /// Save Thread:
    /// by calling this function, save (or update) Threads that comes from server, into the cache
    ///
    /// - for every Conversation object on 'threads' Input
    ///     - send the Conversation object to 'updateCMConversationEntity(withConversationObject:_)' method
    ///         - this function will create the Conversation object on the cache, of if it was exist, it will update its values
    ///
    /// Inputs:
    /// it gets an array of  "[Conversation]" model as an input
    ///
    /// Outputs:
    /// it returns no output
    ///
    /// - parameters:
    ///     - withThreadObjects:    threads to save on Cache. ([Conversation])
    ///
    /// - Returns:
    ///     none
    ///
    public func saveThread(withThreadObjects threads: [Conversation]) {
        for item in threads {
            _ = updateCMConversationEntity(withConversationObject: item)
        }
    }
    
    
    // MARK: - save Pin/Unpin on Conversation:
    /// Save Pin/Unpin on CMConversation Entity:
    /// by calling this function, save (or update) Pin/Unpin property on Thread that comes from server, into the cache
    ///
    /// - fetch CMConversation objcets from the CMConversation Entity, and see if we already had this Conversation on the cache or not
    /// - if it found the object on the Entity, we it update only the "pin" property value of it,
    /// - if not, it will create CMConversation object and save it on the Cache
    ///
    /// Inputs:
    /// it gets the threadId as  "Int" value as an input
    ///
    /// Outputs:
    /// it returns no output
    ///
    /// - parameters:
    ///     - withThreadId: the id of the thread to make it pin. (Int)
    ///     - isPinned:     specify if this thread is pinned or not. (Bool)
    ///
    /// - Returns:
    ///     none
    ///
    func savePinUnpinCMConversationEntity(withThreadId id: Int, isPinned: Bool) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMConversation")
        fetchRequest.predicate = NSPredicate(format: "id == %i", id)
        do {
            if let result = try context.fetch(fetchRequest) as? [CMConversation] {
                if (result.count > 0) {
                    result.first!.pin = isPinned as NSNumber?
                    saveContext(subject: "Update CMConversation on PinThread -update existing object-")
                } else {
                    let conversationEntity = NSEntityDescription.entity(forEntityName: "CMConversation", in: context)
                    let conversation = CMConversation(entity: conversationEntity!, insertInto: context)
                    conversation.pin = isPinned as NSNumber?
                    saveContext(subject: "Update CMConversation on PinThread -create new object-")
                }
            }
        } catch {
            fatalError("Error on trying to find the thread from CMConversation entity")
        }
    }
    
    
    // MARK: - save/update Pin/Unpin:
    /// Save Pin/Unpin on CMMessage and CMConversation Entities:
    /// by calling this function, save (or update) 'pinMessage' property on Message that comes from server, into the cache
    ///
    /// Inputs:
    /// it gets the messageId as  "Int" , and pinMessage as "PinUnpinMessage" value as inputs
    ///
    /// Outputs:
    /// it returns no output
    ///
    /// - parameters:
    ///     - threadId:                 id of the thread. (Int)
    ///     - withPinMessageObject:     the pinMessageObject to save it on the cache. (PinUnpinMessage)
    ///
    /// - Returns:
    ///     none
    ///
    func savePinMessage(threadId: Int, withPinMessageObject pinMessage: PinUnpinMessage) {
        deletePinMessage(threadId: threadId)
        savePinMessageOnCMConversationEntity(threadId: threadId, withPinMessageObject: pinMessage)
        savePinMessageOnCMMessageEntity(messageId: pinMessage.messageId)
    }
    
    // MARK: - save Pin/Unpin on CMConversation Entity:
    /// Save Pin on CMConversation Entity:
    /// by calling this function, update 'pinMessage' property on Conversation that comes from server, into the cache
    ///
    /// Inputs:
    /// it gets the messageId as  "Int"  as input
    ///
    /// Outputs:
    /// it returns no output
    ///
    /// - parameters:
    ///     - threadId:                 id of the thread. (Int)
    ///     - withPinMessageObject:     the pinMessageObject to save it on the cache. (PinUnpinMessage)
    ///
    /// - Returns:
    ///     none
    ///
    func savePinMessageOnCMConversationEntity(threadId: Int, withPinMessageObject pinMessage: PinUnpinMessage) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMConversation")
        fetchRequest.predicate = NSPredicate(format: "id == %i", threadId)
        do {
            if let result = try context.fetch(fetchRequest) as? [CMConversation] {
                if (result.count > 0) {
                    result.first!.pinMessage = updateCMPinMessageEntity(withObject: pinMessage)
                    saveContext(subject: "Update CMConversation on save PinMessage -update existing object-")
                }
            }
        } catch {
            fatalError("Error on trying to find the Thread from CMConversation entity")
        }
    }
    
    // MARK: - save Pin/Unpin on CMMessage:
    /// Save Pin on CMMessage Entity:
    /// by calling this function, update 'pinMessage' property on Message that comes from server, into the cache
    ///
    /// Inputs:
    /// it gets the messageId as  "Int"  as input
    ///
    /// Outputs:
    /// it returns no output
    ///
    /// - parameters:
    ///     - messageId:        id of the message. (Int)
    ///
    /// - Returns:
    ///     none
    ///
    func savePinMessageOnCMMessageEntity(messageId: Int) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMMessage")
        fetchRequest.predicate = NSPredicate(format: "id == %i", messageId)
        do {
            if let result = try context.fetch(fetchRequest) as? [CMMessage] {
                if (result.count > 0) {
                    result.first!.pinned = true as NSNumber
                }
            }
        } catch {
            fatalError("Error on trying to find the Thread from CMMessage entity")
        }
    }
    
    
    // MARK: - save ThreadParticipant:
    /// Save ThreadParticipant:
    /// by calling this function, save (or update) threadParticipants that comes from server into the cache
    ///
    /// Inputs:
    /// it gets an array of  "[Participant]" model  and the "ThreadId" as inputs
    ///
    /// Outputs:
    /// it returns no output
    ///
    /// - parameters:
    ///     - whereThreadIdIs:      the threadId that you want to update your participants on. (Int)
    ///     - withParticipants:     send your participants to this parameter.([Participant])
    ///     - isAdminRequest:       if your request was getting adminParticipants, you have to send "true" to this parameter. (Bool)
    ///
    /// - Returns:
    ///     none
    ///
    public func saveThreadParticipantObjects(whereThreadIdIs threadId: Int, withParticipants participants: [Participant], isAdminRequest: Bool) {
        for item in participants {
            _ = updateCMParticipantEntity(inThreadId: threadId, withParticipantsObject: item, isAdminRequest: isAdminRequest)
        }
    }
    
    
    // ToDo: maybe i have to delete this method, because admins has handled on the 'saveThreadParticipantObjects' method
    public func updateAdminRoles(inThreadId threadId: Int, withUserRoles myUserRole: UserRole) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMParticipant")
        fetchRequest.predicate = NSPredicate(format: "id == %i AND threadId == %i", myUserRole.userId, threadId)
        do {
            if let result = try context.fetch(fetchRequest) as? [CMParticipant] {
                if (result.count > 0) {
                    result.first!.id        = myUserRole.userId as NSNumber?
                    result.first!.name      = myUserRole.name
                    result.first!.roles     = (myUserRole.roles != []) ? myUserRole.roles : nil
                    saveContext(subject: "Update CMParticipant -update existing object-")
                } else {    // it means that we couldn't find the CMParticipant object on the cache, so we will create one
                    let theParticipantEntity = NSEntityDescription.entity(forEntityName: "CMParticipant", in: context)
                    let theParticipant = CMParticipant(entity: theParticipantEntity!, insertInto: context)
                    theParticipant.id       = myUserRole.userId as NSNumber?
                    theParticipant.name     = myUserRole.name
                    theParticipant.roles    = (myUserRole.roles != []) ? myUserRole.roles : nil
                    saveContext(subject: "Update CMParticipant -create a new object-")
                }
            }
        } catch {
            fatalError("Error on trying to find the participant from CMParticipant entity")
        }
        
    }
    
    
    
    // MARK: - save Message:
    /// Save Message:
    /// by calling this function, save (or update) Messages that comes from server, in the Cache.
    ///
    /// Inputs:
    /// it gets an array of  "[Message]" model  and the "ThreadId" as inputs
    ///
    /// Outputs:
    /// it returns no output
    ///
    /// - parameters:
    ///     - messages:             send your messages to this parameter.([Message])
    ///     - getHistoryParams:     this variable will contains the getHistory Request that has send and couses the 'messages' response. (JSON?)
    ///
    /// - Returns:
    ///     none
    ///
    public func saveMessageObjects(messages: [Message], getHistoryParams: JSON?) {
        /*
         *  -> check if we have 'getHistoryParams' Input or not
         *      -> check if user request contains 'metadataCriteria' or not
         *      -> if yes, don't update or delete anything on the cache, just insert newThings
         *      -> if no, we have to update and delete item on the cache, then insert new objects
         *
         *      -> based on the users input request, check every possible conditions:
         *
         *          1-
         *              input:
         *                  count   = Int
         *                  offset  = 0
         *                  order is not important
         *                  all the other conditions = nil
         *              server response:
         *                  messages = nil
         *              means we request to get ('count' number of messages) from offset 0, and the server response was empty,
         *              means we have no message on this thread.
         *              -> delete all of the message from cache
         *
         *          2-
         *              input:
         *                  count   = Int
         *                  offset  = Int
         *                  order   = ascending
         *                  all the other conditions = nil
         *              server response:
         *                  messages = nil
         *              means we request to get messages with ASCENDING order , and the server response was empty,
         *              means we have no message after this offset on this thread.
         *              -> delete all of the messages from cache which has bigger time than the first item on the cache result
         *
         *          3-
         *              input:
         *                  count   = Int
         *                  offset  = Int
         *                  order   = descending
         *                  all the other conditions = nil
         *              server response:
         *                  messages = nil
         *              means we request to get messages with DESCENDING order , and the server response was empty,
         *              means we have no message befor this offset on this thread.
         *              -> delete all of the messages from cache which has smaller time than the first item on the cache result
         *
         *          4-
         *              input:
         *                  count   = Int
         *                  offset  = 0
         *                  order   = ascending
         *                  all the other conditions = nil
         *              server response:
         *                  messages = [MessageObject]
         *              means we request to get messages with ASCENDING order, and the server response was not empty,
         *              so the first Messasge of this result is the first Message of the thread
         *              -> delete everything from cache which has smaller time than this one
         *              -> delete all of the messages between firstMessage and lastMessage of this result from cache database
         *
         *          5-
         *              input:
         *                  count   = Int
         *                  offset  = 0
         *                  order   = descending
         *                  all the other conditions = nil
         *              server response:
         *                  messages = [MessageObject]
         *              means we request to get messages with DESCENDING order, and the server response was not empty,
         *              so the first Message of this result is the first Message of the thread,
         *              -> delete everything from cache which has bigger time than this one
         *              -> delete all of the messages between firstMessage and lastMessage of this result from cache database
         *
         *          6-
         *              input:
         *                  count   = Int
         *                  offset  = Int
         *                  order   = ascending
         *                  all the other conditions = nil
         *              server response:
         *                  messages = [MessageObject]
         *              means we request to get messages with ASCENDING order, and the server response was not empty,
         *              check if last message's previouseId = nil, so it is the first message of thread
         *              -> delete everything before the lastMessage
         *              -> delete all of the messages between firstMessage and lastMessage of this result from cache database
         *
         *          7-
         *              input:
         *                  count   = Int
         *                  offset  = Int
         *                  order   = desscending
         *                  all the other conditions = nil
         *              server response:
         *                  messages = [MessageObject]
         *              means we request to get messages with DESCENDING order, and the server response was not empty,
         *              check if first message's previouseId = nil, so it is the last message of thread
         *              -> delete everything after the firtMessage
         *              -> delete all of the messages between firstMessage and lastMessage of this result from cache database
         *
         *          8-
         *              input:
         *                  messageId   = Int
         *                  all the other conditions = Any
         *              server response:
         *                  messages = [nil]
         *              means we request to get messages with specific messagreId, and the server response was empty,
         *              means we don't have this message on the server anymore
         *              -> delete specific message with its messageId
         *
         *          9-
         *              input:
         *                  query   = String
         *                  all the other conditions = Any
         *              server response:
         *                  messages = Any
         *              means we request to get messages with query
         *              we have to delete all messages that we have on the cache (afterward we will save server answers into it)
         *              -> delete all messages with this query input
         *
         *          10-s
         *              input:
         *                  fromTime    = UInt
         *                  toTime      = UInt
         *                  all the other conditions = Any
         *              server response:
         *                  messages = Any
         *              means both fromTime and toTime has been set
         *              we should delete all messages from cache in this boundry
         *              -> delete all messages with this fromTime, toTime inputs
         *
         *  -> for all messages, update the CMMessageEntity
         *  -> Update the MessageGapEntity inside this specific thread
         *
         */
        
        
        if let params   = getHistoryParams {
            let count       = params["count"].intValue
            let offset      = params["offset"].intValue
            let id          = params["id"].int
            let fromTime    = params["fromTime"].uInt
            let toTime      = params["toTime"].uInt
            let order       = params["order"].string
            let query       = params["query"].string
            let threadId    = params["threadId"].int
//            let uniqueId    = params["uniqueId"].string
            
            if let _ = params["metadataCriteria"] as JSON? {
                
            } else {
                
                switch (count, offset, id, fromTime, toTime, order, query, messages.count) {
                    
                // 1- delete everything from cache
                case (count, 0, .none, .none, .none, _, .none, 0):
                    deleteMessage(count:        nil,
                                  fromTime:     nil,
                                  messageId:    nil,
                                  offset:       offset,
                                  order:        order ?? Ordering.descending.rawValue,
                                  query:        nil,
                                  threadId:     threadId,
                                  toTime:       nil,
                                  uniqueId:     nil)
                    break
                    
                // 2- delete all records that:     'time' > 'time' (first item on the cache result)
                case (count, offset, .none, .none, .none, Ordering.ascending.rawValue, .none, 0):
                    var firstObject: Message?
                    let fetchRequest = retrieveMessageHistoryFetchRequest(fromTime:         nil,
                                                                          messageId:        nil,
                                                                          order:            nil,
                                                                          query:            nil,
                                                                          threadId:         threadId,
                                                                          toTime:           nil,
                                                                          uniqueIds:        nil)
                    do {
                        if let result = try context.fetch(fetchRequest) as? [Message] {
                            if result.count > 0 {
                                firstObject = result.first!
                            }
                        }
                    } catch {
                        fatalError()
                    }
                    if let fObject = firstObject {
                        if let firstObjectTime = fObject.time {
                            deleteMessage(count:        nil,
                                          fromTime:     firstObjectTime,
                                          messageId:    nil,
                                          offset:       offset,
                                          order:        order ?? Ordering.ascending.rawValue,
                                          query:        nil,
                                          threadId:     threadId,
                                          toTime:       nil,
                                          uniqueId:     nil)
                        }
                    }
                    break
                    
                // 3- delete all records that:     'time' < 'time' (first item on the cache result)
                case (count, offset, .none, .none, .none, Ordering.descending.rawValue, .none, 0):
                    var lastObject: Message?
                    let fetchRequest = retrieveMessageHistoryFetchRequest(fromTime:         nil,
                                                                          messageId:        nil,
                                                                          order:            nil,
                                                                          query:            nil,
                                                                          threadId:         threadId,
                                                                          toTime:           nil,
                                                                          uniqueIds:        nil)
                    do {
                        if let result = try context.fetch(fetchRequest) as? [Message] {
                            if result.count > 0 {
                                lastObject = result.first!
                            }
                        }
                    } catch {
                        fatalError()
                    }
                    if let lObject = lastObject {
                        if let lastObjectTime = lObject.time {
                            deleteMessage(count:        nil,
                                          fromTime:     nil,
                                          messageId:    nil,
                                          offset:       offset,
                                          order:        order ?? Ordering.ascending.rawValue,
                                          query:        nil,
                                          threadId:     threadId,
                                          toTime:       lastObjectTime,
                                          uniqueId:     nil)
                        }
                    }
                    break
                    
                    
                
                // 4- delete all records that:   'time' < result.first.time
                // delete every message between result.first and result.last from cache
                case (count, 0, .none, .none, .none, Ordering.ascending.rawValue, .none, _):
                    deleteMessage(count:        nil,
                                  fromTime:     nil,
                                  messageId:    nil,
                                  offset:       0,
                                  order:        Ordering.ascending.rawValue,
                                  query:        nil,
                                  threadId:     threadId,
                                  toTime:       messages.first!.time!,
                                  uniqueId:     nil)
                    
                    deleteMessage(count:        nil,
                                  fromTime:     messages.first!.time!,
                                  messageId:    nil,
                                  offset:       0,
                                  order:        Ordering.ascending.rawValue,
                                  query:        nil,
                                  threadId:     threadId,
                                  toTime:       messages.last!.time!,
                                  uniqueId:     nil)
                    break
                    
                // 5- delete all records that:   'time' > result.first.time
                // delete every message between result.first and result.last from cache
                case (count, 0, .none, .none, .none, Ordering.descending.rawValue, .none, _):
                    deleteMessage(count:        nil,
                                  fromTime:     messages.first!.time!, messageId: nil,
                                  offset:       0,
                                  order:        Ordering.descending.rawValue,
                                  query:        nil,
                                  threadId:     threadId,
                                  toTime:       nil,
                                  uniqueId:     nil)
                    
                    deleteMessage(count:        nil,
                                  fromTime:     messages.first!.time!,
                                  messageId:    nil,
                                  offset:       0,
                                  order:        Ordering.descending.rawValue,
                                  query:        nil,
                                  threadId:     threadId,
                                  toTime:       messages.last!.time!,
                                  uniqueId:     nil)
                    break
                    
                // 6- if (result.last.previousId = nil) => delete all recored befor the result.last
                // delete every message between result.first and result.last from cache
                case (count, offset, .none, .none, .none, Ordering.ascending.rawValue, .none, _):
                    if (messages.last!.previousId == nil) {
                        deleteMessage(count:        nil,
                                      fromTime:     nil,
                                      messageId:    nil,
                                      offset:       0,
                                      order:        Ordering.ascending.rawValue,
                                      query:        nil,
                                      threadId:     threadId,
                                      toTime:       messages.last!.time!,
                                      uniqueId:     nil)
                    }
                    deleteMessage(count:        nil,
                                  fromTime:     messages.first!.time!,
                                  messageId:    nil,
                                  offset:       0,
                                  order:        Ordering.ascending.rawValue,
                                  query:        nil,
                                  threadId:     threadId,
                                  toTime:       messages.last!.time!,
                                  uniqueId:     nil)
                    break
                    
                // 7- if (result.first.previousId = nil) => delete all recored befor the result.first
                // delete every message between result.first and result.last from cache
                case (count, offset, .none, .none, .none, Ordering.descending.rawValue, .none, _):
                    if (messages.first!.previousId == nil) {
                        deleteMessage(count:        nil,
                                      fromTime:     nil,
                                      messageId:    nil,
                                      offset:       0,
                                      order:        Ordering.descending.rawValue,
                                      query:        nil,
                                      threadId:     threadId,
                                      toTime:       messages.last!.time!,
                                      uniqueId:     nil)
                    }
                    deleteMessage(count:        nil,
                                  fromTime:     messages.first!.time!,
                                  messageId:    nil,
                                  offset:       0,
                                  order:        Ordering.descending.rawValue,
                                  query:        nil,
                                  threadId:     threadId,
                                  toTime:       messages.last!.time!,
                                  uniqueId:     nil)
                    break
                    
//                // 8- delete the exact message with messageId
//                case let (_, _, .some(theId), _, _, order, _, 0):
//                    deleteMessage(count:        nil,
//                                  fromTime:     nil,
//                                  messageId:    theId,
//                                  offset:       0,
//                                  order:        order ?? Ordering.descending.rawValue,
//                                  query:        nil,
//                                  threadId:     threadId,
//                                  toTime:       nil,
//                                  uniqueId:     nil)
//                    break
//
//                // 9- delete all result from cache
//                case let (_, _, .none, _, _, _, .some(myQuery), _):
//                    deleteMessage(count:        nil,
//                                  fromTime:     nil,
//                                  messageId:    nil,
//                                  offset:       0,
//                                  order:        order ?? Ordering.descending.rawValue,
//                                  query:        myQuery,
//                                  threadId:     threadId,
//                                  toTime:       nil,
//                                  uniqueId:     nil)
//                    break
                    
                case let (count, offset, id, from, to, order, query, result):
                    
                    // 8- delete the exact message with messageId
                    if let myId = id {
                        if result == 0 {
                            // delete the message with 'id' from cache
                            deleteMessage(count:        nil,
                                          fromTime:     nil,
                                          messageId:    myId,
                                          offset:       0,
                                          order:        order ?? Ordering.descending.rawValue,
                                          query:        nil,
                                          threadId:     threadId,
                                          toTime:       nil,
                                          uniqueId:     nil)
                        }
                    }
                    
                    // 9- delete all result from cache with this query
                    if let myQuery = query {
                        // delete result of the cache + then add new result to the cache
                        deleteMessage(count:        nil,
                                      fromTime:     nil,
                                      messageId:    nil,
                                      offset:       0,
                                      order:        order ?? Ordering.descending.rawValue,
                                      query:        myQuery,
                                      threadId:     threadId,
                                      toTime:       nil,
                                      uniqueId:     nil)
                    }
                    
                    // 10- delete all result from cache in ftomTime, toTime boundry
                    if (from != nil) || (to != nil) {
                        
                        // Server response is empty
                        if result == 0 {
                            
                            if (from != nil) && (to != nil) {
                                deleteMessage(count:        nil,
                                              fromTime:     from,
                                              messageId:    nil,
                                              offset:       0,
                                              order:        order ?? Ordering.descending.rawValue,
                                              query:        nil,
                                              threadId:     threadId,
                                              toTime:       to,
                                              uniqueId:     nil)
                                
                            } else if let fromTime = from {
                                deleteMessage(count:        nil,
                                              fromTime:     fromTime,
                                              messageId:    nil,
                                              offset:       0,
                                              order:        order ?? Ordering.descending.rawValue,
                                              query:        nil,
                                              threadId:     threadId,
                                              toTime:       nil,
                                              uniqueId:     nil)
                                
                            } else if let toTime = to {
                                deleteMessage(count:        nil,
                                              fromTime:     nil,
                                              messageId:    nil,
                                              offset:       0,
                                              order:        order ?? Ordering.descending.rawValue,
                                              query:        nil,
                                              threadId:     threadId,
                                              toTime:       toTime,
                                              uniqueId:     nil)
                            }
                            
                        }
                            
                        // Server response is not empty
                        else {
                            deleteMessage(count:        count,
                                          fromTime:     from,
                                          messageId:    nil,
                                          offset:       offset,
                                          order:        order ?? Ordering.descending.rawValue,
                                          query:        nil,
                                          threadId:     threadId,
                                          toTime:       to,
                                          uniqueId:     nil)
                        }
                        
                    }
                    
                    break
                }
            }
            
        }
        
        // now insert server result in the cache
        for item in messages {
            _ = updateCMMessageEntity(withMessageObject: item)
        }
        
        if let params = getHistoryParams {
            if let threadId = params["threadId"].int {
                updateAllMessageGapEntity(inThreadId: threadId)
            }
        }
        
    }
    
    
    
    
    
    
    // MARK: - save ImageObject:
    /// Save ImageObject:
    /// this function will save (or update) image response that comes from server, in the Cache.
    ///
    /// - check if there is any information about This Image File in the cache
    /// - if it has some data, it will update that data,
    /// - otherwise it will create an object and save data on cache
    ///
    /// Inputs:
    /// it gets the 'ImageObject' model,  and the imageData as 'Data' value, and localPath (optional) as inputs
    ///
    /// Outputs:
    /// it returns no output
    ///
    /// - parameters:
    ///     - imageInfo:    the imageObject that contains image properties to save on the Cache. (ImageObject)
    ///     - imageData:    the image data value. (Data)
    ///     - toLocalPath:  the path that the client specified to save this image on. (URL?)
    ///
    /// - Returns:
    ///     none
    ///
    public func saveImageObject(imageInfo: ImageObject, imageData: Data, toLocalPath: URL?) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMImage")
        do {
            if let result = try context.fetch(fetchRequest) as? [CMImage] {
                // if there is a value in this fetch request, it mean that we had already saved This Image info in the Cache.
                // so we just have to update that information with new response that comes from server
                
                /*
                 if find sth, check out the information about that file:
                 if the info of both, was the same, just delete the fileInfo from cache, and then save it later
                 if the info was different, just save the new info in the cache and link it to this image file path
                 */
                
                var tempImage: ImageObject?
                
                // Part1:
                // find data that are exist in the Cache, (and the response request is containing that). and delete them
                for itemInCache in result {
                    if let imageId = Int(exactly: itemInCache.id!) {
                        if (imageId == imageInfo.id) {
                            
                            tempImage = ImageObject(actualHeight: itemInCache.actualHeight as? Int,
                                                    actualWidth:  itemInCache.actualWidth as? Int,
                                                    hashCode:     itemInCache.hashCode!,
                                                    height:       itemInCache.height as? Int,
                                                    id:           itemInCache.id as! Int,
                                                    name:         itemInCache.name,
                                                    width:        itemInCache.width as? Int)
                            
                            // the uploadImage object that we are going to create, is already exist in the Cache
                            // to update information in this object:
                            // we will delete them first, then we will create it again later
                            
                            // delete the original file from local storage of the app, using path of the file
                            var imagePath = ""
                            if let path = toLocalPath {
                                imagePath = path.absoluteString
                            } else {
                                let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                                imagePath = path + "/\(fileSubPath.Images)/"
                            }
                            
                            let myImagePath = imagePath + "\(itemInCache.id!)\(itemInCache.name ?? "default")"
                            // check if this file is exixt on the app bunde, then delete it
                            if FileManager.default.fileExists(atPath: myImagePath) {
                                do {
                                    try FileManager.default.removeItem(atPath: myImagePath)
                                } catch {
                                    fatalError("can not delete the image from app bundle!")
                                }
                            }
                            
                            // delete the information from cache
                            deleteAndSave(object: itemInCache, withMessage: "Delete CMImage Object")
                        }
                    }
                }
                
                // Part2:
                // save data comes from server to the Cache
                let theUploadImageEntity = NSEntityDescription.entity(forEntityName: "CMImage", in: context)
                let theUploadImage = CMImage(entity: theUploadImageEntity!, insertInto: context)
                
                theUploadImage.actualHeight = (imageInfo.actualHeight ?? tempImage?.actualHeight) as NSNumber?
                theUploadImage.actualWidth  = (imageInfo.actualWidth ?? tempImage?.actualWidth) as NSNumber?
                theUploadImage.hashCode     = imageInfo.hashCode
                theUploadImage.height       = (imageInfo.height ?? tempImage?.height) as NSNumber?
                theUploadImage.id           = imageInfo.id as NSNumber?
                theUploadImage.name         = (imageInfo.name ?? tempImage?.name)
                theUploadImage.width        = (imageInfo.width ?? tempImage?.width) as NSNumber?
                
                // save file on app bundle
                var imagesLocalirectory: URL
                if let path = toLocalPath {
                    imagesLocalirectory = path
                } else {
                    let directoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                    let directoryURL        = URL(fileURLWithPath: directoryPath)
                    imagesLocalirectory = directoryURL.appendingPathComponent("\(fileSubPath.Images)")
                }
                
                createDirectory(at: imagesLocalirectory)
                
                let imageLocalAdress    = imagesLocalirectory.appendingPathComponent("\(imageInfo.id)\(imageInfo.name ?? "default")")
                saveDataToDirectory(data: imageData, to: imageLocalAdress)
                
                saveContext(subject: "Update UploadImage")
            }
        } catch {
            fatalError("Error on fetching list of Conversations")
        }
        
    }
    
    
    
    // MARK: - save FileObject:
    /// Save FileObject:
    /// this function will save (or update) uploaded image response that comes from server, in the Cache.
    ///
    /// - check if there is any information about This File in the cache
    /// - if it has some data, it will update that data,
    /// - otherwise it will create an object and save data on cache
    ///
    /// Inputs:
    /// it gets the 'FileObject' model,  and the fileData as 'Data' value, and localPath (optional) as inputs
    ///
    /// Outputs:
    /// it returns no output
    ///
    /// - parameters:
    ///     - fileInfo:     the FileObject that contains file properties to save on the Cache. (FileObject)
    ///     - imageData:    the file data value. (Data)
    ///     - toLocalPath:  the path that the client specified to save this file on. (URL?)
    ///
    /// - Returns:
    ///     none
    ///
    public func saveFileObject(fileInfo: FileObject, fileData: Data, toLocalPath: URL?) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMFile")
        do {
            
            if let result = try context.fetch(fetchRequest) as? [CMFile] {
                // if there is a value in this fetch request, it mean that we had already saved This Image info in the Cache.
                // so we just have to update that information with new response that comes from server
                
                /*
                 if find sth, check out the information about that file:
                 if the info of both, was the same, just delete the fileInfo from cache, and then save it later
                 if the info was different, just save the new info in the cache and link it to this image file path
                 */
                
                var tempFile: FileObject?
                
                // Part1:
                // find data that are exist in the Cache, (and the response request is containing that). and delete them
                for itemInCache in result {
                    if let fileId = Int(exactly: itemInCache.id ?? 0) {
                        if (fileId == fileInfo.id) {
                            
                            tempFile = FileObject(hashCode:  itemInCache.hashCode!,
                                                  id:        itemInCache.id as! Int,
                                                  name:      itemInCache.name)
                            
                            // the uploadFile object that we are going to create, is already exist in the Cache
                            // to update information in this object:
                            // we will delete them first, then we will create it again later
                            
                            // delete the original file from local storage of the app, using path of the file
                            var filePath = ""
                            if let path = toLocalPath {
                                filePath = path.absoluteString
                            } else {
                                let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                                filePath = path + "/\(fileSubPath.Files)/"
                            }
                            
                            let myFilePath = filePath + "\(itemInCache.id!)\(itemInCache.name ?? "default")"
                            
                            if FileManager.default.fileExists(atPath: myFilePath) {
                                do {
                                    try FileManager.default.removeItem(atPath: myFilePath)
                                } catch {
                                    fatalError("can not delete the image from app bundle!")
                                }
                            }
                            
                            // delete the information from cache
                            deleteAndSave(object: itemInCache, withMessage: "Delete CMFile Object")
                        }
                    }
                }
                
                // Part2:
                // save data comes from server to the Cache
                let theUploadFileEntity = NSEntityDescription.entity(forEntityName: "CMFile", in: context)
                let theUploadFile = CMFile(entity: theUploadFileEntity!, insertInto: context)
                
                theUploadFile.hashCode      = fileInfo.hashCode
                theUploadFile.id            = fileInfo.id as NSNumber?
                theUploadFile.name          = (fileInfo.name ?? tempFile?.name)
                
                // save file on app bundle
                var filesLocalirectory: URL
                if let path = toLocalPath {
                    filesLocalirectory = path
                } else {
                    let directoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                    let directoryURL = URL(fileURLWithPath: directoryPath)
                    filesLocalirectory = directoryURL.appendingPathComponent("\(fileSubPath.Files)")
                }
                
                createDirectory(at: filesLocalirectory)
                
                let fileLocalAdress    = filesLocalirectory.appendingPathComponent("\(fileInfo.id)\(fileInfo.name ?? "default")")
                saveDataToDirectory(data: fileData, to: fileLocalAdress)
                
                saveContext(subject: "Update UploadFile")
            }
        } catch {
            fatalError("Error on fetching list of Conversations")
        }
        
    }
    
    
    
    private func createDirectory(at url: URL) {
        if !(FileManager.default.fileExists(atPath: url.path, isDirectory: nil)) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
                print("directory created at:\n \(url)")
            } catch {
                print("error on creating Directory \n\(error.localizedDescription)")
            }
        }
    }
    
    private func saveDataToDirectory(data: Data, to url: URL) {
        do {
            try data.write(to: url)
        } catch {
            print("error when try to write data on documentDirectory \n\(error.localizedDescription)")
        }
    }
    
    
    
    
    
}
