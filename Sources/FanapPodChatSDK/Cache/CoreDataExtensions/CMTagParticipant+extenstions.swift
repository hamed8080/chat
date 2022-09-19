//
//  CMTagParticipant+extenstions.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/2/21.
//

import Foundation

extension CMTagParticipant{
    
    public static let crud = CoreDataCrud<CMTagParticipant>(entityName: "CMTagParticipant")
    
    public func getCodable() -> TagParticipant?{
        return TagParticipant(id: id as? Int,
                              active: active as? Bool,
                              tagId: tagId as? Int,
                              threadId: threadId as? Int,
                              conversation: conversation?.getCodable()
        )
    }
    
    public class func convertToCM(tagParticipant:TagParticipant , tagId:Int ,entity:CMTagParticipant? = nil) -> CMTagParticipant{
        let model           = entity ?? CMTagParticipant()
        model.id            = tagParticipant.id as NSNumber?
        model.active        = tagParticipant.active as NSNumber?
        model.tagId         = tagParticipant.tagId as NSNumber? ?? tagId as NSNumber?
        model.threadId      = tagParticipant.threadId as NSNumber?
        
        if let conversation = tagParticipant.conversation{
            CMConversation.insertOrUpdate(conversations: [conversation]){ resultEntity in
                model.conversation = resultEntity
            }
        }
        
        return model
    }
    
    public class func insertOrUpdate(tagParticipant:TagParticipant,tagId:Int, resultEntity:((CMTagParticipant)->())? = nil){
            if let id = tagParticipant.id , let findedEntity = CMTagParticipant.crud.find(keyWithFromat: "id == %i", value: id){
                let cmTagParticipant = convertToCM(tagParticipant: tagParticipant , tagId:tagId , entity: findedEntity)
                resultEntity?(cmTagParticipant)
            }else{
                CMTagParticipant.crud.insert { cmTagParticipantEntity in
                    let cmTagParticipant = convertToCM(tagParticipant: tagParticipant,tagId: tagId, entity: cmTagParticipantEntity)
                    resultEntity?(cmTagParticipant)
                }
            }
    }
}
