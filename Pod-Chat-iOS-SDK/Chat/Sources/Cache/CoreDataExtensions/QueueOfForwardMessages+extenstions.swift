//
//  QueueOfForwardMessages+extenstions.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/2/21.
//

import Foundation

extension QueueOfForwardMessages{
    
    public static let crud = CoreDataCrud<QueueOfForwardMessages>(entityName: "QueueOfForwardMessages")
    
    public func getCodable() -> ForwardMessageRequest?{
        guard let threadId = threadId as? Int, let messageId = messageId as? Int else{return nil}
        return ForwardMessageRequest(
            threadId:threadId,
            messageId: messageId,
            typeCode: typeCode,
            uniqueId: uniqueId
        )
    }
    
    public class func convertToCM(request:ForwardMessageRequest , messageId:Int ,entity:QueueOfForwardMessages? = nil) -> QueueOfForwardMessages{
        
        let model            = entity ?? QueueOfForwardMessages()
        model.threadId       = request.threadId as NSNumber?
        model.messageId      = messageId as NSNumber?
        model.repliedTo      = nil
        model.typeCode       = request.typeCode
        model.uniqueId       = request.uniqueId
        
        return model
    }
    
    public class func insert(request:ForwardMessageRequest , resultEntity:((QueueOfForwardMessages)->())? = nil){
        for(index,messageId) in request.messageIds.enumerated(){
            if let entity = QueueOfForwardMessages.crud.find(keyWithFromat: "uniqueId == %@", value: request.uniqueId){
                resultEntity?(entity)
                
            }else{
                QueueOfForwardMessages.crud.insert { cmEntity in
                    let cmEntity = convertToCM(request: request , messageId: messageId , entity: cmEntity)
                    cmEntity.uniqueId = request.uniqueIds[index]
                    resultEntity?(cmEntity)
                }
            }
        }
    }
    
    class func getCodableForwardResuest(threadId:Int)->[ForwardMessageRequest]{
        var requests:[ForwardMessageRequest] = []
        crud.fetchWith(NSPredicate(format: "threadId == %i" , threadId))?.forEach({ entity in
            if let codable  = entity.getCodable(){
                requests.append(codable)
            }
        })
        return requests
    }
}
