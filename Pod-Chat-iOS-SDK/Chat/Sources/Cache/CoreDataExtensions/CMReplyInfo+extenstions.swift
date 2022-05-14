//
//  CMReplyInfo+extenstions.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/2/21.
//

import Foundation

extension CMReplyInfo{
    
    public static let crud = CoreDataCrud<CMReplyInfo>(entityName: "CMReplyInfo")
    
    public func getCodable() -> ReplyInfo{
		return  ReplyInfo(deleted: isDeleted,
						  repliedToMessageId: repliedToMessageId as? Int,
						  message:         message,
						  messageType:     messageType as? Int,
						  metadata:        metadata,
						  systemMetadata:  systemMetadata,
						  time:            time as? UInt,
						  participant:     participant?.getCodable())
    }
    
    public class func convertReplyInfoToCM(replyInfo:ReplyInfo , messageId:Int? , threadId:Int? ,entity:CMReplyInfo? = nil) -> CMReplyInfo{
        let model          = entity ?? CMReplyInfo()
		model.messageId          = messageId as NSNumber?
		model.deletedd           = replyInfo.deleted as NSNumber?
		model.message            = replyInfo.message
		model.messageType        = replyInfo.messageType as NSNumber?
		model.metadata           = replyInfo.metadata
		model.repliedToMessageId = replyInfo.repliedToMessageId as NSNumber?
		model.systemMetadata     = replyInfo.systemMetadata
		model.time               = replyInfo.time as NSNumber?
        if let participant = replyInfo.participant{
            CMParticipant.insertOrUpdate(participant: participant, threadId: threadId){ resultEntity in
                model.participant = resultEntity
            }
        }
        return model
    }
    
    public class func insertOrUpdate(replyInfo:ReplyInfo , messageId:Int?, threadId:Int?, resultEntity:((CMReplyInfo)->())? = nil){
        
		if let messageId = messageId, let findedEntity = CMReplyInfo.crud.find(keyWithFromat: "messageId == %i", value: messageId){
            let cmReplyInfo = convertReplyInfoToCM(replyInfo: replyInfo, messageId: messageId, threadId: threadId, entity: findedEntity)
            resultEntity?(cmReplyInfo)
        }else{
			CMReplyInfo.crud.insert { cmLinkedUserEntity in
                let cmLinkedUser = convertReplyInfoToCM(replyInfo: replyInfo, messageId: messageId, threadId: threadId, entity: cmLinkedUserEntity)
                resultEntity?(cmLinkedUser)
            }
        }
        
    }
}
