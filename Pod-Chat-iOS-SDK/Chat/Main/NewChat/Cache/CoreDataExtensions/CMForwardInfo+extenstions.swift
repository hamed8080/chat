//
//  CMForwardInfo+extenstions.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/2/21.
//

import Foundation

extension CMForwardInfo{
    
    public static let crud = CoreDataCrud<CMForwardInfo>(entityName: "CMForwardInfo")
    
    public func getCodable() -> ForwardInfo{
		return ForwardInfo(conversation: conversation?.getCodable(),
						   participant: participant?.getCodable())
    }
    
    public class func convertForwardInfoToCM(forwardInfo:ForwardInfo ,messageId:Int?, threadId:Int? ,entity:CMForwardInfo? = nil) -> CMForwardInfo{
        
        let model        = entity ?? CMForwardInfo()
        model.messageId = messageId as NSNumber?
        if let participant = forwardInfo.participant{
            CMParticipant.insertOrUpdate(participant: participant, threadId: threadId){ resultEntity in
                model.participant = resultEntity
            }
        }
        
        if let conversation = forwardInfo.conversation{
            CMConversation.insertOrUpdate(conversations: [conversation]){ resultEntity in
                model.conversation = resultEntity
            }
        }
        return model
    }
    
    public class func insertOrUpdate(forwardInfo:ForwardInfo , messageId:Int? , threadId:Int?, resultEntity:((CMForwardInfo)->())? = nil){
        
		if let messageId = messageId, let findedEntity = CMForwardInfo.crud.find(keyWithFromat: "messageId == %i", value: messageId){
            let cmForwardInfo = convertForwardInfoToCM(forwardInfo: forwardInfo,messageId: messageId , threadId: threadId , entity: findedEntity)
            resultEntity?(cmForwardInfo)
        }else{
			CMForwardInfo.crud.insert { cmForwardInfoEntity in
               let cmForwardInfo = convertForwardInfoToCM(forwardInfo: forwardInfo , messageId: messageId , threadId: threadId , entity: cmForwardInfoEntity)
                resultEntity?(cmForwardInfo)
            }
        }
        
    }
}
