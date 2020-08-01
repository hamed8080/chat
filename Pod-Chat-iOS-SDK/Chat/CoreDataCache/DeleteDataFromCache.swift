//
//  DeleteDataFromCache.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 3/18/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import CoreData


// MARK: - Functions that will delete data frome CoreData Cache

extension Cache {
    
    // MARK: - delete UserInfo:
    /// Delete UserInfo:
    /// by calling this method, it will delete the CMUser that had been saved on the cache
    ///
    /// - it fetches CMUser
    /// - iterate throut all CMUser objects inside the cache, and delete them one by one. (it actualy has only one CMUser object!)
    ///
    /// Inputs:
    /// it has no params as input
    ///
    /// Outputs:
    /// it returns no output
    ///
    /// - parameters:
    ///     - isCompleted:  a closure callback that is specified if this deletion is completed or not. (it's actually an output)
    ///
    /// - Returns:
    ///     none
    ///
    public func deleteUserInfo(isCompleted: (()->())?) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMUser")
        do {
            if let result = try context.fetch(fetchRequest) as? [CMUser] {
                for user in result {
                    deleteAndSave(object: user, withMessage: "CMUser Deleted.")
                }
                isCompleted?()
            } else {
                isCompleted?()
            }
        } catch {
            isCompleted?()
            fatalError("cannot fetch CMUser, when trying to delete CMUser")
        }
    }
    
    
    
    // MARK: - delete Contacts:
    /// Delete Contacts by ContactIds:
    /// by calling this method, it will delete the CMContact that had been saved on the cache
    ///
    /// - loop through the items inside the contactIs input
    /// - make them or together to create the OrPredicate
    /// - fetch the CMContact with the use of the oePredicate that we created earlier
    /// - loop through the result ([CMContact])
    ///     - try to delete the LikedUser (if there was any Contact that has this LinkedUser, this deletion will not work)
    ///     - delete the contact from Cache
    ///
    /// Inputs:
    /// it gets an array of contactIds to delete them
    ///
    /// Outputs:
    /// it returns no output
    ///
    /// - parameters:
    ///     - withContactIds:   contactId to delete them. ([Int])
    ///
    /// - Returns:
    ///     none
    ///
    public func deleteContact(withContactIds contactIds: [Int])  {
        var orPredicatArray = [NSPredicate]()
        for item in contactIds {
            orPredicatArray.append(NSPredicate(format: "id == %i", item))
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMContact")
        let predicateCompound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: orPredicatArray)
        fetchRequest.predicate = predicateCompound
        do {
            if let result = try context.fetch(fetchRequest) as? [CMContact] {
                for contact in result {
                    if let _ = contact.linkedUser {
                        deleteAndSave(object: contact.linkedUser!, withMessage: "Delete CMLinkedUser Object")
                    }
                    deleteAndSave(object: contact, withMessage: "Delete CMContact Object")
                }
                saveContext(subject: "Update CMContact")
            }
        } catch {
            fatalError("Error on fetching list of CMContact when trying to delete contact...")
        }
    }
    
    
    
    /// Delete Contacts by TimeStamp:
    /// by calling this method, it will delete the CMContact that had not been updated for specific timeStamp.
    ///
    /// - get the current time
    /// - decrease it with the timeStamp input and create a new time
    /// - fetch CMContact Entity where object that has lesser time value than this new time that we generated
    /// - loop through the result and get the object Ids
    /// - if there was more than 1 value of objectIds,
    /// - send the objectIds to the 'deleteContact(withContactIds: [Int])' to delete these contacts
    ///
    /// Inputs:
    /// it gets the timeStamp as "Int" to delete Contacts that has not been updated for this amount of time
    ///
    /// Outputs:
    /// it returns no output
    ///
    /// - parameters:
    ///     - byTimeStamp:  declear the seconds to delete contacts that has not updated for this amount of time. (Int)
    ///
    /// - Returns:
    ///     none
    ///
    func deleteContacts(byTimeStamp timeStamp: Int) {
        let currentTime = Int(Date().timeIntervalSince1970)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMContact")
        fetchRequest.predicate = NSPredicate(format: "time <= %i", Int(currentTime - timeStamp))
        do {
            if let result = try context.fetch(fetchRequest) as? [CMContact] {
                var contactIds: [Int] = []
                for item in result {
                    contactIds.append((item.id! as? Int)!)
                }
                if contactIds.count > 0 {
                    deleteContact(withContactIds: contactIds)
                }
            }
        } catch {
            fatalError("Error on fetching CMContact when trying to delete object based on timeStamp")
        }
    }
    
    
    
    // MARK: - delete Participants:
    /// Delete Participants by their ParticipantsIds on a specific thread:
    /// by calling this method, it will delete the CMParticipant that had not been updated for specific timeStamp.
    ///
    /// Inputs:
    /// it gets the threadId as "Int" and an array of 'participantsId' to delete them
    ///
    /// Outputs:
    /// it returns no output
    ///
    /// - parameters:
    ///     - inThread:             specify the threadId that want to delete participants from it. (Int)
    ///     - withParticipantIds:   participantIds to delete them. ([Int])
    ///
    /// - Returns:
    ///     none
    ///
    public func deleteParticipant(inThread: Int, withParticipantIds participantIds: [Int]) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMParticipant")
        fetchRequest.predicate = NSPredicate(format: "threadId == %i", inThread)
        do {
            if let result = try context.fetch(fetchRequest) as? [CMParticipant] {
                if (result.count > 0) {
                    for (index, participant) in result.enumerated() {
                        for id in participantIds {
                            if (Int(exactly: participant.id ?? 0) == id) {
                                deleteAndSave(object: result[index], withMessage: "Delete CMParticipant Object from Cache")
                            }
                        }
                    }
                }
                saveContext(subject: "Update CMParticipant")
            }
        } catch {
            fatalError("Error on fetching list of CMParticipant when trying to delete some Participant from it")
        }
    }
    
    
    // ToDo:
    // this function should be deleted because another service that gives all threads, can handel deletion the threads
    // so there is no longer needs to this function!!!!!
    // delete objects that has been not updated for "timeStamp" seconds
    
    /// Delete Participants by TimeStamp on a specific thread:
    /// by calling this method, it will delete the CMParticipant that had not been updated for specific timeStamp.
    ///
    /// Inputs:
    /// - it gets the threadId as "Int" and timeStamp as "Int" to delete Participats that has not been updated for this amount of time
    ///
    /// Outputs:
    /// - it returns no output
    ///
    /// - parameters:
    ///     - inThread:       specify the threadId that want to delete participants from it. (Int)
    ///     - byTimeStamp:    declear the seconds to delete participants that has not updated for this amount of time. (Int)
    ///
    /// - Returns:
    ///     none
    ///
    func deleteThreadParticipants(inThread: Int, byTimeStamp: Int) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMParticipant")
        let currentTime = Int(Date().timeIntervalSince1970)
        let xTime = Int(currentTime - byTimeStamp)
        fetchRequest.predicate = NSPredicate(format: "threadId == %i", inThread)
        do {
            if let result = try context.fetch(fetchRequest) as? [CMParticipant] {
                if result.count > 0 {
                    for (index, participant) in result.enumerated() {
                        if ((participant.time as! Int) <= xTime) {
                            deleteAndSave(object: result[index], withMessage: "Delete CMParticipant Object from Thread")
                        }
                    }
                }
            }
        } catch {
            fatalError("Error on fetching CMParticipant when trying to delete object based on timeStamp")
        }
    }
    
    
    // MARK: - delete Threads:
    /// Delete Threads by their ThreadIds:
    /// by calling this method, we will delete specific CMConversation
    ///
    /// - loop through the items inside the 'threadIds' input
    /// - make them or together to create the orPredicate
    /// - fetch the CMConversation with the use of the orPredicate that we created earlier
    /// - loop through the result ([CMConversation])
    ///     - delete all Message inside this thread
    ///     - delete object thread participants from Cache
    ///     - delete inviter participant from cache
    ///     - delete lastMessage object from cache
    ///     - delete all Messages inside this thread
    ///
    /// Inputs:
    /// it gets the threadIds as "[Int]" to delete them
    ///
    /// Outputs:
    /// it returns no output
    ///
    /// - parameters:
    ///     - withThreadIds:    specify the threadIds that want to delete them. ([Int])
    ///
    /// - Returns:
    ///     none
    ///
    public func deleteThreads(withThreadIds threadIds: [Int]) {
        var orPredicatArray = [NSPredicate]()
        for item in threadIds {
            orPredicatArray.append(NSPredicate(format: "id == %i", item))
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMConversation")
        let predicateCompound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: orPredicatArray)
        fetchRequest.predicate = predicateCompound
        do {
            if let result = try context.fetch(fetchRequest) as? [CMConversation] {
                for (threadIndex, thread) in result.enumerated() {
                    if let _ = thread.inviter {
                        result[threadIndex].removeFromParticipants(thread.inviter!)
                        deleteAndSave(object: thread.inviter!, withMessage: "Delete CMParticipant Object")
                    }
                    if let _ = thread.lastMessageVO {
                        deleteAndSave(object: thread.lastMessageVO!, withMessage: "Delete CMMessage Object")
                    }
                    if let _ = thread.pinMessage {
                        deleteAndSave(object: thread.pinMessage!, withMessage: "Delete pinMessage from CMPinMessage Object")
                    }
                    deleteMessage(inThread: (thread.id as? Int)!, allMessages: true, withMessageIds: [])
                    deleteAndSave(object: thread, withMessage: "Delete CMConversation Object")
                }
                saveContext(subject: "Update CMConversation")
            }
        } catch {
            fatalError("Error on fetching list of CMConversation when trying to delete Threads...")
        }
    }
    
    // MARK: - delete Pin/Unpin Message from Thread:
    /// Unpin Message from CMMessage and CMConversation Entities:
    /// by calling this function, 'pinMessage' property on Conversation will be delete, and the 'pinned' property on the Message will be false
    ///
    /// Inputs:
    /// it gets the threadId as  "Int"  as input
    ///
    /// Outputs:
    /// it returns no output
    ///
    /// - parameters:
    ///     - threadId:     id of the thread to delete the pin message.(Int)
    ///
    /// - Returns:
    ///     none
    ///
    func deletePinMessage(threadId: Int) {
        if let msgId = deletePinMessageFromCMConversationEntity(threadId: threadId) {
            deletePinMessageFromCMMessageEntity(messageId: msgId)
        }
    }
    
    /// Unpin Message from CMConversation Entity:
    /// by calling this function, 'pinMessage' property on Conversation will be delete.
    ///
    /// Inputs:
    /// it gets the threadId as  "Int"  as input
    ///
    /// Outputs:
    /// it returns no output
    ///
    /// - parameters:
    ///     - threadId:     id of the thread to delete the pin message.(Int)
    ///
    /// - Returns:
    ///     none
    ///
    func deletePinMessageFromCMConversationEntity(threadId: Int) -> Int? {
        var msgId: Int?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMConversation")
        fetchRequest.predicate = NSPredicate(format: "id == %i", threadId)
        do {
            if let result = try context.fetch(fetchRequest) as? [CMConversation] {
                if (result.count > 0) {
                    msgId = Int(exactly: result.first!.pinMessage?.messageId ?? 0)
                    result.first!.pinMessage = nil
                    saveContext(subject: "Update CMConversation on delete PinMessage -update existing object-")
                }
            }
        } catch {
            fatalError("Error on trying to find the Thread from CMConversation entity")
        }
        return msgId
    }
    
    /// Unpin Message from CMMessage Entity:
    /// by calling this function, 'pinMessage' property on Message will be delete.
    ///
    /// Inputs:
    /// it gets the messageId as  "Int"  as input
    ///
    /// Outputs:
    /// it returns no output
    ///
    /// - parameters:
    ///     - messageId:    id of the message to delete the pin value.(Int)
    ///
    /// - Returns:
    ///     none
    ///
    func deletePinMessageFromCMMessageEntity(messageId: Int) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMMessage")
        fetchRequest.predicate = NSPredicate(format: "id == %i", messageId)
        do {
            if let result = try context.fetch(fetchRequest) as? [CMMessage] {
                if (result.count > 0) {
                    result.first!.pinned = false as NSNumber
                    saveContext(subject: "Update CMMessage on delete PinMessage -update existing object-")
                }
            }
        } catch {
            fatalError("Error on trying to find the Thread from CMMessage entity")
        }
    }
    
    /// Unpin All Pinned Messages from CMMessage Entity:
    /// by calling this function, 'pinMessage' property on Message will be delete.
    ///
    /// Inputs:
    /// it gets the threadId as  "Int"  as input
    ///
    /// Outputs:
    /// it returns no output
    ///
    /// - parameters:
    ///     - onThreadId:   id of the thread to delete the pin value.(Int)
    ///
    /// - Returns:
    ///     none
    ///
    func deleteAllPinMessageFromCMMessageEntity(onThreadId: Int) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMMessage")
        var predicateArray = [NSPredicate]()
        predicateArray.append(NSPredicate(format: "threadId == %i", onThreadId))
        predicateArray.append(NSPredicate(format: "pinned == %@", true as NSNumber))
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicateArray)
        do {
            if let result = try context.fetch(fetchRequest) as? [CMMessage] {
                for item in result {
                    item.pinned = false as NSNumber
                }
                saveContext(subject: "Update CMMessage on delete AllPinMessage")
            }
        } catch {
            fatalError("Error on trying to find the Thread from CMMessage entity")
        }
    }
    
    
    // MARK: - delete Messages:
    // ToDo: make it better, because it calls another function to delete messages (one more query on the cache)
    /// Delete Message:
    /// by calling this method, we will delete specific CMMessages
    ///
    /// Inputs:
    /// it gets some parameters to retireave Messages from Cache based on this params, and then delete them
    ///
    /// Outputs:
    /// it returns no output
    ///
    /// - parameters:
    ///     - count:        how many Messages do you spect to delete (Int)
    ///     - fromTime:     filter the messages that sends after this time.
    ///     - messageId:    if you want to search specific message with its messageId, fill this parameter
    ///     - offset:       from what offset do you want to get the Cache response (Int)
    ///     - order:        on what order do you want to get the response? "asc" or "desc". (String?)
    ///     - query:        if you want to search a specific term on the messages, fill this parameter. (String?)
    ///     - threadIds:    do you want to search messages on what threadId. (Int)
    ///     - fromTime:     filter the messages that sends before this time
    ///     - uniqueId:     if you want to search specific message with its uniqueId, fill this parameter
    ///
    /// - Returns:
    ///     none
    ///
    public func deleteMessage(count:    Int?,
                              fromTime: UInt?,
                              messageId: Int?,
                              offset:   Int,
                              order:    String,
                              query:    String?,
                              threadId: Int?,
                              toTime:   UInt?,
                              uniqueId: String?) {
        let fetchRequest = retrieveMessageHistoryFetchRequest(fromTime:         fromTime,
                                                              messageId:        messageId,
                                                              messageType:      nil,
                                                              order:            order,
                                                              query:            query,
                                                              threadId:         threadId,
                                                              toTime:           toTime,
                                                              uniqueIds:        (uniqueId != nil) ? [uniqueId!] : nil)
        do {
            if let result = try context.fetch(fetchRequest) as? [CMMessage] {
                
                switch (count) {
                case let .some(count):
                    var insideCount = 0
                    for (index, item) in result.enumerated() {
                        if (index >= offset) && (insideCount < count) {
                            
                            deleteMessage(inThread:         Int(exactly: threadId ?? 0) ?? 0,
                                          allMessages:      false,
                                          withMessageIds:   [Int(exactly: item.id ?? 0) ?? 0])
                            insideCount += 1
                        }
                    }
                case .none:
                    for item in result {
                        deleteMessage(inThread:         Int(exactly: threadId ?? 0) ?? 0,
                                      allMessages:      false,
                                      withMessageIds:   [Int(exactly: item.id ?? 0) ?? 0])
                    }
                    
                }
            }
            
        } catch {
            fatalError("Error on fetching list of CMMessage")
        }
    }
    
    
    /// Delete Message on specific thread:
    /// by calling this method, we will delete CMMessages on specific Thread
    ///
    /// - define a method that will handle of deletion of messages
    ///     - delete the participant object of the message
    ///     - delete the conversation object of the message
    ///     - delete the replyInfo object of the message
    ///     - delete the forwardInfo object of the message
    ///     - delete the message object itself
    /// - fetch through al CMMessage that its threadId is equal to 'inThread' input
    ///     - if user wants to delete all messages ('allMessages' = 'true'), call the method to delete all messages
    ///     - else, get the 'messageIds' input, and delete them from cache
    /// - delete this messages from MessageGap Entity (if exists)
    ///
    /// Inputs:
    /// it gets some parameters to retireave Messages from Cache based on this params, and then delete them
    ///
    /// Outputs:
    /// it returns no output
    ///
    /// - parameters:
    ///     - inThread:         the threadId that you want to delete messages from it. (Int)
    ///     - allMessages:      if you want to delete all messages on this thread, send this param as "true". (Bool)
    ///     - withMessageIds:   if you want to delete specifice messages with their Ids, send them to this param. ([Int])
    ///
    /// - Returns:
    ///     none
    ///
    public func deleteMessage(inThread: Int, allMessages: Bool, withMessageIds messageIds: [Int]?) {
        func deleteCMMessage(message: CMMessage) {
            if let _ = message.participant {
                deleteAndSave(object: message.participant!, withMessage: "Delete participant from CMMessage Object")
            }
            if let _ = message.replyInfo {
                deleteAndSave(object: message.replyInfo!, withMessage: "Delete replyInfo from CMMessage Object")
            }
            if let _ = message.forwardInfo {
                deleteAndSave(object: message.forwardInfo!, withMessage: "Delete forwardInfo from CMMessage Object")
            }
            deleteAndSave(object: message, withMessage: "Delete CMMessage Object")
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMMessage")
        fetchRequest.predicate = NSPredicate(format: "threadId == %i", inThread)
        do {
            if let result = try context.fetch(fetchRequest) as? [CMMessage] {
                for message in result {
                    
                    if allMessages {
                        deleteCMMessage(message: message)
                    } else if let theMessageIds = messageIds {
                        for msgId in theMessageIds {
                            if (Int(exactly: message.id ?? 0) == msgId) {
                                deleteCMMessage(message: message)
                            }
                        }
                    }
                    
                }
                saveContext(subject: "Update CMMessage")
            }
        } catch {
            fatalError("Error on fetching list of CMMessage when trying to delete")
        }
        
        deleteThread(withThreadId: inThread) {
        }
        
        if allMessages {
            deleteAllMessageGaps(inThreadId: inThread)
        } else {
            updateAllMessageGapEntity(inThreadId: inThread)
        }
        
        
    }
    
    
    
    // MARK: - delete MessageGaps:
    /// Delete MessageGaps:
    /// by calling this method, we will delete MessageGaps
    ///
    /// - fetch from 'MessageGaps' Entity with 'threadId' and 'messageId' Inputs
    /// - if we found any object, we will delete it
    ///
    /// Inputs:
    /// it gets some the threadId that we want to delete all its MessageGaps
    ///
    /// Outputs:
    /// it returns no output
    ///
    /// - parameters:
    ///     - inThread:     the threadId that you want to delete messageGapes from it. (Int)
    ///
    /// - Returns:
    ///     none
    ///
    func deleteAllMessageGaps(inThreadId threadId: Int) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MessageGaps")
        fetchRequest.predicate = NSPredicate(format: "threadId == %i", threadId)
        do {
            if let result = try context.fetch(fetchRequest) as? [MessageGaps] {
                for gap in result {
                    deleteAndSave(object: gap, withMessage: "Delete gap from MessageGap Object")
                }
            }
        } catch {
            fatalError("Error on trying to find MessageGaps")
        }
        
    }
    
    
    
    // MARK: Delete All Contacts
    
    /// Delete All Contacts:
    /// by calling this method, it will Remove all Contacts and LinkeUsers From CacheDB.
    ///
    /// Inputs:
    /// it gets no parameters as input
    ///
    /// Outputs:
    /// it returns no output
    ///
    /// - parameters:
    ///     none
    ///
    /// - Returns:
    ///     none
    ///
    public func deleteAllContacts(isCompleted: @escaping ()->()) {
        deleteContacts {
            self.deleteLinkedUsers {
                isCompleted()
            }
        }
    }
    
    
    /// Delete Contacts:
    /// by calling this method, it will just Remove Contacts From CacheDB.
    ///
    /// - fetch all CMContact
    /// - loop through the contacts
    ///     - delete their object linkedUser
    ///     - delete the object itself
    ///
    /// Inputs:
    /// it gets no parameters as input
    ///
    /// Outputs:
    /// it returns no output
    ///
    /// - parameters:
    ///     none
    ///
    /// - Returns:
    ///     none
    ///
    func deleteContacts(isCompleted: (()->())?) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMContact")
        do {
            if let result = try context.fetch(fetchRequest) as? [CMContact] {
                for contact in result {
                    if let _ = contact.linkedUser {
                        deleteAndSave(object: contact.linkedUser!, withMessage: "CMLinkedUser Deleted")
                    }
                    deleteAndSave(object: contact, withMessage: "CMContact Deleted")
                }
                isCompleted?()
            } else {
                isCompleted?()
            }
        } catch {
            isCompleted?()
            fatalError()
        }
    }
    
    
    /// Delete PhoneBook Contacts:
    /// by calling this method, it will just Remove PhoneBook Contacts From CacheDB.
    ///
    /// - fetch all CMContact
    /// - loop through the contacts
    ///     - delete their object linkedUser
    ///     - delete the object itself
    ///
    /// Inputs:
    /// it gets no parameters as input
    ///
    /// Outputs:
    /// it returns no output
    ///
    /// - parameters:
    ///     none
    ///
    /// - Returns:
    ///     none
    ///
    func deletePhoneBookContacts(isCompleted: (()->())?) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PhoneContact")
        do {
            if let result = try context.fetch(fetchRequest) as? [PhoneContact] {
                for contact in result {
                    deleteAndSave(object: contact, withMessage: "PhoneContact Deleted")
                }
                isCompleted?()
            } else {
                isCompleted?()
            }
        } catch {
            isCompleted?()
            fatalError()
        }
    }
    
    
    /// Delete LinkedUsers:
    /// by calling this method, it will just Remove LinkedUsers From CacheDB.
    ///
    /// - fetch all CMLinkedUser
    /// - loop through the linkedUsers
    ///     - delete the objects one by one
    ///
    /// Inputs:
    /// it gets no parameters as input
    ///
    /// Outputs:
    /// it returns no output
    ///
    /// - parameters:
    ///     none
    ///
    /// - Returns:
    ///     none
    ///
    func deleteLinkedUsers(isCompleted: @escaping ()->()) {
        let fetchLinkeUsers = NSFetchRequest<NSFetchRequestResult>(entityName: "CMLinkedUser")
        do {
            if let result = try context.fetch(fetchLinkeUsers) as? [CMLinkedUser] {
                for linkeUser in result {
                    deleteAndSave(object: linkeUser, withMessage: "CMLinkedUser Deleted")
                }
                isCompleted()
            } else {
                isCompleted()
            }
        } catch {
            isCompleted()
            fatalError()
        }
    }
    
    
    // MARK: Delete All Threads
    
    /// Delete All Threads:
    /// by calling this method, it will Remove all Threads and Participants and Messages From CacheDB.
    ///
    /// Inputs:
    /// it gets no parameters as input
    ///
    /// Outputs:
    /// it returns no output
    ///
    /// - parameters:
    ///     none
    ///
    /// - Returns:
    ///     none
    ///
    public func deleteAllThreads(isCompleted: @escaping ()->()) {
        deleteThreads {
            self.deleteAllMessage {
                self.deleteParticipants {
                    isCompleted()
                }
            }
        }
    }
    
    /// Delete Threads:
    /// by calling this method, it will just Remove Threads From CacheDB.
    ///
    /// - fetch 'CMConversation' Entity
    /// - for every CMConversation object on the response
    ///     - delete its 'inviter' object
    ///     - delete its 'lastMessageVO' object
    ///     - delete its 'participants' object
    ///     - delete the conversation object itself
    ///
    /// Inputs:
    /// it gets no parameters as input
    ///
    /// Outputs:
    /// it returns no output
    ///
    /// - parameters:
    ///     none
    ///
    /// - Returns:
    ///     none
    ///
    func deleteThreads(isCompleted: @escaping ()->()) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMConversation")
        do {
            if let result = try context.fetch(fetchRequest) as? [CMConversation] {
                for thread in result {
                    if (thread.inviter != nil) {
                        deleteAndSave(object: thread.inviter!, withMessage: "inviter from CMConversation Deleted.")
                    }
                    deleteAndSave(object: thread, withMessage: "CMConversation Deleted.")
                }
                isCompleted()
            } else {
                isCompleted()
            }
        } catch {
            isCompleted()
            fatalError()
        }
    }
    
    func deleteThread(withThreadId: Int, isCompleted: @escaping ()->()) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMConversation")
        fetchRequest.predicate = NSPredicate(format: "id == %i", withThreadId)
        do {
            if let result = try context.fetch(fetchRequest) as? [CMConversation] {
                if result.count > 0 {
                    if (result.first!.inviter != nil) {
                        deleteAndSave(object: result.first!.inviter!, withMessage: "inviter from CMConversation Deleted.")
                    }
                    deleteAndSave(object: result.first!, withMessage: "CMConversation Deleted.")
                }
                isCompleted()
            } else {
                isCompleted()
            }
        } catch {
            isCompleted()
            fatalError()
        }
    }
    
    
    /// Delete ThreadParticipants:
    /// by calling this method, it will just Remove ThreadParticipants From CacheDB.
    ///
    /// - fetch 'CMParticipant' Entity
    /// - delete all CMParticipant objects
    ///
    /// Inputs:
    /// it gets no parameters as input
    ///
    /// Outputs:
    /// it returns no output
    ///
    /// - parameters:
    ///     none
    ///
    /// - Returns:
    ///     none
    ///
    func deleteParticipants(isCompleted: @escaping ()->()) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMParticipant")
        do {
            if let result = try context.fetch(fetchRequest) as? [CMParticipant] {
                for row in result {
                    deleteAndSave(object: row, withMessage: "Delete row from CMParticipant table")
                }
                isCompleted()
            } else {
                isCompleted()
            }
        } catch {
            isCompleted()
            fatalError()
        }
    }
    
    
    // MARK: Delete All Messages
    
    /// Delete All Messages:
    /// by calling this method, it will Remove all Messages and ReplyInfo and ForwardInfo and MessageGaps From CacheDB.
    ///
    /// Inputs:
    /// it gets no parameters as input
    ///
    /// Outputs:
    /// it returns no output
    ///
    /// - parameters:
    ///     none
    ///
    /// - Returns:
    ///     none
    ///
    public func deleteAllMessage(isCompleted: @escaping ()->()) {
        deleteMessages() {
            self.deleteReplyInfo {
                self.deleteForwardInfo {
                    self.deleteMessageGaps {
                        isCompleted()
                    }
                }
            }
        }
    }
    
    /// Delete Messages:
    /// by calling this method, it will just Remove Messages From CacheDB.
    ///
    /// - fetch 'CMMessage' Entity
    /// - for every CMMessage object on the response
    ///     - delete its 'participant' object
    ///     - delete its 'forwardInfo' object
    ///     - delete its 'replyInfo' object
    ///     - delete its 'conversation' object
    ///     - delete the message object itself
    ///
    /// Inputs:
    /// it gets no parameters as input
    ///
    /// Outputs:
    /// it returns no output
    ///
    /// - parameters:
    ///     none
    ///
    /// - Returns:
    ///     none
    ///
    func deleteMessages(isCompleted: @escaping ()->()) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMMessage")
        do {
            if let result = try context.fetch(fetchRequest) as? [CMMessage] {
                for message in result {
                    if (message.participant != nil) {
                        deleteAndSave(object: message.participant!, withMessage: "participant from CMMessage Deleted")
                    }
                    if (message.forwardInfo != nil) {
                        deleteAndSave(object: message.forwardInfo!, withMessage: "forwardInfo from CMMessage Deleted")
                    }
                    if (message.replyInfo != nil) {
                        deleteAndSave(object: message.replyInfo!, withMessage: "replyInfo from CMMessage Deleted")
                    }
                    if (message.conversation != nil) {
                        deleteAndSave(object: message.conversation!, withMessage: "conversation from CMMessage Deleted")
                    }
                    deleteAndSave(object: message, withMessage: "CMMessage Deleted.")
                }
                isCompleted()
            } else {
                isCompleted()
            }
        } catch {
            isCompleted()
            fatalError()
        }
    }
    
    /// Delete ForwardInfo:
    /// by calling this method, it will just Remove ForwardInfo From CacheDB.
    ///
    /// - fetch 'CMForwardInfo' Entity
    /// - delete all CMForwardInfo objects
    ///
    /// Inputs:
    /// it gets no parameters as input
    ///
    /// Outputs:
    /// it returns no output
    ///
    /// - parameters:
    ///     none
    ///
    /// - Returns:
    ///     none
    ///
    func deleteForwardInfo(isCompleted: @escaping ()->()) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMForwardInfo")
        do {
            if let result = try context.fetch(fetchRequest) as? [CMForwardInfo] {
                for row in result {
                    deleteAndSave(object: row, withMessage: "Delete row from CMForwardInfo table")
                }
                isCompleted()
            } else {
                isCompleted()
            }
        } catch {
            isCompleted()
            fatalError()
        }
    }
    
    /// Delete ReplyInfo:
    /// by calling this method, it will just Remove ReplyInfo From CacheDB.
    ///
    /// - fetch 'CMReplyInfo' Entity
    /// - delete all CMReplyInfo objects
    ///
    /// Inputs:
    /// it gets no parameters as input
    ///
    /// Outputs:
    /// it returns no output
    ///
    /// - parameters:
    ///     none
    ///
    /// - Returns:
    ///     none
    ///
    func deleteReplyInfo(isCompleted: @escaping ()->()) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMReplyInfo")
        do {
            if let result = try context.fetch(fetchRequest) as? [CMReplyInfo] {
                for row in result {
                    deleteAndSave(object: row, withMessage: "Delete row from CMReplyInfo table")
                }
                isCompleted()
            } else {
                isCompleted()
            }
        } catch {
            isCompleted()
            fatalError()
        }
    }
    
    
    /// Delete MessageGaps:
    /// by calling this method, it will just Remove MessageGaps From CacheDB.
    ///
    /// - fetch 'MessageGaps' Entity
    /// - delete all MessageGaps objects
    ///
    /// Inputs:
    /// it gets no parameters as input
    ///
    /// Outputs:
    /// it returns no output
    ///
    /// - parameters:
    ///     none
    ///
    /// - Returns:
    ///     none
    ///
    func deleteMessageGaps(isCompleted: @escaping ()->()) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MessageGaps")
        do {
            if let result = try context.fetch(fetchRequest) as? [MessageGaps] {
                for row in result {
                    deleteAndSave(object: row, withMessage: "Delete row from MessageGaps table")
                }
                isCompleted()
            } else {
                isCompleted()
            }
        } catch {
            isCompleted()
            fatalError()
        }
    }
    
    
    
    /// Delete All Images:
    /// by calling this method, it will Remove all CMImage From CacheDB, and the image data from local app bundel
    ///
    /// Inputs:
    /// it gets no parameters as input
    ///
    /// Outputs:
    /// it returns no output
    ///
    /// - parameters:
    ///     none
    ///
    /// - Returns:
    ///     none
    ///
    public func deleteAllImages() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMImage")
        do {
            if let result = try context.fetch(fetchRequest) as? [CMImage] {
                for itemInCache in result {
                    // delete the original file from local storage of the app, using path of the file
                    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                    let myImagePath = path + "/\(fileSubPath.Images)/" + "\(itemInCache.hashCode ?? "default")"
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
        } catch {
            fatalError("Error on fetching list of CMImage")
        }
    }
    
    
    
    /// Delete All Files:
    /// by calling this method, it will Remove all CMFile From CacheDB, and the file data from local app bundel
    ///
    /// Inputs:
    /// it gets no parameters as input
    ///
    /// Outputs:
    /// it returns no output
    ///
    /// - parameters:
    ///     none
    ///
    /// - Returns:
    ///     none
    ///
    public func deleteAllFiles() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMFile")
        do {
            if let result = try context.fetch(fetchRequest) as? [CMFile] {
                for itemInCache in result {
                    // delete the original file from local storage of the app, using path of the file
                    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                    let myFilePath = path + "/\(fileSubPath.Files)/" + "\(itemInCache.hashCode ?? "default")"
                    
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
        } catch {
            fatalError("Error on fetching list of CMFile")
        }
    }
    
    
    // MARK: - delete AllCacheData:
    /// Delete Everything fromCache:
    /// by calling this method, it will just Remove everything From CacheDB.
    ///
    /// Inputs:
    /// it gets no parameters as input
    ///
    /// Outputs:
    /// it returns no output
    ///
    /// - parameters:
    ///     none
    ///
    /// - Returns:
    ///     none
    ///
    public func deleteCacheData() {
        deleteUserInfo() {
            self.deleteContacts(isCompleted: nil)
            self.deletePhoneBookContacts(isCompleted: nil)
            self.deleteThreads() {
                self.deleteAllImages()
                self.deleteAllFiles()
                self.deleteAllWaitQueues()
            }
        }
    }
    
}

