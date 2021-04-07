//
//  CMMutualGroup+extenstions.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/2/21.
//

import Foundation

extension CMMutualGroup{
    
    public static let crud = CoreDataCrud<CMMutualGroup>(entityName: "CMMutualGroup")
    
    class func convertMutualGroupToCM(conversation:Conversation , req:MutualGroupsRequest ,entity:CMMutualGroup? = nil) -> CMMutualGroup{
        let model                              = entity ?? CMMutualGroup()
        model.idType                           = req.toBeUserVO.idType as NSNumber?
        model.mutualId                         = req.toBeUserVO.id
        CMConversation.insertOrUpdate(conversations: [conversation]) { conversationEntity in
            model.conversation = conversationEntity
        }
        return model
    }
    
    public class func insertOrUpdate(conversations:[Conversation] , req:MutualGroupsRequest , resultEntity:((CMMutualGroup)->())? = nil){
		conversations.forEach { conversation in
            if let findedEntity = CMMutualGroup.crud.fetchWith(NSPredicate(format: "mutualId == %@ AND idType == %i", req.toBeUserVO.id! , req.toBeUserVO.id!))?.first{
                let cmConversation = convertMutualGroupToCM(conversation: conversation, req: req, entity: findedEntity)
                resultEntity?(cmConversation)
            }else{
                CMMutualGroup.crud.insert { entity in
                    let cmConversation = convertMutualGroupToCM(conversation: conversation , req: req, entity: entity)
                    resultEntity?(cmConversation)
                }
            }
        }
    }
    
	public class func getMutualGroups(_ req: MutualGroupsRequest)->[Conversation]{
        guard let mutualId = req.toBeUserVO.id , let idType = req.toBeUserVO.idType else {return []}
        let predicate = NSPredicate(format: "mutualId == %@ AND idType == %i", mutualId , idType)
        let conversationsWithMutual = CMMutualGroup.crud.fetchWithOffset(count: req.count, offset: req.offset, predicate: predicate)
        let conversations = conversationsWithMutual.compactMap{$0.conversation?.getCodable()}
        return conversations
	}
}
