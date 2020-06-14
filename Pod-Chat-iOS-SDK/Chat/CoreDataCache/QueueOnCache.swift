//
//  QueueOnCache.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 3/18/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import CoreData


// handle Queue of wait messages
extension Cache {
    
    // MARK: - save to the wait Queues
    func saveTextMessageToWaitQueue(textMessage: QueueOfWaitTextMessagesModel) {
        let theWaitQueueEntity = NSEntityDescription.entity(forEntityName: "QueueOfTextMessages", in: context)
        let messageToSaveOnQueue = QueueOfTextMessages(entity: theWaitQueueEntity!, insertInto: context)
        messageToSaveOnQueue.textMessage    = textMessage.textMessage
        messageToSaveOnQueue.repliedTo      = textMessage.repliedTo as NSNumber?
        messageToSaveOnQueue.threadId       = textMessage.threadId as NSNumber?
        messageToSaveOnQueue.typeCode       = textMessage.typeCode
        messageToSaveOnQueue.uniqueId       = textMessage.uniqueId
        
//        if let metadata2 = textMessage.metadata {
//            NSObject.convertJSONtoTransformable(dataToStore: metadata2) { (data) in
//                messageToSaveOnQueue.metadata = data
//            }
//        }
//
//        if let systemMetadata2 = textMessage.systemMetadata {
//            NSObject.convertJSONtoTransformable(dataToStore: systemMetadata2) { (data) in
//                messageToSaveOnQueue.systemMetadata = data
//            }
//        }
        messageToSaveOnQueue.metadata       = textMessage.metadata
        messageToSaveOnQueue.systemMetadata = textMessage.systemMetadata
        
        // save function that will try to save changes that made on the Cache
        saveContext(subject: "Create QueueOfTextMessages -create a new object-")
    }
    
    func saveEditMessageToWaitQueue(editMessage: QueueOfWaitEditMessagesModel) {
        
        let fetchRequest = retrieveMessageHistoryFetchRequest(fromTime:     nil,
                                                              messageId:    editMessage.messageId,
                                                              messageType:  nil,
                                                              order:        nil,
                                                              query:        nil,
                                                              threadId:     nil,
                                                              toTime:       nil,
                                                              uniqueIds:    nil)
        
        do {
            if let result = try context.fetch(fetchRequest) as? [CMMessage] {
                if (result.count > 0) {
                    let theWaitQueueEntity = NSEntityDescription.entity(forEntityName: "QueueOfEditMessages", in: context)
                    let messageToSaveOnQueue = QueueOfEditMessages(entity: theWaitQueueEntity!, insertInto: context)
                    messageToSaveOnQueue.textMessage    = editMessage.textMessage
                    messageToSaveOnQueue.repliedTo      = editMessage.repliedTo as NSNumber?
                    messageToSaveOnQueue.messageId      = editMessage.messageId as NSNumber?
                    messageToSaveOnQueue.typeCode       = editMessage.typeCode
                    messageToSaveOnQueue.uniqueId       = editMessage.uniqueId
                    messageToSaveOnQueue.threadId       = result.first!.threadId
//                    if let metadata2 = editMessage.metadata {
//                        NSObject.convertJSONtoTransformable(dataToStore: metadata2) { (data) in
//                            messageToSaveOnQueue.metadata = data
//                        }
//                    }
                    messageToSaveOnQueue.metadata   = editMessage.metadata
                    
                    // save function that will try to save changes that made on the Cache
                    saveContext(subject: "Create QueueOfEditMessages -create a new object-")
                }
            }
        } catch {
            fatalError("Error on fetching the CMMessage")
        }
        
    }
    
    func saveForwardMessageToWaitQueue(forwardMessage: QueueOfWaitForwardMessagesModel) {
        let theWaitQueueEntity = NSEntityDescription.entity(forEntityName: "QueueOfForwardMessages", in: context)
        let messageToSaveOnQueue = QueueOfForwardMessages(entity: theWaitQueueEntity!, insertInto: context)
//        messageToSaveOnQueue.messageIds = forwardMessage.messageIds as [NSNumber]?
        messageToSaveOnQueue.messageId  = forwardMessage.messageId as NSNumber?
        messageToSaveOnQueue.repliedTo  = forwardMessage.repliedTo as NSNumber?
        messageToSaveOnQueue.threadId   = forwardMessage.threadId as NSNumber?
        messageToSaveOnQueue.typeCode   = forwardMessage.typeCode
        messageToSaveOnQueue.uniqueId   = forwardMessage.uniqueId
        
//        if let metadata2 = forwardMessage.metadata {
//            NSObject.convertJSONtoTransformable(dataToStore: metadata2) { (data) in
//                messageToSaveOnQueue.metadata = data
//            }
//        }
        messageToSaveOnQueue.metadata   = forwardMessage.metadata
        
        // save function that will try to save changes that made on the Cache
        saveContext(subject: "Create QueueOfForwardMessages -create a new object-")
    }
    
    func saveFileMessageToWaitQueue(fileMessage: QueueOfWaitFileMessagesModel) {
        let theWaitQueueEntity = NSEntityDescription.entity(forEntityName: "QueueOfFileMessages", in: context)
        let messageToSaveOnQueue = QueueOfFileMessages(entity: theWaitQueueEntity!, insertInto: context)
        messageToSaveOnQueue.textMessage    = fileMessage.textMessage
        messageToSaveOnQueue.fileName       = fileMessage.fileName
        messageToSaveOnQueue.fileToSend     = fileMessage.fileToSend as NSData?
//        messageToSaveOnQueue.imageName      = fileMessage.imageName
        messageToSaveOnQueue.imageToSend    = fileMessage.imageToSend as NSData?
        messageToSaveOnQueue.repliedTo      = fileMessage.repliedTo as NSNumber?
//        messageToSaveOnQueue.subjectId      = fileMessage.subjectId as NSNumber?
        messageToSaveOnQueue.threadId       = fileMessage.threadId as NSNumber?
        messageToSaveOnQueue.hC             = fileMessage.hC as NSNumber?
        messageToSaveOnQueue.wC             = fileMessage.wC as NSNumber?
        messageToSaveOnQueue.xC             = fileMessage.xC as NSNumber?
        messageToSaveOnQueue.yC             = fileMessage.yC as NSNumber?
        messageToSaveOnQueue.typeCode    = fileMessage.typeCode
        messageToSaveOnQueue.uniqueId    = fileMessage.uniqueId
        
//        if let metadata2 = fileMessage.metadata {
//            NSObject.convertJSONtoTransformable(dataToStore: metadata2) { (data) in
//                messageToSaveOnQueue.metadata = data
//            }
//        }
        messageToSaveOnQueue.metadata   = fileMessage.metadata
        
        // save function that will try to save changes that made on the Cache
        saveContext(subject: "Create QueueOfFileMessages -create a new object-")
    }
    
    func saveUploadImageToWaitQueue(image: QueueOfWaitUploadImagesModel) {
        let theWaitQueueEntity = NSEntityDescription.entity(forEntityName: "QueueOfUploadImages", in: context)
        let messageToSaveOnQueue = QueueOfUploadImages(entity: theWaitQueueEntity!, insertInto: context)
        messageToSaveOnQueue.dataToSend     = image.dataToSend as NSData?
        messageToSaveOnQueue.fileExtension  = image.fileExtension
        messageToSaveOnQueue.fileName       = image.fileName
        messageToSaveOnQueue.fileSize       = image.fileSize as NSNumber?
        messageToSaveOnQueue.isPublic       = image.isPublic as NSNumber?
        messageToSaveOnQueue.mimeType       = image.mimeType
        messageToSaveOnQueue.userGroupHash  = image.userGroupHash
        messageToSaveOnQueue.uniqueId       = image.uniqueId
        messageToSaveOnQueue.xC             = image.xC as NSNumber?
        messageToSaveOnQueue.yC             = image.yC as NSNumber?
        messageToSaveOnQueue.hC             = image.hC as NSNumber?
        messageToSaveOnQueue.wC             = image.wC as NSNumber?
        
        // save function that will try to save changes that made on the Cache
        saveContext(subject: "Create QueueOfUploadImages -create a new object-")
    }
    
    func saveUploadFileToWaitQueue(file: QueueOfWaitUploadFilesModel) {
        let theWaitQueueEntity = NSEntityDescription.entity(forEntityName: "QueueOfUploadFiles", in: context)
        let messageToSaveOnQueue = QueueOfUploadFiles(entity: theWaitQueueEntity!, insertInto: context)
        messageToSaveOnQueue.dataToSend     = file.dataToSend as NSData?
        messageToSaveOnQueue.fileExtension  = file.fileExtension
        messageToSaveOnQueue.fileName       = file.fileName
        messageToSaveOnQueue.fileSize       = file.fileSize as NSNumber?
        messageToSaveOnQueue.isPublic       = file.isPublic as NSNumber?
        messageToSaveOnQueue.mimeType       = file.mimeType
        messageToSaveOnQueue.userGroupHash  = file.userGroupHash
        messageToSaveOnQueue.uniqueId       = file.uniqueId
        
        // save function that will try to save changes that made on the Cache
        saveContext(subject: "Create QueueOfUploadFiles -create a new object-")
    }
    
    
    
    // MARK: - retrieve items from wait Queues
    func retrieveWaitTextMessages(threadId: Int) -> [QueueOfWaitTextMessagesModel]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "QueueOfTextMessages")
        
        // this predicate used to get messages that are in the specific thread using 'threadId' property
        let threadPredicate = NSPredicate(format: "threadId == %i", threadId)
        fetchRequest.predicate = threadPredicate
        
        do {
            if let result = try context.fetch(fetchRequest) as? [QueueOfTextMessages] {
                if (result.count > 0) {
                    
                    var messageArray = [QueueOfWaitTextMessagesModel]()
                    for item in result {
                        messageArray.append(item.convertCMObjectToObject())
                    }
                    return messageArray
                    
                }
                //                else {
                //                    return nil
                //                }
            }
            //            else {
            //                return nil
            //            }
        } catch {
            fatalError("Error on fetching list of QueueOfTextMessages")
        }
        return nil
    }
    
    func retrieveWaitEditMessages(threadId: Int) -> [QueueOfWaitEditMessagesModel]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "QueueOfEditMessages")
        
        // this predicate used to get messages that are in the specific thread using 'threadId' property
        let threadPredicate = NSPredicate(format: "threadId == %i", threadId)
        fetchRequest.predicate = threadPredicate
        
        do {
            if let result = try context.fetch(fetchRequest) as? [QueueOfEditMessages] {
                if (result.count > 0) {
                    
                    var messageArray = [QueueOfWaitEditMessagesModel]()
                    for item in result {
                        messageArray.append(item.convertCMObjectToObject())
                    }
                    return messageArray
                    
                }
            }
        } catch {
            fatalError("Error on fetching list of QueueOfEditMessages")
        }
        return nil
    }
    
    func retrieveWaitForwardMessages(threadId: Int) -> [QueueOfWaitForwardMessagesModel]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "QueueOfForwardMessages")
        
        // this predicate used to get messages that are in the specific thread using 'threadId' property
        let threadPredicate = NSPredicate(format: "threadId == %i", threadId)
        fetchRequest.predicate = threadPredicate
        
        do {
            if let result = try context.fetch(fetchRequest) as? [QueueOfForwardMessages] {
                if (result.count > 0) {
                    
                    var messageArray = [QueueOfWaitForwardMessagesModel]()
                    for item in result {
                        messageArray.append(item.convertCMObjectToObject())
                    }
                    return messageArray
                    
                }
            }
        } catch {
            fatalError("Error on fetching list of QueueOfForwardMessages")
        }
        return nil
    }
    
    func retrieveWaitFileMessages(threadId: Int) -> [QueueOfWaitFileMessagesModel]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "QueueOfFileMessages")
        
        // this predicate used to get messages that are in the specific thread using 'threadId' property
        let threadPredicate = NSPredicate(format: "threadId == %i", threadId)
        fetchRequest.predicate = threadPredicate
        
        do {
            if let result = try context.fetch(fetchRequest) as? [QueueOfFileMessages] {
                if (result.count > 0) {
                    
                    var messageArray = [QueueOfWaitFileMessagesModel]()
                    for item in result {
                        messageArray.append(item.convertCMObjectToObject())
                    }
                    return messageArray
                    
                }
            }
        } catch {
            fatalError("Error on fetching list of QueueOfFileMessages")
        }
        return nil
    }
    
    func retrieveWaitUploadImages(threadId: Int) -> [QueueOfWaitUploadImagesModel]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "QueueOfUploadImages")
        
        // this predicate used to get messages that are in the specific thread using 'threadId' property
        let threadPredicate = NSPredicate(format: "threadId == %i", threadId)
        fetchRequest.predicate = threadPredicate
        
        do {
            if let result = try context.fetch(fetchRequest) as? [QueueOfUploadImages] {
                if (result.count > 0) {
                    
                    var messageArray = [QueueOfWaitUploadImagesModel]()
                    for item in result {
                        messageArray.append(item.convertCMObjectToObject())
                    }
                    return messageArray
                    
                }
            }
        } catch {
            fatalError("Error on fetching list of QueueOfFileMessages")
        }
        return nil
    }
    
    func retrieveWaitUploadFiles(threadId: Int) -> [QueueOfWaitUploadFilesModel]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "QueueOfUploadFiles")
        
        // this predicate used to get messages that are in the specific thread using 'threadId' property
        let threadPredicate = NSPredicate(format: "threadId == %i", threadId)
        fetchRequest.predicate = threadPredicate
        
        do {
            if let result = try context.fetch(fetchRequest) as? [QueueOfUploadFiles] {
                if (result.count > 0) {
                    
                    var messageArray = [QueueOfWaitUploadFilesModel]()
                    for item in result {
                        messageArray.append(item.convertCMObjectToObject())
                    }
                    return messageArray
                    
                }
            }
        } catch {
            fatalError("Error on fetching list of QueueOfFileMessages")
        }
        return nil
    }
    
    
    
    // MARK: - delete items from the wait Queues
    func deleteWaitTextMessage(uniqueId: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "QueueOfTextMessages")
        
        // this predicate used to get messages that are in the specific thread using 'threadId' property
        let threadPredicate = NSPredicate(format: "uniqueId == %@", uniqueId)
        fetchRequest.predicate = threadPredicate
        
        do {
            if let result = try context.fetch(fetchRequest) as? [QueueOfTextMessages] {
                if (result.count > 0) {
                    deleteAndSave(object: result.first!, withMessage: "QueueOfTextMessages object Deleted from cache")
                }
            }
        } catch {
            fatalError("Error on fetching list of QueueOfTextMessages with uniqueId")
        }
    }
    
    func deleteWaitEditMessage(uniqueId: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "QueueOfEditMessages")
        
        // this predicate used to get messages that are in the specific thread using 'threadId' property
        let threadPredicate = NSPredicate(format: "uniqueId == %@", uniqueId)
        fetchRequest.predicate = threadPredicate
        
        do {
            if let result = try context.fetch(fetchRequest) as? [QueueOfEditMessages] {
                if (result.count > 0) {
                    deleteAndSave(object: result.first!, withMessage: "QueueOfEditMessages object Deleted from cache")
                }
            }
        } catch {
            fatalError("Error on fetching list of QueueOfEditMessages with uniqueId")
        }
    }
    
    func deleteWaitForwardMessage(uniqueId: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "QueueOfForwardMessages")
        
        // this predicate used to get messages that are in the specific thread using 'threadId' property
        let threadPredicate = NSPredicate(format: "uniqueId == %@", uniqueId)
        fetchRequest.predicate = threadPredicate
        
        do {
            if let result = try context.fetch(fetchRequest) as? [QueueOfForwardMessages] {
                if (result.count > 0) {
                    deleteAndSave(object: result.first!, withMessage: "QueueOfForwardMessages object Deleted from cache")
                }
            }
        } catch {
            fatalError("Error on fetching list of QueueOfForwardMessages with uniqueId")
        }
    }
    
    func deleteWaitFileMessage(uniqueId: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "QueueOfFileMessages")
        
        // this predicate used to get messages that are in the specific thread using 'threadId' property
        let threadPredicate = NSPredicate(format: "uniqueId == %@", uniqueId)
        fetchRequest.predicate = threadPredicate
        
        do {
            if let result = try context.fetch(fetchRequest) as? [QueueOfFileMessages] {
                if (result.count > 0) {
                    deleteAndSave(object: result.first!, withMessage: "QueueOfFileMessages object Deleted from cache")
                }
            }
        } catch {
            fatalError("Error on fetching list of QueueOfFileMessages with uniqueId")
        }
    }
    
    func deleteWaitUploadImages(uniqueId: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "QueueOfUploadImages")
        
        // this predicate used to get messages that are in the specific thread using 'threadId' property
        let threadPredicate = NSPredicate(format: "uniqueId == %@", uniqueId)
        fetchRequest.predicate = threadPredicate
        
        do {
            if let result = try context.fetch(fetchRequest) as? [QueueOfUploadImages] {
                if (result.count > 0) {
                    deleteAndSave(object: result.first!, withMessage: "QueueOfUploadImages object Deleted from cache")
                }
            }
        } catch {
            fatalError("Error on fetching list of QueueOfUploadImages with uniqueId")
        }
    }
    
    func deleteWaitUploadFiles(uniqueId: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "QueueOfUploadFiles")
        
        // this predicate used to get messages that are in the specific thread using 'threadId' property
        let threadPredicate = NSPredicate(format: "uniqueId == %@", uniqueId)
        fetchRequest.predicate = threadPredicate
        
        do {
            if let result = try context.fetch(fetchRequest) as? [QueueOfUploadFiles] {
                if (result.count > 0) {
                    deleteAndSave(object: result.first!, withMessage: "QueueOfUploadFiles object Deleted from cache")
                }
            }
        } catch {
            fatalError("Error on fetching list of QueueOfUploadFiles with uniqueId")
        }
    }
    
    
    
    // MARK: - delete all items from some wait Queues
    func deleteAllWaitTextMessage() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "QueueOfTextMessages")
        do {
            if let result = try context.fetch(fetchRequest) as? [QueueOfTextMessages] {
                for (index, _) in result.enumerated() {
                    deleteAndSave(object: result[index], withMessage: "QueueOfTextMessages object Deleted from cache")
                }
            }
        } catch {
            fatalError("Error on fetching list of QueueOfTextMessages with uniqueId")
        }
    }
    
    func deleteAllWaitForwardMessage() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "QueueOfForwardMessages")
        do {
            if let result = try context.fetch(fetchRequest) as? [QueueOfForwardMessages] {
                for (index, _) in result.enumerated() {
                    deleteAndSave(object: result[index], withMessage: "QueueOfForwardMessages object Deleted from cache")
                }
            }
        } catch {
            fatalError("Error on fetching list of QueueOfForwardMessages with uniqueId")
        }
    }
    
    func deleteAllWaitFileMessage() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "QueueOfFileMessages")
        do {
            if let result = try context.fetch(fetchRequest) as? [QueueOfFileMessages] {
                for (index, _) in result.enumerated() {
                    deleteAndSave(object: result[index], withMessage: "QueueOfFileMessages object Deleted from cache")
                }
            }
        } catch {
            fatalError("Error on fetching list of QueueOfFileMessages with uniqueId")
        }
    }
    
    func deleteAllWaitUploadImages() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "QueueOfUploadImages")
        do {
            if let result = try context.fetch(fetchRequest) as? [QueueOfUploadImages] {
                for (index, _) in result.enumerated() {
                    deleteAndSave(object: result[index], withMessage: "QueueOfUploadImages object Deleted from cache")
                }
            }
        } catch {
            fatalError("Error on fetching list of QueueOfFileMessages with uniqueId")
        }
    }
    
    func deleteAllWaitUploadFiles() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "QueueOfUploadFiles")
        do {
            if let result = try context.fetch(fetchRequest) as? [QueueOfUploadFiles] {
                for (index, _) in result.enumerated() {
                    deleteAndSave(object: result[index], withMessage: "QueueOfUploadFiles object Deleted from cache")
                }
            }
        } catch {
            fatalError("Error on fetching list of QueueOfUploadFiles with uniqueId")
        }
    }
    
    func deleteAllWaitEditMessage() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "QueueOfEditMessages")
        do {
            if let result = try context.fetch(fetchRequest) as? [QueueOfEditMessages] {
                for (index, _) in result.enumerated() {
                    deleteAndSave(object: result[index], withMessage: "QueueOfEditMessages object Deleted from cache")
                }
            }
        } catch {
            fatalError("Error on fetching list of QueueOfEditMessages with uniqueId")
        }
    }
    
    
    
    // MARK: - delete all wait Queues
    func deleteAllWaitQueues() {
        deleteAllWaitTextMessage()
        deleteAllWaitFileMessage()
        deleteAllWaitUploadImages()
        deleteAllWaitUploadFiles()
        deleteAllWaitEditMessage()
        deleteAllWaitForwardMessage()
    }
    
    
}
