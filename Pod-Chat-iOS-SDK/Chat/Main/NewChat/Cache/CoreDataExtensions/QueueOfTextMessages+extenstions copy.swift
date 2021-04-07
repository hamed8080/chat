//
//  QueueOfTextMessages+extenstions.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/2/21.
//

import Foundation

extension QueueOfTextMessages{
    
    public static let crud = CoreDataCrud<QueueOfTextMessages>(entityName: "QueueOfTextMessages")
    
    public func getCodable() -> NewSendTextMessageRequest?{
        guard let threadId = threadId as? Int , let textMessage = textMessage , let messageType  = messageType as? Int else {return nil}
        return NewSendTextMessageRequest(threadId: threadId ,
                                         textMessage: textMessage,
                                         messageType: MessageType(rawValue: messageType) ?? .TEXT,
                                         metadata: metadata,
                                         repliedTo: repliedTo as? Int,
                                         systemMetadata: systemMetadata,
                                         uniqueId: uniqueId
                                         )
    }
    
    public class func convertToCM(request:NewSendTextMessageRequest  ,entity:QueueOfTextMessages? = nil) -> QueueOfTextMessages{
        
        let model            = entity ?? QueueOfTextMessages()
        model.threadId       = request.threadId as NSNumber?
        model.messageType    = request.messageType.rawValue as NSNumber?
        model.textMessage    = request.textMessage
        model.repliedTo      = request.repliedTo as NSNumber?
        model.typeCode       = request.typeCode
        model.uniqueId       = request.uniqueId
        model.systemMetadata = request.systemMetadata
        model.metadata       = request.metadata
        
        return model
    }
    
    public class func insert(request:NewSendTextMessageRequest , resultEntity:((QueueOfTextMessages)->())? = nil){
        if let entity = QueueOfTextMessages.crud.find(keyWithFromat: "uniqueId == %@", value: request.uniqueId){
            resultEntity?(entity)
            return
        }
        QueueOfTextMessages.crud.insert { cmEntity in
            let cmEntity = convertToCM(request: request, entity: cmEntity)
            resultEntity?(cmEntity)
        }
    }
    
}
