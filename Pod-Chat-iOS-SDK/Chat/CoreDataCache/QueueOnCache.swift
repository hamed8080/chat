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
    
    func saveTextMessageToWaitQueue(textMessage: QueueOfWaitTextMessagesModel) {
        let theWaitQueueEntity = NSEntityDescription.entity(forEntityName: "QueueOfTextMessages", in: context)
        let messageToSaveOnQueue = QueueOfTextMessages(entity: theWaitQueueEntity!, insertInto: context)
        messageToSaveOnQueue.content        = textMessage.content
        messageToSaveOnQueue.repliedTo      = textMessage.repliedTo as NSNumber?
        messageToSaveOnQueue.threadId       = textMessage.threadId as NSNumber?
        messageToSaveOnQueue.typeCode       = textMessage.typeCode
        messageToSaveOnQueue.uniqueId       = textMessage.uniqueId
        
        if let metaData2 = textMessage.metaData {
            NSObject.convertJSONtoTransformable(dataToStore: metaData2) { (data) in
                messageToSaveOnQueue.metaData = data
            }
        }
        
        if let systemMetadata2 = textMessage.systemMetadata {
            NSObject.convertJSONtoTransformable(dataToStore: systemMetadata2) { (data) in
                messageToSaveOnQueue.systemMetadata = data
            }
        }
        
        // save function that will try to save changes that made on the Cache
        saveContext(subject: "Create QueueOfTextMessages -create a new object-")
    }
    
    func saveFileMessageToWaitQueue(fileMessage: QueueOfWaitFileMessagesModel) {
        let theWaitQueueEntity = NSEntityDescription.entity(forEntityName: "QueueOfFileMessages", in: context)
        let messageToSaveOnQueue = QueueOfFileMessages(entity: theWaitQueueEntity!, insertInto: context)
        messageToSaveOnQueue.content        = fileMessage.content
        messageToSaveOnQueue.fileName       = fileMessage.fileName
        messageToSaveOnQueue.fileToSend     = fileMessage.fileToSend as NSData?
        messageToSaveOnQueue.imageName      = fileMessage.imageName
        messageToSaveOnQueue.imageToSend    = fileMessage.imageToSend as NSData?
        messageToSaveOnQueue.repliedTo      = fileMessage.repliedTo as NSNumber?
        messageToSaveOnQueue.subjectId      = fileMessage.subjectId as NSNumber?
        messageToSaveOnQueue.threadId       = fileMessage.threadId as NSNumber?
        messageToSaveOnQueue.typeCode       = fileMessage.typeCode
        messageToSaveOnQueue.uniqueId       = fileMessage.uniqueId
        messageToSaveOnQueue.hC             = fileMessage.hC
        messageToSaveOnQueue.wC             = fileMessage.wC
        messageToSaveOnQueue.xC             = fileMessage.xC
        messageToSaveOnQueue.yC             = fileMessage.yC
        
        if let metaData2 = fileMessage.metaData {
            NSObject.convertJSONtoTransformable(dataToStore: metaData2) { (data) in
                messageToSaveOnQueue.metaData = data
            }
        }
        
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
        messageToSaveOnQueue.originalFileName = image.originalFileName
        messageToSaveOnQueue.threadId       = image.threadId as NSNumber?
        messageToSaveOnQueue.uniqueId       = image.uniqueId
        messageToSaveOnQueue.xC             = image.xC as NSNumber?
        messageToSaveOnQueue.yC             = image.yC as NSNumber?
        messageToSaveOnQueue.hC             = image.hC as NSNumber?
        messageToSaveOnQueue.wC             = image.wC as NSNumber?
        
        // save function that will try to save changes that made on the Cache
        saveContext(subject: "Create QueueOfImages -create a new object-")
    }
    
    func saveUploadFileToWaitQueue(file: QueueOfWaitUploadFilesModel) {
        let theWaitQueueEntity = NSEntityDescription.entity(forEntityName: "QueueOfUploadFiles", in: context)
        let messageToSaveOnQueue = QueueOfUploadFiles(entity: theWaitQueueEntity!, insertInto: context)
        messageToSaveOnQueue.dataToSend     = file.dataToSend as NSData?
        messageToSaveOnQueue.fileExtension  = file.fileExtension
        messageToSaveOnQueue.fileName       = file.fileName
        messageToSaveOnQueue.fileSize       = file.fileSize as NSNumber?
        messageToSaveOnQueue.originalFileName = file.originalFileName
        messageToSaveOnQueue.threadId       = file.threadId as NSNumber?
        messageToSaveOnQueue.uniqueId       = file.uniqueId
        
        // save function that will try to save changes that made on the Cache
        saveContext(subject: "Create QueueOfUploadFiles -create a new object-")
    }
    
    func saveEditMessageToWaitQueue(editMessage: QueueOfWaitEditMessagesModel) {
        let theWaitQueueEntity = NSEntityDescription.entity(forEntityName: "QueueOfEditMessages", in: context)
        let messageToSaveOnQueue = QueueOfEditMessages(entity: theWaitQueueEntity!, insertInto: context)
        messageToSaveOnQueue.content    = editMessage.content
        messageToSaveOnQueue.repliedTo  = editMessage.repliedTo as NSNumber?
        messageToSaveOnQueue.subjectId  = editMessage.subjectId as NSNumber?
        messageToSaveOnQueue.typeCode   = editMessage.typeCode
        messageToSaveOnQueue.uniqueId   = editMessage.uniqueId
        
        if let metaData2 = editMessage.metaData {
            NSObject.convertJSONtoTransformable(dataToStore: metaData2) { (data) in
                messageToSaveOnQueue.metaData = data
            }
        }
        
        // save function that will try to save changes that made on the Cache
        saveContext(subject: "Create QueueOfEditMessages -create a new object-")
    }
    
    func saveForwardMessageToWaitQueue(forwardMessage: QueueOfWaitForwardMessagesModel) {
        let theWaitQueueEntity = NSEntityDescription.entity(forEntityName: "QueueOfForwardMessages", in: context)
        let messageToSaveOnQueue = QueueOfForwardMessages(entity: theWaitQueueEntity!, insertInto: context)
        messageToSaveOnQueue.messageIds = forwardMessage.messageIds as [NSNumber]?
        messageToSaveOnQueue.repliedTo  = forwardMessage.repliedTo as NSNumber?
        messageToSaveOnQueue.subjectId  = forwardMessage.subjectId as NSNumber?
        messageToSaveOnQueue.typeCode   = forwardMessage.typeCode
        messageToSaveOnQueue.uniqueId   = forwardMessage.uniqueId
        
        if let metaData2 = forwardMessage.metaData {
            NSObject.convertJSONtoTransformable(dataToStore: metaData2) { (data) in
                messageToSaveOnQueue.metaData = data
            }
        }
        
        // save function that will try to save changes that made on the Cache
        saveContext(subject: "Create QueueOfForwardMessages -create a new object-")
    }
    
    
    
    
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
                        messageArray.append(item.convertQueueOfTextMessagesToQueueOfWaitTextMessagesModelObject())
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
                        messageArray.append(item.convertQueueOfFileMessagesToQueueOfWaitFileMessagesModelObject())
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
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "QueueOfImages")
        
        // this predicate used to get messages that are in the specific thread using 'threadId' property
        let threadPredicate = NSPredicate(format: "threadId == %i", threadId)
        fetchRequest.predicate = threadPredicate
        
        do {
            if let result = try context.fetch(fetchRequest) as? [QueueOfUploadImages] {
                if (result.count > 0) {
                    
                    var messageArray = [QueueOfWaitUploadImagesModel]()
                    for item in result {
                        messageArray.append(item.convertQueueOfUploadImagesToQueueOfWaitUploadImagesModelObject())
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
                        messageArray.append(item.convertQueueOfUploadFilesToQueueOfWaitUploadFilesModelObject())
                    }
                    return messageArray
                    
                }
            }
        } catch {
            fatalError("Error on fetching list of QueueOfFileMessages")
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
                        messageArray.append(item.convertQueueOfEditMessagesToQueueOfWaitEditMessagesModelObject())
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
                        messageArray.append(item.convertQueueOfForwardMessagesToQueueOfWaitForwardMessagesModelObject())
                    }
                    return messageArray
                    
                }
            }
        } catch {
            fatalError("Error on fetching list of QueueOfForwardMessages")
        }
        return nil
    }
    
    
    
    
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
    
    
}
