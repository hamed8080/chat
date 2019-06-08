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
    
    
    public func deleteMessage(count: Int?, fromTime: UInt?, messageId: Int?, offset: Int, order: String, query: String?, threadId: Int?, toTime: UInt?, uniqueId: String?) {
        let fetchRequest = retrieveMessageHistoryFetchRequest(firstMessageId: nil, fromTime: fromTime, messageId: messageId, lastMessageId: nil, order: order, query: query, threadId: threadId, toTime: toTime, uniqueId: uniqueId)
        do {
            if let result = try context.fetch(fetchRequest) as? [CMMessage] {
                
                switch (count) {
                case let .some(count):
                    var insideCount = 0
                    for (index, item) in result.enumerated() {
                        if (index >= offset) && (insideCount < count) {
                            
                            deleteMessage(inThread: Int(exactly: item.threadId ?? 0) ?? 0, withMessageIds: [Int(exactly: item.id ?? 0) ?? 0])
                            insideCount += 1
                        }
                    }
                case .none:
                    for item in result {
                        deleteMessage(inThread: Int(exactly: item.threadId ?? 0) ?? 0, withMessageIds: [Int(exactly: item.id ?? 0) ?? 0])
                    }
                    
                    //                default: break
                }
            }
            
        } catch {
            fatalError("Error on fetching list of CMMessage")
        }
    }
    
// delete contacts thas has removed from server
//    public func updateCMContactEntityByDeletingRemovedContactsFromServer(allServerContacts: [Contact]) {
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMContact")
//        do {
//            if let result = try context.fetch(fetchRequest) as? [CMContact] {
//                for cmcontact in result {    // loop through the CMContacts (Contacts in the cache)
//                    var shouldDelete = false
//                    for contact in allServerContacts {
//                        if (cmcontact.id! == (contact.id! as NSNumber)) {
//                            shouldDelete = true
//                        }
//                    }
//                    if shouldDelete {
//                        deleteContact(withContactIds: [Int(exactly: cmcontact.id!)!])
//                    }
//                }
//            }
//        } catch {
//
//        }
//    }
    
    // delete contact
    public func deleteContact(withContactIds contactIds: [Int])  {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMContact")
        do {
            if let result = try context.fetch(fetchRequest) as? [CMContact] {
                for id in contactIds {
                    for itemInCache in result {
                        if let contactId = Int(exactly: itemInCache.id ?? 0) {
                            if (contactId == id) {
                                if let _ = itemInCache.linkedUser {
                                    context.delete(itemInCache.linkedUser!)
                                }
                                context.delete(itemInCache)
                                saveContext(subject: "Delete CMContact Object")
                            }
                        }
                    }
                }
                saveContext(subject: "Update CMContact")
            }
        } catch {
            fatalError("Error on fetching list of CMContact when trying to delete contact...")
        }
    }
    
    
    // delete the participant itself
    public func deleteParticipant(withParticipantIds participantIds: [Int]) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMParticipant")
        do {
            if let result = try context.fetch(fetchRequest) as? [CMParticipant] {
                
                // Part1:
                // find data that are exist in the Cache, (and the response request is containing that). and delete them
                for id in participantIds {
                    for itemInCache in result {
                        if let participantId = Int(exactly: itemInCache.id ?? 0) {
                            if (participantId == id) {
                                context.delete(itemInCache)
                                saveContext(subject: "Delete CMParticipant Object")
                            }
                        }
                    }
                }
            }
        } catch {
            fatalError("Error on fetching list of CMParticipant when trying to delete Participant")
        }
    }
    
    
    // delete participants from specific thread
    public func deleteParticipant(inThread: Int, withParticipantIds participantIds: [Int]) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMConversation")
        fetchRequest.predicate = NSPredicate(format: "id == %i", inThread)
        do {
            if let result = try context.fetch(fetchRequest) as? [CMConversation] {
                if (result.count > 0) {
                    if let _ = result.first!.participants {
                        for participant in result.first!.participants! {
                            for id in participantIds {
                                if (Int(exactly: participant.id ?? 0) == id) {
                                    context.delete(participant)
                                    saveContext(subject: "Delete CMParticipant Object from Thread")
                                }
                            }
                        }
                    }
                }
                saveContext(subject: "Update CMConversation")
            }
        } catch {
            fatalError("Error on fetching list of CMConversation when trying to delete some Participant from it")
        }
    }
    
    
    // delete messages from specific thread
    public func deleteMessage(inThread: Int, withMessageIds messageIds: [Int]) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMMessage")
        fetchRequest.predicate = NSPredicate(format: "threadId == %i", inThread)
        do {
            if let result = try context.fetch(fetchRequest) as? [CMMessage] {
                for message in result {
                    for msgId in messageIds {
                        if (Int(exactly: message.id ?? 0) == msgId) {
                            if let _ = message.participant {
                                context.delete(message.participant!)
                                saveContext(subject: "Delete participant from CMMessage Object")
                            }
                            if let _ = message.conversation {
                                context.delete(message.conversation!)
                                saveContext(subject: "Delete conversation from CMMessage Object")
                            }
                            if let _ = message.replyInfo {
                                context.delete(message.replyInfo!)
                                saveContext(subject: "Delete replyInfo from CMMessage Object")
                            }
                            if let _ = message.forwardInfo {
                                context.delete(message.forwardInfo!)
                                saveContext(subject: "Delete forwardInfo from CMMessage Object")
                            }
                            context.delete(message)
                            saveContext(subject: "Delete CMMessage Object")
                        }
                    }
                }
                saveContext(subject: "Update CMMessage")
            }
        } catch {
            fatalError("Error on fetching list of CMMessage when trying to delete")
        }
    }
    
    
    
    
    
    
    // delete objects that has been not updated for "timeStamp" seconds
    func deleteThreadParticipants(timeStamp: Int) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMThreadParticipants")
        let currentTime = Int(Date().timeIntervalSince1970)
        fetchRequest.predicate = NSPredicate(format: "time <= %i", Int(currentTime - timeStamp))
        
        print("currentTime = \(currentTime)\t timeStamp = \(timeStamp)")
        
        do {
            if let result = try context.fetch(fetchRequest) as? [CMThreadParticipants] {
                print("fetched successfully")
                for item in result {
                    print("there are = \(result.count)")
                    print("time = \(item.time!)")
                    deleteParticipant(inThread: Int(exactly: item.threadId!)!, withParticipantIds: [Int(exactly: item.participantId!)!])
                    print("first delete")
                    context.delete(item)
                    print("second delete")
                    saveContext(subject: "item Deleted from CMThreadParticipants")
                }
            }
        } catch {
            fatalError("Error on fetching CMThreadParticipants when trying to delete object based on timeStamp")
        }
    }
    
    
    // delete objects that has been not updated for "timeStamp" seconds
    func deleteContacts(byTimeStamp timeStamp: Int) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMContact")
        let currentTime = Int(Date().timeIntervalSince1970)
        fetchRequest.predicate = NSPredicate(format: "time <= %i", Int(currentTime - timeStamp))
        do {
            if let result = try context.fetch(fetchRequest) as? [CMContact] {
                for item in result {
                    deleteContact(withContactIds: [Int(exactly: item.id!)!])
                    context.delete(item)
                    saveContext(subject: "item Deleted from CMContact")
                }
            }
        } catch {
            fatalError("Error on fetching CMContact when trying to delete object based on timeStamp")
        }
    }
    
    
    
    public func deleteAllCMLinkedUsersFromCache() {
        let fetchLinkeUsers = NSFetchRequest<NSFetchRequestResult>(entityName: "CMLinkedUser")
        do {
            if let result = try context.fetch(fetchLinkeUsers) as? [CMLinkedUser] {
                for linkeUser in result {
                    deleteAndSave(object: linkeUser, withMessage: "CMLinkedUser Deleted")
                }
            }
        } catch {
            fatalError()
        }
    }
    
    public func deleteAllContactsFromCache() {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMContact")
        do {
            if let result = try context.fetch(fetchRequest) as? [CMContact] {
                for contact in result {
                    if let lui = contact.linkedUser {
                        print("id = \(lui)")
                        context.delete(contact.linkedUser!)
                    }
                    deleteAndSave(object: contact, withMessage: "CMContact Deleted.")
                }
            }
        } catch {
            fatalError()
        }
    }
    
    public func deleteAllThreadsFromCache() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMConversation")
        do {
            if let result = try context.fetch(fetchRequest) as? [CMConversation] {
                for thread in result {
                    if (thread.inviter != nil) {
                        deleteAndSave(object: thread.inviter!, withMessage: "inviter from CMConversation Deleted.")
                    }
                    if (thread.lastMessageVO != nil) {
                        deleteAndSave(object: thread.lastMessageVO!, withMessage: "lastMessageVO from CMConversation Deleted.")
                    }
                    if let threadParticipants = thread.participants {
                        for participant in threadParticipants {
                            deleteAndSave(object: participant, withMessage: "participant from CMConversation Deleted.")
                        }
                    }
                    deleteAndSave(object: thread, withMessage: "CMConversation Deleted.")
                }
            }
        } catch {
            fatalError()
        }
    }
    
    public func deleteAllMessagesFromCache() {
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
            }
        } catch {
            fatalError()
        }
    }
    
    public func deleteUserInfoFromCache() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMUser")
        do {
            if let result = try context.fetch(fetchRequest) as? [CMUser] {
                for user in result {
                    deleteAndSave(object: user, withMessage: "CMUser Deleted.")
                }
            }
        } catch {
            fatalError()
        }
    }
    
    public func deleteAllImagesFromCache() {
        
    }
    
    public func deleteAllFilesFromCache() {
        
    }
    
    public func deleteThreadParticipantsTableFromCache() {
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
    
    public func deleteCacheData() {
        deleteAllCMLinkedUsersFromCache()
        deleteAllContactsFromCache()
        deleteAllThreadsFromCache()
        deleteAllMessagesFromCache()
        deleteUserInfoFromCache()
        deleteAllImagesFromCache()
        deleteAllFilesFromCache()
        deleteThreadParticipantsTableFromCache()
    }
    
}

