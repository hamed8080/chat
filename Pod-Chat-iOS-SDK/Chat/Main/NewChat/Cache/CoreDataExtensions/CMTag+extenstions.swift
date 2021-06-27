//
//  CMTag+extenstions.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/2/21.
//

import Foundation

extension CMTag{
    
    public static let crud = CoreDataCrud<CMTag>(entityName: "CMTag")
    
    public func getCodable() -> Tag?{
        return Tag(id: id as! Int,
                   name: name,
                   owner: owner.getCodable(),
                   active: Bool(exactly: active) ?? false,
                   tagParticipants: tagParticipants?.compactMap{$0.getCodable()} ?? []
        )
    }
    
    public class func convertToCM(tag:Tag ,entity:CMTag? = nil) -> CMTag{
        let model           = entity ?? CMTag()
        
        model.id            = tag.id as NSNumber?
        model.name          = tag.name
        model.active        = tag.active as NSNumber
        
        if let tagParticipants = tag.tagParticipants{
            tagParticipants.forEach { tagParticipant in
                CMTagParticipant.insertOrUpdate(tagParticipant: tagParticipant , tagId: tag.id){ resultEntity in
                    model.tagParticipants?.insert(resultEntity)
                }
            }
        }
        
        CMParticipant.insertOrUpdate(participant: tag.owner){ resultEntity in
            model.owner = resultEntity
        }
        
        return model
    }
    
    public class func insertOrUpdate(tags:[Tag], resultEntity:((CMTag)->())? = nil){
        tags.forEach { tag in
            if let findedEntity = CMTag.crud.find(keyWithFromat: "id == %i", value: tag.id){
                let cmTag = convertToCM(tag: tag , entity: findedEntity)
                resultEntity?(cmTag)
            }else{
                CMTag.crud.insert { cmTagEntity in
                    let cmTag = convertToCM(tag: tag, entity: cmTagEntity)
                    resultEntity?(cmTag)
                }
            }
        }
    }
}
