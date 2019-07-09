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

// MARK: - Functions that will save data on CoreData Cache

extension Cache {
    
    /*
     * Save UserInfo:
     * by calling this function, it will save (or update) the UserInfo on the Cache.
     *
     *  + Access:   Public
     *  + Inputs:
     *      - user: User
     *  + Outputs:  _
     *
     */
    public func saveUserInfo(withUserObject user: User) {
        /*
         -> fetch CMUser on the cache (check if there is any information about UserInfo on the cache)
         -> if it has found some data (CMUser object), it we will update that CMUser object
         -> otherwise we will create an CMUser object and save that on the cache
         */
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMUser")
        do {
            if let result = try context.fetch(fetchRequest) as? [CMUser] {
                // if there is a value in this fetch request, it mean that we had already saved UserInfo on the Cache.
                // so we just have to update that information with new response that comes from server
                if (result.count > 0) {
                    result.first!.cellphoneNumber   = user.cellphoneNumber
                    result.first!.coreUserId        = user.coreUserId as NSNumber?
                    result.first!.email             = user.email
                    result.first!.id                = user.id as NSNumber?
                    result.first!.image             = user.image
                    result.first!.lastSeen          = user.lastSeen as NSNumber?
                    result.first!.name              = user.name
                    result.first!.receiveEnable     = user.receiveEnable as NSNumber?
                    result.first!.sendEnable        = user.sendEnable as NSNumber?
                    
                    // save function that will try to save changes that made on the Cache
                    saveContext(subject: "Update UserInfo -update existing object-")
                    
                } else {
                    // if there wasn't any CMUser object (means there is no information about UserInfo on the Cache)
                    // this part will execute, which will create an object of User and save it on the Cache
                    let theUserEntity = NSEntityDescription.entity(forEntityName: "CMUser", in: context)
                    let theUser = CMUser(entity: theUserEntity!, insertInto: context)
                    
                    theUser.cellphoneNumber    = user.cellphoneNumber
                    theUser.coreUserId         = user.coreUserId as NSNumber?
                    theUser.email              = user.email
                    theUser.id                 = user.id as NSNumber?
                    theUser.image              = user.image
                    theUser.lastSeen           = user.lastSeen as NSNumber?
                    theUser.name               = user.name
                    theUser.receiveEnable      = user.receiveEnable as NSNumber?
                    theUser.sendEnable         = user.sendEnable as NSNumber?
                    
                    // save function that will try to save changes that made on the Cache
                    saveContext(subject: "Update UserInfo -create a new object-")
                }
            }
        } catch {
            fatalError("Error on fetching list of CMUser")
        }
    }
    
    
    /*
     * Save Contact:
     * by calling this function, it save (or update) contacts that comes from server, into the Cache.
     *
     *  + Access:   Public
     *  + Inputs:
     *      - contacts: [Contact]
     *  + Outputs:  _
     *
     */
    public func saveContact(withContactObjects contacts: [Contact]) {
        
        for item in contacts {
            _ = updateCMContactEntity(withContactObject: item)
        }
        
        /*
         // check if there is any information about Contact that are in the cache,
         // if they has beed there, it we will update that data,
         // otherwise we will create an object and save data on cache
         let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMContact")
         do {
         if let result = try context.fetch(fetchRequest) as? [CMContact] {
         
         // Part1:
         // find data that are exist in the Cache, (and the response request is containing that). and delete them
         for item in contacts {
         for itemInCache in result {
         if let contactId = Int(exactly: itemInCache.id ?? 0) {
         if (contactId == item.id) {
         // the contact object that we are going to create, is already exist in the Cache
         // to update information in this object:
         // we will delete them first, then we will create it again later
         
         itemInCache.linkedUser = nil
         context.delete(itemInCache)
         
         saveContext(subject: "Delete CMContact Object")
         }
         }
         
         }
         }
         
         // Part2:
         // save data comes from server to the Cache
         var allContacts = [CMContact]()
         
         for item in contacts {
         let theContactEntity = NSEntityDescription.entity(forEntityName: "CMContact", in: context)
         let theContact = CMContact(entity: theContactEntity!, insertInto: context)
         
         theContact.cellphoneNumber  = item.cellphoneNumber
         theContact.email            = item.email
         theContact.firstName        = item.firstName
         theContact.hasUser          = item.hasUser as NSNumber?
         theContact.id               = item.id as NSNumber?
         theContact.image            = item.image
         theContact.lastName         = item.lastName
         theContact.notSeenDuration  = item.notSeenDuration as NSNumber?
         theContact.uniqueId         = item.uniqueId
         theContact.userId           = item.userId as NSNumber?
         
         let theLinkedUserEntity = NSEntityDescription.entity(forEntityName: "CMLinkedUser", in: context)
         let theLinkedUser = CMLinkedUser(entity: theLinkedUserEntity!, insertInto: context)
         theLinkedUser.coreUserId    = item.linkedUser?.coreUserId as NSNumber?
         theLinkedUser.image         = item.linkedUser?.image
         theLinkedUser.name          = item.linkedUser?.name
         theLinkedUser.nickname      = item.linkedUser?.nickname
         theLinkedUser.username      = item.linkedUser?.username
         
         theContact.linkedUser = theLinkedUser
         
         allContacts.append(theContact)
         }
         
         saveContext(subject: "Update CMContact")
         }
         } catch {
         fatalError("Error on fetching list of CMConversation")
         }
         */
        
    }
    
    
    /*
     * Save PhoneBook Contact:
     *
     * by calling this function, it save (or update) PhoneContact that comes from users phone, into the Cache.
     * -> it will fetch PhoneContact
     * -> if it found any object that has the same 'cellphoneNumber' as the input contact 'cellphoneNumber',
     *    it will update its properties
     * -> otherwise it will create a PhoneContact object on the cache
     *
     *  + Access:   Public
     *  + Inputs:
     *      - contact:  AddContactsRequestModel
     *  + Outputs:  _
     *
     */
    public func savePhoneBookContact(contact myContact: AddContactsRequestModel) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PhoneContact")
        if let contactCellphoneNumber = myContact.cellphoneNumber {
            fetchRequest.predicate = NSPredicate(format: "cellphoneNumber == %@", contactCellphoneNumber)
            do {
                if let result = try context.fetch(fetchRequest) as? [PhoneContact] {
                    if (result.count > 0) {
                        result.first!.cellphoneNumber   = myContact.cellphoneNumber
                        result.first!.email             = myContact.email
                        result.first!.firstName         = myContact.firstName
                        result.first!.lastName          = myContact.lastName
                        
                        saveContext(subject: "Update PhoneContact -update existing object-")
                    }
                } else {
                    let theContactEntity = NSEntityDescription.entity(forEntityName: "PhoneContact", in: context)
                    let theContact = CMContact(entity: theContactEntity!, insertInto: context)
                    
                    theContact.cellphoneNumber  = myContact.cellphoneNumber
                    theContact.email            = myContact.email
                    theContact.firstName        = myContact.firstName
                    theContact.lastName         = myContact.lastName
                    
                    saveContext(subject: "Update PhoneContact -create new object-")
                }
            } catch {
                fatalError("Error on trying to find the contact from PhoneContact entity")
            }
        }
        
    }
    
    
    
    
    
    
    /*
     * Save Thread:
     *
     * by calling this function, it save (or update) Threads that comes from server, into the cache
     *
     *  + Access:   Public
     *  + Inputs:
     *      - threads: [Conversation]
     *  + Outputs:  _
     *
     */
    public func saveThread(withThreadObjects threads: [Conversation]) {
        
        for item in threads {
            _ = updateCMConversationEntity(withConversationObject: item)
        }
        
        /*
         // check if there is any information about Conversations that are in the cache,
         // which if it has been there, it we will update that data,
         // otherwise we will create an object and save data on cache
         let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMConversation")
         do {
         if let result = try context.fetch(fetchRequest) as? [CMConversation] {
         
         // Part1:
         // find data that are exist in the Cache, (and the response request is containing that). and delete them
         for item in threads {
         for itemInCache in result {
         if let conversationId = Int(exactly: itemInCache.id ?? 0) {
         print("Conversation id = \(item.id ?? 99999) ; CMConversation id = \(conversationId)")
         if (conversationId == item.id) {
         // the conversation object that we are going to create, is already exist in the Cache
         // to update information in this object:
         // we will delete them first, then we will create it again later
         
         if let _ = itemInCache.inviter {
         context.delete(itemInCache.inviter!)
         saveContext(subject: "Delete CMParticipant Object as inviter")
         }
         if let _ = itemInCache.lastMessageVO {
         context.delete(itemInCache.lastMessageVO!)
         saveContext(subject: "Delete CMMessage Object as lastMessageVO")
         }
         if let _ = itemInCache.participants {
         for item in itemInCache.participants! {
         context.delete(item)
         saveContext(subject: "Delete CMParticipant Object as object in participants")
         }
         }
         
         //                                itemInCache.inviter = nil
         //                                itemInCache.lastMessageVO = nil
         //                                itemInCache.participants = nil
         context.delete(itemInCache)
         
         saveContext(subject: "Delete CMConversation Object")
         }
         }
         }
         }
         
         // Part2:
         // save data comes from server to the Cache
         var allThreads = [CMConversation]()
         
         for item in threads {
         let conversationEntity = NSEntityDescription.entity(forEntityName: "CMConversation", in: context)
         let conversation = CMConversation(entity: conversationEntity!, insertInto: context)
         
         conversation.admin                  = item.admin as NSNumber?
         conversation.canEditInfo            = item.canEditInfo as NSNumber?
         conversation.canSpam                = item.canSpam as NSNumber?
         conversation.descriptions           = item.description
         conversation.group                  = item.group as NSNumber?
         conversation.id                     = item.id as NSNumber?
         conversation.image                  = item.image
         conversation.joinDate               = item.joinDate as NSNumber?
         conversation.lastMessage            = item.lastMessage
         conversation.lastParticipantImage   = item.lastParticipantImage
         conversation.lastParticipantName    = item.lastParticipantName
         conversation.lastSeenMessageId      = item.lastSeenMessageId as NSNumber?
         conversation.metadata               = item.metadata
         conversation.mute                   = item.mute as NSNumber?
         conversation.participantCount       = item.participantCount as NSNumber?
         conversation.partner                = item.partner as NSNumber?
         conversation.partnerLastDeliveredMessageId  = item.partnerLastDeliveredMessageId as NSNumber?
         conversation.partnerLastSeenMessageId       = item.partnerLastSeenMessageId as NSNumber?
         conversation.title                  = item.title
         conversation.time                   = item.time as NSNumber?
         conversation.type                   = item.time as NSNumber?
         conversation.unreadCount            = item.unreadCount as NSNumber?
         
         
         let theInviterEntity = NSEntityDescription.entity(forEntityName: "CMParticipant", in: context)
         let theInviter = CMParticipant(entity: theInviterEntity!, insertInto: context)
         theInviter.admin           = item.inviter?.admin as NSNumber?
         theInviter.blocked         = item.inviter?.blocked as NSNumber?
         theInviter.cellphoneNumber = item.inviter?.cellphoneNumber
         theInviter.contactId       = item.inviter?.contactId as NSNumber?
         theInviter.coreUserId      = item.inviter?.coreUserId as NSNumber?
         theInviter.email           = item.inviter?.email
         theInviter.firstName       = item.inviter?.firstName
         theInviter.id              = item.inviter?.id as NSNumber?
         theInviter.image           = item.inviter?.image
         theInviter.lastName        = item.inviter?.lastName
         theInviter.myFriend        = item.inviter?.myFriend as NSNumber?
         theInviter.name            = item.inviter?.name
         theInviter.notSeenDuration = item.inviter?.notSeenDuration as NSNumber?
         theInviter.online          = item.inviter?.online as NSNumber?
         theInviter.receiveEnable   = item.inviter?.receiveEnable as NSNumber?
         theInviter.sendEnable      = item.inviter?.sendEnable as NSNumber?
         conversation.inviter = theInviter
         
         
         let theMessageEntity = NSEntityDescription.entity(forEntityName: "CMMessage", in: context)
         let theMessage = CMMessage(entity: theMessageEntity!, insertInto: context)
         theMessage.delivered    = item.lastMessageVO?.delivered as NSNumber?
         theMessage.editable     = item.lastMessageVO?.editable as NSNumber?
         theMessage.edited       = item.lastMessageVO?.edited as NSNumber?
         theMessage.id           = item.lastMessageVO?.id as NSNumber?
         theMessage.message      = item.lastMessageVO?.message
         theMessage.messageType  = item.lastMessageVO?.messageType
         theMessage.metaData     = item.lastMessageVO?.metaData
         theMessage.ownerId      = item.lastMessageVO?.ownerId as NSNumber?
         theMessage.previousId   = item.lastMessageVO?.previousId as NSNumber?
         theMessage.seen         = item.lastMessageVO?.seen as NSNumber?
         theMessage.threadId     = item.lastMessageVO?.threadId as NSNumber?
         theMessage.time         = item.lastMessageVO?.time as NSNumber?
         theMessage.uniqueId     = item.lastMessageVO?.uniqueId
         //                    theMessage.conversation = item.lastMessageVO?.conversation
         //                    theMessage.forwardInfo  = item.lastMessageVO?.forwardInfo
         //                    theMessage.participant  = item.lastMessageVO?.participant
         //                    theMessage.replyInfo    = item.lastMessageVO?.replyInfo
         conversation.lastMessageVO = theMessage
         
         if let messagParticipants = item.participants {
         var participantArr = [CMParticipant]()
         for part in messagParticipants {
         let theParticipantEntity = NSEntityDescription.entity(forEntityName: "CMParticipant", in: context)
         let theParticipant = CMParticipant(entity: theParticipantEntity!, insertInto: context)
         theParticipant.admin           = part.admin as NSNumber?
         theParticipant.blocked         = part.blocked as NSNumber?
         theParticipant.cellphoneNumber = part.cellphoneNumber
         theParticipant.contactId       = part.contactId as NSNumber?
         theParticipant.coreUserId      = part.coreUserId as NSNumber?
         theParticipant.email           = part.email
         theParticipant.firstName       = part.firstName
         theParticipant.id              = part.id as NSNumber?
         theParticipant.image           = part.image
         theParticipant.lastName        = part.lastName
         theParticipant.myFriend        = part.myFriend as NSNumber?
         theParticipant.name            = part.name
         theParticipant.notSeenDuration = part.notSeenDuration as NSNumber?
         theParticipant.online          = part.online as NSNumber?
         theParticipant.receiveEnable   = part.receiveEnable as NSNumber?
         theParticipant.sendEnable      = part.sendEnable as NSNumber?
         participantArr.append(theParticipant)
         }
         conversation.participants = participantArr
         }
         
         allThreads.append(conversation)
         }
         
         saveContext(subject: "Update CMConversation")
         }
         } catch {
         fatalError("Error on fetching list of CMConversation")
         }
         */
        
    }
    
    
    
    // this function will save (or update) contacts that comes from server, in the Cache.
    public func saveThreadParticipantObjects(whereThreadIdIs threadId: Int, withParticipants participants: [Participant]) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMConversation")
        fetchRequest.predicate = NSPredicate(format: "id == %i", threadId)
        do {
            if let result = try context.fetch(fetchRequest) as? [CMConversation] {
                if (result.count > 0) {
                    for item in participants {
                        if let myCMParticipantObject = updateCMParticipantEntity(withParticipantsObject: item) {
                            
                            result.first!.addToParticipants(myCMParticipantObject)
                            //                                result.first!.participants!.append(myCMParticipantObject)
                            saveContext(subject: "Add/Update CMParticipant in a thread and Update CMConversation")
                            updateThreadParticipantEntity(inThreadId: Int(exactly: result.first!.id!)!, withParticipantId: Int(exactly: item.id!)!)
                        }
                    }
                }
                saveContext(subject: "Update CMConversation after adding/updating new Participant")
            }
        } catch {
            fatalError("Error on getting CMConversation when trying to add/update thread participants")
        }
        
        
        //        for item in participants {
        //            _ = updateCMParticipantEntity(withParticipantsObject: item)
        //        }
        
        /*
         // check if there is any information about Contact that are in the cache,
         // if they has beed there, it we will update that data,
         // otherwise we will create an object and save data on cache
         let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMParticipant")
         do {
         if let result = try context.fetch(fetchRequest) as? [CMParticipant] {
         
         // Part1:
         // find data that are exist in the Cache, (and the response request is containing that). and delete them
         for item in participants {
         for itemInCache in result {
         if let participantId = Int(exactly: itemInCache.id ?? 0) {
         if (participantId == item.id) {
         // the Participant object that we are going to create, is already exist in the Cache
         // to update information in this object:
         // we will delete them first, then we will create it again later
         
         context.delete(itemInCache)
         
         saveContext(subject: "Delete CMParticipant Object")
         }
         }
         
         }
         }
         
         
         // Part2:
         // save data comes from server to the Cache
         var allParticipants = [CMParticipant]()
         
         for item in participants {
         let theParticipantEntity = NSEntityDescription.entity(forEntityName: "CMParticipant", in: context)
         let theParticipant = CMParticipant(entity: theParticipantEntity!, insertInto: context)
         
         theParticipant.admin           = item.admin as NSNumber?
         theParticipant.blocked         = item.blocked as NSNumber?
         theParticipant.cellphoneNumber = item.cellphoneNumber
         theParticipant.contactId       = item.contactId as NSNumber?
         theParticipant.coreUserId      = item.coreUserId as NSNumber?
         theParticipant.email           = item.email
         theParticipant.firstName       = item.firstName
         theParticipant.id              = item.id as NSNumber?
         theParticipant.image           = item.image
         theParticipant.lastName        = item.lastName
         theParticipant.myFriend        = item.myFriend as NSNumber?
         theParticipant.name            = item.name
         theParticipant.notSeenDuration = item.notSeenDuration as NSNumber?
         theParticipant.online          = item.online as NSNumber?
         theParticipant.receiveEnable   = item.receiveEnable as NSNumber?
         theParticipant.sendEnable      = item.sendEnable as NSNumber?
         
         allParticipants.append(theParticipant)
         }
         
         saveContext(subject: "Update ThreadParticipants")
         
         }
         } catch {
         fatalError("Error on fetching list of CMConversation")
         }
         */
        
    }
    
    
    // this function will save (or update) messages that comes from server, in the Cache.
    public func saveMessageObjects(messages: [Message], getHistoryParams: JSON?) {
        
        if let params       = getHistoryParams {
            let count       = params["count"].intValue
            let offset      = params["offset"].intValue
            let id          = params["id"].int
            let fromTime    = params["fromTime"].uInt
            let toTime      = params["toTime"].uInt
            let order       = params["order"].string
            let query       = params["query"].string
            let threadId    = params["threadId"].int
            //            let uniqueId    = params["uniqueId"].string
            
            switch (count, offset, id, fromTime, toTime, order, query, messages.count) {
            
            
                /*
                 * 
                 *
                 */
            // 1- delete everything from cache
            case (count, 0, .none, .none, .none, _, .none, 0):
                deleteMessage(count: nil, fromTime: nil, messageId: nil, offset: offset, order: order ?? Ordering.descending.rawValue, query: nil, threadId: threadId, toTime: nil, uniqueId: nil)
                
            // 2- delete all records that:     'time' > 'time' (first cache result)
            case (count, offset, .none, .none, .none, Ordering.ascending.rawValue, .none, 0):
                var firstObject: Message?
                let fetchRequest = retrieveMessageHistoryFetchRequest(firstMessageId: nil, fromTime: nil, messageId: nil, lastMessageId: nil, order: nil, query: nil, threadId: threadId, toTime: nil, uniqueId: nil)
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
                        deleteMessage(count: nil, fromTime: firstObjectTime, messageId: nil, offset: offset, order: Ordering.ascending.rawValue, query: nil, threadId: threadId, toTime: nil, uniqueId: nil)
                    }
                }
                
                
            // 3- delete all records that:     'time' < 'time' (first cache result)
            case (count, offset, .none, .none, .none, Ordering.descending.rawValue, .none, 0):
                var lastObject: Message?
                let fetchRequest = retrieveMessageHistoryFetchRequest(firstMessageId: nil, fromTime: nil, messageId: nil, lastMessageId: nil, order: nil, query: nil, threadId: threadId, toTime: nil, uniqueId: nil)
                do {
                    if let result = try context.fetch(fetchRequest) as? [Message] {
                        if result.count > 0 {
                            lastObject = result.last!
                        }
                    }
                } catch {
                    fatalError()
                }
                if let lObject = lastObject {
                    if let lastObjectTime = lObject.time {
                        deleteMessage(count: nil, fromTime: nil, messageId: nil, offset: offset, order: Ordering.descending.rawValue, query: nil, threadId: threadId, toTime: lastObjectTime, uniqueId: nil)
                    }
                }
                
                
                //Server result is not Empty, so we should remove everything which are between firstMessage and lastMessage of this result from cache database and insert the new result into cache, so the deleted ones would be deleted
                
                
                // Offset has been set as 0 so this result is either the very beggining part of thread or the very last Depending on the sort order.
                // 6: Results are sorted ASC, and the offet is 0, so the first Messasge of this result is first Message of thread, everything in cache database which has smaller time than this one should be removed
                //  delete all records that::   'time' < result.first.time
            // delete every message between result.first and result.last from cache + then add new messages to the database
            case (count, 0, .none, .none, .none, Ordering.ascending.rawValue, .none, _):
                deleteMessage(count: nil, fromTime: nil, messageId: nil, offset: 0, order: Ordering.ascending.rawValue, query: nil, threadId: threadId, toTime: messages.first!.time!, uniqueId: nil)
                deleteMessage(count: nil, fromTime: messages.first!.time!, messageId: nil, offset: 0, order: Ordering.ascending.rawValue, query: nil, threadId: threadId, toTime: messages.last!.time!, uniqueId: nil)
                
                // 7: Results are sorted DESC and the offset is 0, so the last Message of this result is the last Message of the thread, everything in cache database which has bigger time than this one should be removed from cache
                //  delete all records that::   'time' > result.last.time
            // delete every message between result.first and result.last from cache + then add new messages to the database
            case (count, 0, .none, .none, .none, Ordering.descending.rawValue, .none, _):
                deleteMessage(count: nil, fromTime: messages.last!.time!, messageId: nil, offset: 0, order: Ordering.descending.rawValue, query: nil, threadId: threadId, toTime: nil, uniqueId: nil)
                deleteMessage(count: nil, fromTime: messages.first!.time!, messageId: nil, offset: 0, order: Ordering.descending.rawValue, query: nil, threadId: threadId, toTime: messages.last!.time!, uniqueId: nil)
                
                
                // 4- (result.last.previousId = nil) => delete all recored befor the result.last
            // delete every message between result.first and result.last from cache + then add new messages to the database
            case (count, offset, .none, .none, .none, Ordering.ascending.rawValue, .none, _):
                if (messages.last!.previousId == nil) {
                    deleteMessage(count: nil, fromTime: nil, messageId: nil, offset: 0, order: Ordering.ascending.rawValue, query: nil, threadId: threadId, toTime: messages.last!.time!, uniqueId: nil)
                }
                deleteMessage(count: nil, fromTime: messages.first!.time!, messageId: nil, offset: 0, order: Ordering.ascending.rawValue, query: nil, threadId: threadId, toTime: messages.last!.time!, uniqueId: nil)
                
                // 5- if (result.first.previousId = nil) => delete all recored befor the result.first
            // delete every message between result.first and result.last from cache + then add new messages to the database
            case (count, offset, .none, .none, .none, Ordering.descending.rawValue, .none, _):
                if (messages.last!.previousId == nil) {
                    deleteMessage(count: nil, fromTime: nil, messageId: nil, offset: 0, order: Ordering.descending.rawValue, query: nil, threadId: threadId, toTime: messages.last!.time!, uniqueId: nil)
                }
                deleteMessage(count: nil, fromTime: messages.first!.time!, messageId: nil, offset: 0, order: Ordering.descending.rawValue, query: nil, threadId: threadId, toTime: messages.last!.time!, uniqueId: nil)
                
                
            // whereClasue is not empty and we should check for every single one of the conditions to update the cache properly
            case let (count, offset, id, from, to, order, query, result):
                // When user ordered a message with exact ID and server returns [] but there is something in cache database, we should delete that row from cache, because it has been deleted
                if let myId = id {
                    if result == 0 {
                        // delete the message with 'id' from cache
                        deleteMessage(count: nil, fromTime: nil, messageId: myId, offset: 0, order: order ?? Ordering.descending.rawValue, query: nil, threadId: threadId, toTime: nil, uniqueId: nil)
                    }
                }
                
                // When user sets a query to search on messages we should delete all the results came from cache and insert new results instead, because those messages would be either removed or updated
                if let myQuery = query {
                    // delete result of the cache + then add new result to the cache
                    deleteMessage(count: nil, fromTime: nil, messageId: nil, offset: 0, order: order ?? Ordering.descending.rawValue, query: myQuery, threadId: threadId, toTime: nil, uniqueId: nil)
                }
                
                /*
                 User set both fromTime and toTime, so we have a boundry restriction in this case.
                 if server result is empty, we should delete all messages from cache which are between fromTime and toTime.
                 if there are any messages on server in this boundry, we should delete all messages which are between time of first and last message of the server result, from cache and insert new result into cache.
                 */
                if (from != nil) || (to != nil) {
                    
                    // Server response is Empty []
                    if result == 0 {
                        
                        if (from != nil) && (to != nil) {
                            deleteMessage(count: nil, fromTime: from, messageId: nil, offset: 0, order: order ?? Ordering.descending.rawValue, query: nil, threadId: threadId, toTime: to, uniqueId: nil)
                            
                        } else if let fromTime = from {
                            deleteMessage(count: nil, fromTime: fromTime, messageId: nil, offset: 0, order: order ?? Ordering.descending.rawValue, query: nil, threadId: threadId, toTime: nil, uniqueId: nil)
                            
                        } else if let toTime = to {
                            deleteMessage(count: nil, fromTime: nil, messageId: nil, offset: 0, order: order ?? Ordering.descending.rawValue, query: nil, threadId: threadId, toTime: toTime, uniqueId: nil)
                        }
                        
                    }
                        
                        // Server response is not Empty [..., n-1, n, n+1, ...]
                    else {
                        deleteMessage(count: count, fromTime: from, messageId: nil, offset: offset, order: order ?? Ordering.descending.rawValue, query: nil, threadId: threadId, toTime: to, uniqueId: nil)
                    }
                    
                }
                
                
            }
            
            
            
        }
        
        // now insert server result in the cache
        for item in messages {
            _ = updateCMMessageEntity(withMessageObject: item)
        }
        
        
        
        /*
         // check if there is any information about Messages that are in the cache,
         // which if it has been there, it we will update that data,
         // otherwise we will create an object and save data on cache
         let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMMessage")
         do {
         if let result = try context.fetch(fetchRequest) as? [CMMessage] {
         
         // Part1:
         // find data that are exist in the Cache, (and the response request is containing that). and delete them
         for item in messages {
         for itemInCache in result {
         if let messageId = Int(exactly: itemInCache.id ?? 0) {
         if (messageId == item.id) {
         // the message object that we are going to create, is already exist in the Cache
         // to update information in this object:
         // we will delete them first, then we will create it again later
         
         itemInCache.conversation = nil
         itemInCache.forwardInfo?.conversation = nil
         itemInCache.forwardInfo?.participant = nil
         itemInCache.forwardInfo = nil
         itemInCache.participant = nil
         itemInCache.replyInfo?.participant = nil
         itemInCache.replyInfo = nil
         context.delete(itemInCache)
         
         saveContext(subject: "Delete CMMessage Object")
         }
         }
         
         }
         }
         
         // Part2:
         // save data comes from server to the Cache
         var allMessages = [CMMessage]()
         
         for item in messages {
         let messageEntity = NSEntityDescription.entity(forEntityName: "CMMessage", in: context)
         let message = CMMessage(entity: messageEntity!, insertInto: context)
         
         message.delivered   = item.delivered as NSNumber?
         message.edited      = item.edited as NSNumber?
         message.id          = item.id as NSNumber?
         message.message     = item.message
         message.messageType = item.messageType
         message.metaData    = item.metaData
         message.ownerId     = item.ownerId as NSNumber?
         message.previousId  = item.previousId as NSNumber?
         message.seen        = item.seen as NSNumber?
         message.threadId    = item.threadId as NSNumber?
         message.time        = item.time as NSNumber?
         message.uniqueId    = item.uniqueId
         
         
         let theConversationEntity = NSEntityDescription.entity(forEntityName: "CMConversation", in: context)
         let theConversation = CMConversation(entity: theConversationEntity!, insertInto: context)
         theConversation.admin                   = item.conversation?.admin as NSNumber?
         theConversation.canEditInfo             = item.conversation?.canEditInfo as NSNumber?
         theConversation.canSpam                 = item.conversation?.canSpam as NSNumber?
         theConversation.descriptions            = item.conversation?.description
         theConversation.group                   = item.conversation?.group as NSNumber?
         theConversation.id                      = item.conversation?.id as NSNumber?
         theConversation.image                   = item.conversation?.image
         theConversation.joinDate                = item.conversation?.joinDate as NSNumber?
         theConversation.lastMessage             = item.conversation?.lastMessage
         theConversation.lastParticipantImage    = item.conversation?.lastParticipantImage
         theConversation.lastParticipantName     = item.conversation?.lastParticipantName
         theConversation.lastSeenMessageId       = item.conversation?.lastSeenMessageId as NSNumber?
         theConversation.metadata                = item.conversation?.metadata
         theConversation.mute                    = item.conversation?.mute as NSNumber?
         theConversation.participantCount        = item.conversation?.participantCount as NSNumber?
         theConversation.partner                 = item.conversation?.partner as NSNumber?
         theConversation.partnerLastDeliveredMessageId   = item.conversation?.partnerLastDeliveredMessageId as NSNumber?
         theConversation.partnerLastSeenMessageId        = item.conversation?.partnerLastSeenMessageId as NSNumber?
         theConversation.title                   = item.conversation?.title
         theConversation.time                    = item.conversation?.time as NSNumber?
         theConversation.type                    = item.conversation?.time as NSNumber?
         theConversation.unreadCount             = item.conversation?.unreadCount as NSNumber?
         
         message.conversation = theConversation
         
         
         let theForwardInfoEntity = NSEntityDescription.entity(forEntityName: "CMForwardInfo", in: context)
         let theForwardInfo = CMForwardInfo(entity: theForwardInfoEntity!, insertInto: context)
         let theForwardInfoParticipantEntity = NSEntityDescription.entity(forEntityName: "CMParticipant", in: context)
         let theForwardInfoParticipant = CMParticipant(entity: theForwardInfoParticipantEntity!, insertInto: context)
         theForwardInfoParticipant.admin             = item.forwardInfo?.participant?.admin as NSNumber?
         theForwardInfoParticipant.blocked           = item.forwardInfo?.participant?.blocked as NSNumber?
         theForwardInfoParticipant.cellphoneNumber   = item.forwardInfo?.participant?.cellphoneNumber
         theForwardInfoParticipant.contactId         = item.forwardInfo?.participant?.contactId as NSNumber?
         theForwardInfoParticipant.coreUserId        = item.forwardInfo?.participant?.coreUserId as NSNumber?
         theForwardInfoParticipant.email             = item.forwardInfo?.participant?.email
         theForwardInfoParticipant.firstName         = item.forwardInfo?.participant?.firstName
         theForwardInfoParticipant.id                = item.forwardInfo?.participant?.id as NSNumber?
         theForwardInfoParticipant.image             = item.forwardInfo?.participant?.image
         theForwardInfoParticipant.lastName          = item.forwardInfo?.participant?.lastName
         theForwardInfoParticipant.myFriend          = item.forwardInfo?.participant?.myFriend as NSNumber?
         theForwardInfoParticipant.name              = item.forwardInfo?.participant?.name
         theForwardInfoParticipant.notSeenDuration   = item.forwardInfo?.participant?.notSeenDuration as NSNumber?
         theForwardInfoParticipant.online            = item.forwardInfo?.participant?.online as NSNumber?
         theForwardInfoParticipant.receiveEnable     = item.forwardInfo?.participant?.receiveEnable as NSNumber?
         theForwardInfoParticipant.sendEnable        = item.forwardInfo?.participant?.sendEnable as NSNumber?
         let theForwardInfoConversationEntity = NSEntityDescription.entity(forEntityName: "CMConversation", in: context)
         let theForwardInfoConversation = CMConversation(entity: theForwardInfoConversationEntity!, insertInto: context)
         theForwardInfoConversation.admin                   = item.forwardInfo?.conversation?.admin as NSNumber?
         theForwardInfoConversation.canEditInfo             = item.forwardInfo?.conversation?.canEditInfo as NSNumber?
         theForwardInfoConversation.canSpam                 = item.forwardInfo?.conversation?.canSpam as NSNumber?
         theForwardInfoConversation.descriptions            = item.forwardInfo?.conversation?.description
         theForwardInfoConversation.group                   = item.forwardInfo?.conversation?.group as NSNumber?
         theForwardInfoConversation.id                      = item.forwardInfo?.conversation?.id as NSNumber?
         theForwardInfoConversation.image                   = item.forwardInfo?.conversation?.image
         theForwardInfoConversation.joinDate                = item.forwardInfo?.conversation?.joinDate as NSNumber?
         theForwardInfoConversation.lastMessage             = item.forwardInfo?.conversation?.lastMessage
         theForwardInfoConversation.lastParticipantImage    = item.forwardInfo?.conversation?.lastParticipantImage
         theForwardInfoConversation.lastParticipantName     = item.forwardInfo?.conversation?.lastParticipantName
         theForwardInfoConversation.lastSeenMessageId       = item.forwardInfo?.conversation?.lastSeenMessageId as NSNumber?
         theForwardInfoConversation.metadata                = item.forwardInfo?.conversation?.metadata
         theForwardInfoConversation.mute                    = item.forwardInfo?.conversation?.mute as NSNumber?
         theForwardInfoConversation.participantCount        = item.forwardInfo?.conversation?.participantCount as NSNumber?
         theForwardInfoConversation.partner                 = item.forwardInfo?.conversation?.partner as NSNumber?
         theForwardInfoConversation.partnerLastDeliveredMessageId   = item.forwardInfo?.conversation?.partnerLastDeliveredMessageId as NSNumber?
         theForwardInfoConversation.partnerLastSeenMessageId        = item.forwardInfo?.conversation?.partnerLastSeenMessageId as NSNumber?
         theForwardInfoConversation.title                   = item.forwardInfo?.conversation?.title
         theForwardInfoConversation.time                    = item.forwardInfo?.conversation?.time as NSNumber?
         theForwardInfoConversation.type                    = item.forwardInfo?.conversation?.time as NSNumber?
         theForwardInfoConversation.unreadCount             = item.forwardInfo?.conversation?.unreadCount as NSNumber?
         
         theForwardInfo.participant = theForwardInfoParticipant
         theForwardInfo.conversation = theForwardInfoConversation
         
         message.forwardInfo = theForwardInfo
         
         
         let theParticipantEntity = NSEntityDescription.entity(forEntityName: "CMParticipant", in: context)
         let theParticipant = CMParticipant(entity: theParticipantEntity!, insertInto: context)
         theParticipant.admin            = item.participant?.admin as NSNumber?
         theParticipant.blocked          = item.participant?.blocked as NSNumber?
         theParticipant.cellphoneNumber  = item.participant?.cellphoneNumber
         theParticipant.contactId        = item.participant?.contactId as NSNumber?
         theParticipant.coreUserId       = item.participant?.coreUserId as NSNumber?
         theParticipant.email            = item.participant?.email
         theParticipant.firstName        = item.participant?.firstName
         theParticipant.id               = item.participant?.id as NSNumber?
         theParticipant.image            = item.participant?.image
         theParticipant.lastName         = item.participant?.lastName
         theParticipant.myFriend         = item.participant?.myFriend as NSNumber?
         theParticipant.name             = item.participant?.name
         theParticipant.notSeenDuration  = item.participant?.notSeenDuration as NSNumber?
         theParticipant.online           = item.participant?.online as NSNumber?
         theParticipant.receiveEnable    = item.participant?.receiveEnable as NSNumber?
         theParticipant.sendEnable       = item.participant?.sendEnable as NSNumber?
         message.participant = theParticipant
         
         
         let theReplyInfoEntity = NSEntityDescription.entity(forEntityName: "CMReplyInfo", in: context)
         let theReplyInfo = CMReplyInfo(entity: theReplyInfoEntity!, insertInto: context)
         theReplyInfo.deletedd           = item.replyInfo?.deleted as NSNumber?
         theReplyInfo.repliedToMessageId = item.replyInfo?.repliedToMessageId as NSNumber?
         theReplyInfo.message            = item.replyInfo?.message
         theReplyInfo.messageType        = item.replyInfo?.messageType as NSNumber?
         theReplyInfo.metadata           = item.replyInfo?.metadata
         theReplyInfo.systemMetadata     = item.replyInfo?.systemMetadata
         let theReplyInfoParticipantEntity = NSEntityDescription.entity(forEntityName: "CMParticipant", in: context)
         let theReplyInfoParticipant = CMParticipant(entity: theReplyInfoParticipantEntity!, insertInto: context)
         theReplyInfoParticipant.admin            = item.replyInfo?.participant?.admin as NSNumber?
         theReplyInfoParticipant.blocked          = item.replyInfo?.participant?.blocked as NSNumber?
         theReplyInfoParticipant.cellphoneNumber  = item.replyInfo?.participant?.cellphoneNumber
         theReplyInfoParticipant.contactId        = item.replyInfo?.participant?.contactId as NSNumber?
         theReplyInfoParticipant.coreUserId       = item.replyInfo?.participant?.coreUserId as NSNumber?
         theReplyInfoParticipant.email            = item.replyInfo?.participant?.email
         theReplyInfoParticipant.firstName        = item.replyInfo?.participant?.firstName
         theReplyInfoParticipant.id               = item.replyInfo?.participant?.id as NSNumber?
         theReplyInfoParticipant.image            = item.replyInfo?.participant?.image
         theReplyInfoParticipant.lastName         = item.replyInfo?.participant?.lastName
         theReplyInfoParticipant.myFriend         = item.replyInfo?.participant?.myFriend as NSNumber?
         theReplyInfoParticipant.name             = item.replyInfo?.participant?.name
         theReplyInfoParticipant.notSeenDuration  = item.replyInfo?.participant?.notSeenDuration as NSNumber?
         theReplyInfoParticipant.online           = item.replyInfo?.participant?.online as NSNumber?
         theReplyInfoParticipant.receiveEnable    = item.replyInfo?.participant?.receiveEnable as NSNumber?
         theReplyInfoParticipant.sendEnable       = item.replyInfo?.participant?.sendEnable as NSNumber?
         theReplyInfo.participant = theReplyInfoParticipant
         
         message.replyInfo = theReplyInfo
         
         allMessages.append(message)
         }
         
         saveContext(subject: "Update Messages")
         }
         } catch {
         fatalError("Error on fetching list of CMConversation")
         }
         */
        
    }
    
    
    
    // this function will save (or update) uploaded image response that comes from server, in the Cache.
    public func saveUploadImage(imageInfo: UploadImage, imageData: Data) {
        // check if there is any information about This Image File in the cache
        // if it has some data, it we will update that data,
        // otherwise we will create an object and save data on cache
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMUploadImage")
        do {
            
            if let result = try context.fetch(fetchRequest) as? [CMUploadImage] {
                // if there is a value in this fetch request, it mean that we had already saved This Image info in the Cache.
                // so we just have to update that information with new response that comes from server
                
                // TODO: prevent copy one file in several places in the app - search by the Image file itself through the app bundle
                /*
                 if find sth, check out the information about that file:
                 if the info of both, was the same, just delete the fileInfo from cache, and then save it later
                 if the info was different, just save the new info in the cache and link it to this image file path
                 */
                
                // Part1:
                // find data that are exist in the Cache, (and the response request is containing that). and delete them
                for itemInCache in result {
                    if let imageId = Int(exactly: itemInCache.id ?? 0) {
                        if (imageId == imageInfo.id) {
                            // the uploadImage object that we are going to create, is already exist in the Cache
                            // to update information in this object:
                            // we will delete them first, then we will create it again later
                            
                            // delete the original file from local storage of the app, using path of the file
                            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                            
                            let myFilePath = path + "/\(fileSubPath.Images)/" + "\(imageInfo.id ?? 0)\(imageInfo.name ?? "default.png")"
                            // check if this file is exixt on the app bunde, then delete it
                            if FileManager.default.fileExists(atPath: myFilePath) {
                                do {
                                    try FileManager.default.removeItem(atPath: myFilePath)
                                } catch {
                                    fatalError("can not delete the image from app bundle!")
                                }
                            }
                            
                            // delete the information from cache
                            context.delete(itemInCache)
                            saveContext(subject: "Delete CMUploadImage Object")
                        }
                    }
                }
                
                // Part2:
                // save data comes from server to the Cache
                let theUploadImageEntity = NSEntityDescription.entity(forEntityName: "CMUploadImage", in: context)
                let theUploadImage = CMUploadImage(entity: theUploadImageEntity!, insertInto: context)
                
                theUploadImage.actualHeight = imageInfo.actualHeight as NSNumber?
                theUploadImage.actualWidth  = imageInfo.actualWidth as NSNumber?
                theUploadImage.hashCode     = imageInfo.hashCode
                theUploadImage.height       = imageInfo.height as NSNumber?
                theUploadImage.id           = imageInfo.id as NSNumber?
                theUploadImage.name         = imageInfo.name
                theUploadImage.width        = imageInfo.width as NSNumber?
                
                // save file on app bundle
                //                guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else { return }
                let directoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                let directoryURL = URL(fileURLWithPath: directoryPath)
                do {
                    try imageData.write(to: directoryURL.appendingPathComponent("\(fileSubPath.Images)/\(imageInfo.id ?? 0)\(imageInfo.name ?? "default")"))
                } catch {
                    print(error.localizedDescription)
                }
                
                saveContext(subject: "Update UploadImage")
            }
        } catch {
            fatalError("Error on fetching list of Conversations")
        }
        
    }
    
    
    // this function will save (or update) uploaded image response that comes from server, in the Cache.
    public func saveUploadFile(fileInfo: UploadFile, fileData: Data) {
        // check if there is any information about This Image File in the cache
        // if it has some data, it we will update that data,
        // otherwise we will create an object and save data on cache
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMUploadFile")
        do {
            
            if let result = try context.fetch(fetchRequest) as? [CMUploadFile] {
                // if there is a value in this fetch request, it mean that we had already saved This Image info in the Cache.
                // so we just have to update that information with new response that comes from server
                
                // TODO: prevent copy one file in several places in the app - search by the Image file itself through the app bundle
                /*
                 if find sth, check out the information about that file:
                 if the info of both, was the same, just delete the fileInfo from cache, and then save it later
                 if the info was different, just save the new info in the cache and link it to this image file path
                 */
                
                // Part1:
                // find data that are exist in the Cache, (and the response request is containing that). and delete them
                for itemInCache in result {
                    if let fileId = Int(exactly: itemInCache.id ?? 0) {
                        if (fileId == fileInfo.id) {
                            // the uploadFile object that we are going to create, is already exist in the Cache
                            // to update information in this object:
                            // we will delete them first, then we will create it again later
                            
                            // delete the original file from local storage of the app, using path of the file
                            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                            let myFilePath = path + "/\(fileSubPath.Files)/" + "\(fileInfo.id ?? 0)\(fileInfo.name ?? "default")"
                            
                            if FileManager.default.fileExists(atPath: myFilePath) {
                                do {
                                    try FileManager.default.removeItem(atPath: myFilePath)
                                } catch {
                                    fatalError("can not delete the image from app bundle!")
                                }
                            }
                            
                            // delete the information from cache
                            context.delete(itemInCache)
                            saveContext(subject: "Delete CMUploadFile Object")
                        }
                    }
                }
                
                // Part2:
                // save data comes from server to the Cache
                let theUploadFileEntity = NSEntityDescription.entity(forEntityName: "CMUploadFile", in: context)
                let theUploadFile = CMUploadFile(entity: theUploadFileEntity!, insertInto: context)
                
                theUploadFile.hashCode      = fileInfo.hashCode
                theUploadFile.id            = fileInfo.id as NSNumber?
                theUploadFile.name          = fileInfo.name
                
                // save file on app bundle
                let directoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                let directoryURL = URL(fileURLWithPath: directoryPath)
                do {
                    try fileData.write(to: directoryURL.appendingPathComponent("\(fileSubPath.Files)/\(fileInfo.id ?? 0)\(fileInfo.name ?? "default")"))
                } catch {
                    print(error.localizedDescription)
                }
                
                saveContext(subject: "Update UploadFile")
            }
        } catch {
            fatalError("Error on fetching list of Conversations")
        }
        
    }
    
    
    
    
}
