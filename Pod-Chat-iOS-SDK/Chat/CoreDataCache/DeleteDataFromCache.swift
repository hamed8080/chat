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
    /// Inputs:
    /// - it has no params as input
    ///
    /// Outputs:
    /// - it returns no output
    public func deleteUserInfo(isCompleted: (()->())?) {
        /*
         -> fetch CMUser
         -> iterate throut all CMUser objects inside the cache, and delete them one by one.
         (it actualy has only one CMUser object!)
         */
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
    /// Inputs:
    /// - it gets an array of contactIds to delete them
    ///
    /// Outputs:
    /// - it returns no output
    ///
    /// - parameter contactIds:     contactId to delete them. ([Int])
    public func deleteContact(withContactIds contactIds: [Int])  {
        /*
         *  -> loop through the items inside the contactIs input
         *  -> make them or together to create the OrPredicate
         *  -> fetch the CMContact with the use of the oePredicate that we created earlier
         *  -> loop through the result ([CMContact])
         *      -> try to delete the LikedUser (if there was any Contact that has this LinkedUser, this deletion will not work)
         *      -> delete the contact from Cache
         *
         */
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
                
//                for id in contactIds {
//                    for itemInCache in result {
//                        if let contactId = itemInCache.id as? Int {
//                            if (contactId == id) {
//                                if let _ = itemInCache.linkedUser {
//                                    context.delete(itemInCache.linkedUser!)
//                                    saveContext(subject: "Delete CMLinkedUser Object")
//                                }
//                                context.delete(itemInCache)
//                                saveContext(subject: "Delete CMContact Object")
//                            }
//                        }
//                    }
//                }
//                saveContext(subject: "Update CMContact")
            }
        } catch {
            fatalError("Error on fetching list of CMContact when trying to delete contact...")
        }
    }
    
    
    
    /// Delete Contacts by TimeStamp:
    /// by calling this method, it will delete the CMContact that had not been updated for specific timeStamp.
    ///
    /// Inputs:
    /// - it gets the timeStamp as "Int" to delete Contacts that has not been updated for this amount of time
    ///
    /// Outputs:
    /// - it returns no output
    ///
    /// - parameter byTimeStamp: declear the seconds to delete contacts that has not updated for this amount of time. (Int)
    func deleteContacts(byTimeStamp timeStamp: Int) {
        /*
         *  -> get the current time
         *  -> decrease it with the timeStamp input and create a new time
         *  -> fetch CMContact Entity where object that has lesser time value than this new time that we generated
         *  -> loop through the result and get the object Ids
         *  -> if there was more than 1 value of objectIds,
         *  -> send the objectIds to the 'deleteContact(withContactIds: [Int])' to delete these contacts
         *
         */
        let currentTime = Int(Date().timeIntervalSince1970)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMContact")
        fetchRequest.predicate = NSPredicate(format: "time <= %i", Int(currentTime - timeStamp))
        do {
            if let result = try context.fetch(fetchRequest) as? [CMContact] {
                var contactIds: [Int] = []
                for item in result {
                    contactIds.append((item.id! as? Int)!)
//                    deleteContact(withContactIds: [(item.id! as? Int)!])
//                    context.delete(item)
//                    saveContext(subject: "item Deleted from CMContact")
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
    /// - it gets the threadId as "Int" and an array of 'participantsId' to delete them
    ///
    /// Outputs:
    /// - it returns no output
    ///
    /// - parameter inThread:       specify the threadId that want to delete participants from it. (Int)
    /// - parameter participantIds: participantIds to delete them. ([Int])
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
        
//        /*
//         *  -> fetch all the CMConversation where its is is equal to 'inThread' threadId
//         *  -> if there is any response on the result
//         *  -> loop through all participants of the conversation,
//         *      -> loop through the 'participantIds' input
//         *          -> if we fount the participant that has the same participant id, we will delete that participant object
//         *
//         */
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMConversation")
//        fetchRequest.predicate = NSPredicate(format: "id == %i", inThread)
//        do {
//            if let result = try context.fetch(fetchRequest) as? [CMConversation] {
//                if (result.count > 0) {
//                    if let _ = result.first!.participants {
//                        for (index, participant) in result.first!.participants!.enumerated() {
//                            for id in participantIds {
//                                if (Int(exactly: participant.id ?? 0) == id) {
//                                    result.first!.removeFromParticipants(at: index)
//                                    deleteAndSave(object: participant, withMessage: "Delete CMParticipant Object from Thread")
//                                }
//                            }
//                        }
//                    }
//                }
//                saveContext(subject: "Update CMConversation")
//            }
//        } catch {
//            fatalError("Error on fetching list of CMConversation when trying to delete some Participant from it")
//        }
    }
    
    /*
    // delete the participant itself
    func deleteParticipant(withParticipantIds participantIds: [Int]) {
        /*
         *  -> loop through the items inside the participantIds input
         *  -> make them "logical or" together, to create the orPredicate
         *  -> fetch the CMParticipant with the use of the oePredicate that we created earlier
         *  -> loop through the result ([CMParticipant])
         *      -> delete the participant from Cache
         *
         */
        var orPredicatArray = [NSPredicate]()
        for item in participantIds {
            orPredicatArray.append(NSPredicate(format: "id == %i", item))
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMParticipant")
        let predicateCompound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: orPredicatArray)
        fetchRequest.predicate = predicateCompound
        do {
            if let result = try context.fetch(fetchRequest) as? [CMParticipant] {
                for participant in result {
                    context.delete(participant)
                    saveContext(subject: "Delete CMParticipant Object")
                }
                saveContext(subject: "Update CMParticipant")
//                for id in participantIds {
//                    for itemInCache in result {
//                        if let participantId = Int(exactly: itemInCache.id ?? 0) {
//                            if (participantId == id) {
//                                context.delete(itemInCache)
//                                saveContext(subject: "Delete CMParticipant Object")
//                            }
//                        }
//                    }
//                }
            }
        } catch {
            fatalError("Error on fetching list of CMParticipant when trying to delete Participant")
        }
    }
    */
    
    
    
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
    /// - parameter inThread:       specify the threadId that want to delete participants from it. (Int)
    /// - parameter byTimeStamp:    declear the seconds to delete participants that has not updated for this amount of time. (Int)
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
        
//        /*
//         *  -> get the current time
//         *  -> decrease it with the timeStamp input and create a new time
//         *  -> fetch CMConversation Entity with its threadId
//         *  -> loop through the participants of the thread (result) and
//         *      -> remove this particiapnt from the thread
//         *      -> delete the particiapnt object itself
//         *
//         */
//
//
//        /*
//         *  -> get the current time
//         *  -> decrease it with the timeStamp input and create a new time
//         *  -> fetch CMThreadParticipants Entity where object that has lesser time value than this new time that we generated
//         *  -> loop through the result and
//         *      -> send threadId and ParticipantId to the 'deleteParticipant(inThread: Int, withParticipantIds: [Int])' to delete these participants
//         *      -> delete the threadParticipant itself
//         *
//         */
//
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMConversation")
//        let currentTime = Int(Date().timeIntervalSince1970)
//        let xTime = Int(currentTime - byTimeStamp)
//        fetchRequest.predicate = NSPredicate(format: "id == %i", inThread)
//        do {
//            if let result = try context.fetch(fetchRequest) as? [CMConversation] {
//
//                if result.count > 0 {
//
//                    for (index, participant) in result.first!.participants!.enumerated() {
//                        if ((participant.time as! Int) <= xTime) {
//                            result.first!.removeFromParticipants(at: index)
//                            deleteAndSave(object: participant, withMessage: "Delete CMParticipant Object from Thread")
//                        }
//                    }
//
//                }
//
//                /*
//                for threadParticipant in result {
//                    deleteParticipant(inThread: Int(exactly: threadParticipant.threadId!)!, withParticipantIds: [Int(exactly: threadParticipant.participantId!)!])
//                    context.delete(threadParticipant)
//                    saveContext(subject: "item Deleted from CMThreadParticipants")
//                }
//                */
//
//            }
//        } catch {
//            fatalError("Error on fetching CMThreadParticipants when trying to delete object based on timeStamp")
//        }
    }
    
    
    
    /*
    func deleteAllThreadParticipants(inThreadId: Int) {
        /*
         *  -> fetch all threadParticipants that their threadId is equal to 'inThreadId' input
         *  -> for every object inside the result
         *      -> send threadId and ParticipantId to the 'deleteParticipant(inThread: Int, withParticipantIds: [Int])' to delete these participants
         *      -> delete the threadParticipant itself
         *
         */
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMThreadParticipants")
        fetchRequest.predicate = NSPredicate(format: "id == %i", inThreadId)
        do {
            if let result = try context.fetch(fetchRequest) as? [CMThreadParticipants] {
                for item in result {
                    deleteParticipant(inThread: Int(exactly: item.threadId!)!, withParticipantIds: [Int(exactly: item.participantId!)!])
                    context.delete(item)
                    saveContext(subject: "item Deleted from CMThreadParticipants")
                }
            }
        } catch {
            fatalError("Error on fetching CMThreadParticipants when trying to delete object based on timeStamp")
        }
    }
    */
    
    
    // MARK: - delete Threads:
    /// Delete Threads by their ThreadIds:
    /// by calling this method, we will delete specific CMConversation
    ///
    /// Inputs:
    /// - it gets the threadIds as "[Int]" to delete them
    ///
    /// Outputs:
    /// - it returns no output
    ///
    /// - parameter withThreadIds:  specify the threadIds that want to delete them. ([Int])
    public func deleteThreads(withThreadIds threadIds: [Int]) {
        /*
         *  -> loop through the items inside the 'threadIds' input
         *  -> make them or together to create the orPredicate
         *  -> fetch the CMConversation with the use of the orPredicate that we created earlier
         *  -> loop through the result ([CMConversation])
         *      -> delete all Message inside this thread
         *      -> delete object thread participants from Cache
         *      -> delete inviter participant from cache
         *      -> delete lastMessage object from cache
         *      -> delete all Messages inside this thread
         *
         */
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
//                    if let participants = thread.participants {
//                        for (index, _) in participants.enumerated() {
//                            result[threadIndex].removeFromParticipants(at: index)
//                            deleteAndSave(object: (thread.participants?[index])!, withMessage: "Delete CMParticipant Object")
//                        }
//                    }
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
                
//                for id in threadIds {
//                    for itemInCache in result {
//                        if let threadId = itemInCache.id as? Int {
//                            if (threadId == id) {
//                                deleteMessage(inThread: id, allMessages: true, withMessageIds: [])
//                                deleteAllThreadParticipants(inThreadId: id)
//
//                                if let participants = itemInCache.participants {
//                                    for (index, _) in participants.enumerated() {
//                                        context.delete((itemInCache.participants?[index])!)
//                                        saveContext(subject: "Delete CMParticipant Object")
//                                    }
//                                }
//                                if let _ = itemInCache.inviter {
//                                    context.delete(itemInCache.inviter!)
//                                    saveContext(subject: "Delete CMParticipant Object")
//                                }
//                                if let _ = itemInCache.lastMessageVO {
//                                    context.delete(itemInCache.lastMessageVO!)
//                                    saveContext(subject: "Delete CMMessage Object")
//                                }
//                                context.delete(itemInCache)
//                                saveContext(subject: "Delete CMConversation Object")
//                            }
//                        }
//                    }
//                }
//                saveContext(subject: "Update CMConversation")
            }
        } catch {
            fatalError("Error on fetching list of CMConversation when trying to delete Threads...")
        }
    }
    
    // MARK: - delete Pin/Unpin Message from Thread:
    /// Delete Pin/Unpin Message on CMConversation Entity:
    /// by calling this function, 'pinMessage' property on Conversation will be delete
    ///
    /// Inputs:
    /// - it gets the messageId as  "Int" , and pinMessage as "PinUnpinMessage" value as inputs
    ///
    /// Outputs:
    /// - it returns no output
    ///
    /// - parameter messageId:      send your messageId to this parameter.(Int)
    /// - parameter pinMessage:     send your  pinMessageObject to save it on the cache (PinUnpinMessage)
    func deletePinMessageFromCMConversationEntity(threadId: Int) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMConversation")
        fetchRequest.predicate = NSPredicate(format: "id == %i", threadId)
        do {
            if let result = try context.fetch(fetchRequest) as? [CMConversation] {
                if (result.count > 0) {
                    result.first!.pinMessage = nil
                    saveContext(subject: "Update CMConversation on save PinMessage -update existing object-")
                }
            }
        } catch {
            fatalError("Error on trying to find the Thread from CMConversation entity")
        }
    }
    
    
    
    // MARK: - delete Messages:
    // ToDo: make it better, because it calls another function to delete messages (one more query on the cache)
    /// Delete Message:
    /// by calling this method, we will delete specific CMMessages
    ///
    /// Inputs:
    /// - it gets some parameters to retireave Messages from Cache based on this params, and then delete them
    ///
    /// Outputs:
    /// - it returns no output
    ///
    /// - parameter count:      how many Messages do you spect to delete (Int)
    /// - parameter fromTime:   filter the messages that sends after this time.
    /// - parameter messageId:  if you want to search specific message with its messageId, fill this parameter
    /// - parameter offset:     from what offset do you want to get the Cache response (Int)
    /// - parameter order:      on what order do you want to get the response? "asc" or "desc". (String?)
    /// - parameter query:      if you want to search a specific term on the messages, fill this parameter. (String?)
    /// - parameter threadIds:  do you want to search messages on what threadId. (Int)
    /// - parameter fromTime:   filter the messages that sends before this time
    /// - parameter uniqueId:   if you want to search specific message with its uniqueId, fill this parameter
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
    /// Inputs:
    /// - it gets some parameters to retireave Messages from Cache based on this params, and then delete them
    ///
    /// Outputs:
    /// - it returns no output
    ///
    /// - parameter inThread:       the threadId that you want to delete messages from it. (Int)
    /// - parameter allMessages:    if you want to delete all messages on this thread, send this param as "true". (Bool)
    /// - parameter withMessageIds: if you want to delete specifice messages with their Ids, send them to this param. ([Int])
    public func deleteMessage(inThread: Int, allMessages: Bool, withMessageIds messageIds: [Int]?) {
        /*
         *  -> define a method that will handle of deletion of messages
         *      -> delete the participant object of the message
         *      -> delete the conversation object of the message
         *      -> delete the replyInfo object of the message
         *      -> delete the forwardInfo object of the message
         *      -> delete the message object itself
         *  -> fetch through al CMMessage that its threadId is equal to 'inThread' input
         *      -> if user wants to delete all messages ('allMessages' = 'true'), call the method to delete all messages
         *      -> else, get the 'messageIds' input, and delete them from cache
         *
         *  -> delete this messages from MessageGap Entity (if exists)
         *
         */
        
        func deleteCMMessage(message: CMMessage) {
            if let _ = message.participant {
                deleteAndSave(object: message.participant!, withMessage: "Delete participant from CMMessage Object")
            }
            if let _ = message.conversation {
                deleteAndSave(object: message.conversation!, withMessage: "Delete conversation from CMMessage Object")
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
    /// Inputs:
    /// - it gets some the threadId that we want to delete all its MessageGaps
    ///
    /// Outputs:
    /// - it returns no output
    ///
    /// - parameter inThread:       the threadId that you want to delete messageGapes from it. (Int)
    func deleteAllMessageGaps(inThreadId threadId: Int) {
        /*
         *  -> fetch from 'MessageGaps' Entity with 'threadId' and 'messageId' Inputs
         *  -> if we found any object, we will delete it
         *
         */
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MessageGaps")
        fetchRequest.predicate = NSPredicate(format: "threadId == %i", threadId)
        do {
            if let result = try context.fetch(fetchRequest) as? [MessageGaps] {
                for gap in result {
                    deleteAndSave(object: gap, withMessage: "Delete gap from MessageGap Object")
                }
//                for msgId in messageIds {
//                    for item in result {
//                        if ((item.messageId as? Int) == msgId) {
//                            deleteAndSave(object: item, withMessage: "Delete gap from MessageGap Object")
//                        }
//                    }
//                }
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
    /// - it gets no parameters as input
    ///
    /// Outputs:
    /// - it returns no output
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
    /// Inputs:
    /// - it gets no parameters as input
    ///
    /// Outputs:
    /// - it returns no output
    func deleteContacts(isCompleted: (()->())?) {
        /*
         *  -> fetch all CMContact
         *  -> loop through the contacts
         *      -> delete their object linkedUser
         *      -> delete the object itself
         *
         */
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMContact")
        do {
            if let result = try context.fetch(fetchRequest) as? [CMContact] {
                for contact in result {
                    if let _ = contact.linkedUser {
                        deleteAndSave(object: contact.linkedUser!, withMessage: "CMLinkedUser Deleted")
//                        context.delete(contact.linkedUser!)
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
    
    
    /// Delete LinkedUsers:
    /// by calling this method, it will just Remove LinkedUsers From CacheDB.
    ///
    /// Inputs:
    /// - it gets no parameters as input
    ///
    /// Outputs:
    /// - it returns no output
    func deleteLinkedUsers(isCompleted: @escaping ()->()) {
        /*
         *  -> fetch all CMLinkedUser
         *  -> loop through the linkedUsers
         *      -> delete the objects one by one
         *
         */
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
    /// - it gets no parameters as input
    ///
    /// Outputs:
    /// - it returns no output
    public func deleteAllThreads(isCompleted: @escaping ()->()) {
        deleteThreads {
            self.deleteAllMessage {
                self.deleteParticipants {
                    isCompleted()
                }
            }
        }
        
        
//        deleteThreadParticipants()
    }
    
    /// Delete Threads:
    /// by calling this method, it will just Remove Threads From CacheDB.
    ///
    /// Inputs:
    /// - it gets no parameters as input
    ///
    /// Outputs:
    /// - it returns no output
    func deleteThreads(isCompleted: @escaping ()->()) {
        /*
         *  -> fetch 'CMConversation' Entity
         *  -> for every CMConversation object on the response
         *      -> delete its 'inviter' object
         *      -> delete its 'lastMessageVO' object
         *      -> delete its 'participants' object
         *      -> delete the conversation object itself
         *
         */
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMConversation")
        do {
            if let result = try context.fetch(fetchRequest) as? [CMConversation] {
                for thread in result {
                    if (thread.inviter != nil) {
                        deleteAndSave(object: thread.inviter!, withMessage: "inviter from CMConversation Deleted.")
                    }
//                    if (thread.lastMessageVO != nil) {
//                        deleteAndSave(object: thread.lastMessageVO!, withMessage: "lastMessageVO from CMConversation Deleted.")
//                    }
//                    if let threadParticipants = thread.participants {
//                        for participant in threadParticipants {
//                            deleteAndSave(object: participant, withMessage: "participant from CMConversation Deleted.")
//                        }
//                    }
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
    
    /// Delete ThreadParticipants:
    /// by calling this method, it will just Remove ThreadParticipants From CacheDB.
    ///
    /// Inputs:
    /// - it gets no parameters as input
    ///
    /// Outputs:
    /// - it returns no output
    func deleteParticipants(isCompleted: @escaping ()->()) {
    /*
        *  -> fetch 'CMParticipant' Entity
        *  -> delete all CMParticipant objects
        *
        */
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
    
    /*
    func deleteThreadParticipants() {
        /*
         *  -> fetch 'CMThreadParticipants' Entity
         *  -> delete all CMThreadParticipants objects
         *
         */
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMThreadParticipants")
        do {
            if let result = try context.fetch(fetchRequest) as? [CMThreadParticipants] {
                for row in result {
                    deleteAndSave(object: row, withMessage: "Delete row from CMThreadParticipants table")
                }
            }
        } catch {
            fatalError()
        }
    }
    */
    
    
    
    // MARK: Delete All Messages
    
    /// Delete All Messages:
    /// by calling this method, it will Remove all Messages and ReplyInfo and ForwardInfo and MessageGaps From CacheDB.
    ///
    /// Inputs:
    /// - it gets no parameters as input
    ///
    /// Outputs:
    /// - it returns no output
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
//        deleteReplyInfo()
//        deleteForwardInfo()
//        deleteMessageGaps()
    }
    
    /// Delete Messages:
    /// by calling this method, it will just Remove Messages From CacheDB.
    ///
    /// Inputs:
    /// - it gets no parameters as input
    ///
    /// Outputs:
    /// - it returns no output
    func deleteMessages(isCompleted: @escaping ()->()) {
        /*
         *  -> fetch 'CMMessage' Entity
         *  -> for every CMMessage object on the response
         *      -> delete its 'participant' object
         *      -> delete its 'forwardInfo' object
         *      -> delete its 'replyInfo' object
         *      -> delete its 'conversation' object
         *      -> delete the message object itself
         *
         */
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
    /// Inputs:
    /// - it gets no parameters as input
    ///
    /// Outputs:
    /// - it returns no output
    func deleteForwardInfo(isCompleted: @escaping ()->()) {
        /*
         *  -> fetch 'CMForwardInfo' Entity
         *  -> delete all CMForwardInfo objects
         *
         */
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
    /// Inputs:
    /// - it gets no parameters as input
    ///
    /// Outputs:
    /// - it returns no output
    func deleteReplyInfo(isCompleted: @escaping ()->()) {
        /*
         *  -> fetch 'CMReplyInfo' Entity
         *  -> delete all CMReplyInfo objects
         *
         */
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
    
//    func deleteMessageGap(wihtMessageId messageId: Int) {
//        /*
//         *  -> fetch 'MessageGaps' Entity with messageId
//         *  -> delete that specific messageGap object
//         *
//         */
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MessageGaps")
//        fetchRequest.predicate = NSPredicate(format: "messageId == %i", messageId)
//        do {
//            if let result = try context.fetch(fetchRequest) as? [MessageGaps] {
//                for row in result {
//                    deleteAndSave(object: row, withMessage: "Delete gap from MessageGaps Object")
//                }
//            }
//        } catch {
//            fatalError()
//        }
//    }
    
    /// Delete MessageGaps:
    /// by calling this method, it will just Remove MessageGaps From CacheDB.
    ///
    /// Inputs:
    /// - it gets no parameters as input
    ///
    /// Outputs:
    /// - it returns no output
    func deleteMessageGaps(isCompleted: @escaping ()->()) {
        /*
         *  -> fetch 'MessageGaps' Entity
         *  -> delete all MessageGaps objects
         *
         */
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
    /// - it gets no parameters as input
    ///
    /// Outputs:
    /// - it returns no output
    public func deleteAllImages() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMImage")
        do {
            if let result = try context.fetch(fetchRequest) as? [CMImage] {
                for itemInCache in result {
                    // delete the original file from local storage of the app, using path of the file
                    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                    let myImagePath = path + "/\(fileSubPath.Images)/" + "\(itemInCache.id!)\(itemInCache.name ?? "default")"
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
    /// - it gets no parameters as input
    ///
    /// Outputs:
    /// - it returns no output
    public func deleteAllFiles() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMFile")
        do {
            if let result = try context.fetch(fetchRequest) as? [CMFile] {
                for itemInCache in result {
                    // delete the original file from local storage of the app, using path of the file
                    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                    let myFilePath = path + "/\(fileSubPath.Files)/" + "\(itemInCache.id!)\(itemInCache.name ?? "default")"
                    
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
    /// - it gets no parameters as input
    ///
    /// Outputs:
    /// - it returns no output
    public func deleteCacheData() {
        deleteUserInfo() {
            self.deleteContacts(isCompleted: nil)
            self.deleteThreads() {
                self.deleteAllImages()
                self.deleteAllFiles()
                self.deleteAllWaitQueues()
            }
        }
//        deleteContacts()    // it will delete the LinkedUsers too
//        deleteThreads()     // it will delete threads, participants, threadParticipants too, messages (contain: message, raplyIndo, forwardInfo, messageGaps)
        
//        deleteAllImages()
//        deleteAllFiles()
        
//        deleteAllWaitQueues()
    }
    
}

