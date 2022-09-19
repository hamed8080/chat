//
//  QueueOfFileMessages+extenstions.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/2/21.
//

import Foundation

extension QueueOfFileMessages{
    
    public static let crud = CoreDataCrud<QueueOfFileMessages>(entityName: "QueueOfFileMessages")
    
    public func getCodable() -> (UploadFileRequest , SendTextMessageRequest)?{
        
        guard let threadId = threadId as? Int , let textMessage = textMessage , let messageType  = messageType as? Int else {return nil}
        let textMessageRequest = SendTextMessageRequest(threadId: threadId, textMessage: textMessage, messageType: MessageType(rawValue: messageType) ?? .POD_SPACE_FILE)
        
        if let imageData = imageToSend as Data?{
            //is image upload file
            let uploadRequest = UploadImageRequest(data: imageData,
                                                      xC: (xC as? Int) ?? 0,
                                                      yC: (yC as? Int) ?? 0,
                                                      hC: (hC as? Int) ?? 0,
                                                      wC: (wC as? Int) ?? 0,
                                                      fileExtension: fileExtension,
                                                      fileName: fileName,
                                                      mimeType: mimeType,
                                                      originalName: originalName,
                                                      userGroupHash: userGroupHash,
                                                      uniqueId: uniqueId)
            return ( uploadRequest , textMessageRequest)
        }else{
            //any file upload
            guard let fileData = fileToSend as Data? else{return nil}
            let uploadRequest = UploadFileRequest(data: fileData,
                                                      fileExtension: fileExtension,
                                                      fileName: fileName,
                                                      mimeType: mimeType,
                                                      originalName: originalName,
                                                      userGroupHash: userGroupHash,
                                                      uniqueId: uniqueId)
            return ( uploadRequest , textMessageRequest)
        }
    }
    
    public class func convertFileToCM(request:UploadFileRequest , textMessage:SendTextMessageRequest ,entity:QueueOfFileMessages? = nil) -> QueueOfFileMessages{
        
        let model            = entity ?? QueueOfFileMessages()
        
        model.textMessage   = textMessage.textMessage
        model.messageType   = textMessage.messageType.rawValue as NSNumber?
        model.metadata      = textMessage.metadata
        model.repliedTo     = textMessage.repliedTo as NSNumber?
        model.threadId      = textMessage.threadId as NSNumber?
        model.uniqueId      = textMessage.uniqueId
            
        model.imageToSend   = request.data as NSData
        model.fileExtension = request.fileExtension
        model.fileName      = request.fileName
        model.isPublic      = request.isPublic as NSNumber?
        model.mimeType      = request.mimeType
        model.originalName  = request.originalName
        model.userGroupHash = request.userGroupHash
        model.typeCode      = Chat.sharedInstance.config?.typeCode
      
        return model
    }
    
    public class func convertImageToCM(request:UploadImageRequest , textMessage:SendTextMessageRequest ,entity:QueueOfFileMessages? = nil) -> QueueOfFileMessages{
        
        let model            = entity ?? QueueOfFileMessages()
        
        model.textMessage   = textMessage.textMessage
        model.messageType   = textMessage.messageType.rawValue as NSNumber?
        model.metadata      = textMessage.metadata
        model.repliedTo     = textMessage.repliedTo as NSNumber?
        model.threadId      = textMessage.threadId as NSNumber?
        model.uniqueId      = textMessage.uniqueId
        
        model.imageToSend   = request.data as NSData
        model.fileExtension = request.fileExtension
        model.fileName      = request.fileName
        model.isPublic      = request.isPublic as NSNumber?
        model.mimeType      = request.mimeType
        model.originalName  = request.originalName
        model.userGroupHash = request.userGroupHash
        model.xC            = request.xC as NSNumber?
        model.yC            = request.yC as NSNumber?
        model.hC            = request.hC as NSNumber?
        model.wC            = request.wC as NSNumber?
        model.typeCode      = Chat.sharedInstance.config?.typeCode
        
        return model
    }
    
    public class func insert(request:UploadFileRequest , textMessage:SendTextMessageRequest , resultEntity:((QueueOfFileMessages)->())? = nil){
        
        if let entity = QueueOfFileMessages.crud.find(keyWithFromat: "uniqueId == %@", value: request.uniqueId){
            resultEntity?(entity)
            return
        }
        if let imageRequest = request as? UploadImageRequest{
            QueueOfFileMessages.crud.insert { cmEntity in
                let cmEntity = convertImageToCM(request: imageRequest, textMessage: textMessage, entity: cmEntity)
                resultEntity?(cmEntity)
            }
        }else{
            QueueOfFileMessages.crud.insert { cmEntity in
                let cmEntity = convertFileToCM(request: request, textMessage: textMessage, entity: cmEntity)
                resultEntity?(cmEntity)
            }
        }
    }
    
}
