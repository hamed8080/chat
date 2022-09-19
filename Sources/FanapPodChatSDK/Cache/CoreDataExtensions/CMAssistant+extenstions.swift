//
//  CMAssistant+extenstions.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/2/21.
//

import Foundation

extension CMAssistant{
    
    public static let crud = CoreDataCrud<CMAssistant>(entityName: "CMAssistant")
    
    public func getCodable() -> Assistant?{
        var assistant:Invitee? = nil
        if let data = self.assistant , let decodedAssistant = try? JSONDecoder().decode(Invitee.self, from: data as Data){
            assistant = decodedAssistant
        }
        return Assistant(assistant: assistant,
                         contactType: contactType,
                         participant: participant?.getCodable(),
                         block: block as? Bool ?? false,
                         roleTypes: roles?.compactMap{Roles.init(rawValue: $0)} )
    }
    
    public class func convertToCM(assistant:Assistant ,entity:CMAssistant? = nil) -> CMAssistant{
        let model           = entity ?? CMAssistant()
        model.inviteeId     = assistant.participant?.id as NSNumber?
        model.contactType   = assistant.contactType
        model.block         = assistant.block as NSNumber
        if let assistant = assistant.assistant{
            model.assistant  = (try? JSONEncoder().encode(assistant)) as NSData?
        }
        if let participant = assistant.participant{
            CMParticipant.insertOrUpdate(participant: participant, threadId: nil){ resultEntity in
                model.participant = resultEntity
            }
        }
        model.roles         = assistant.roleTypes?.map{$0.rawValue}
        return model
    }
    
    public class func insertOrUpdate(assistants:[Assistant], resultEntity:((CMAssistant)->())? = nil){
        assistants.forEach { assistant in
            if let id = assistant.participant?.id , let findedEntity = CMAssistant.crud.find(keyWithFromat: "inviteeId == %i", value: id){
                let cmAssistant = convertToCM(assistant: assistant , entity: findedEntity)
                resultEntity?(cmAssistant)
            }else{
                CMAssistant.crud.insert { cmAssistantEntity in
                   let cmAssistant = convertToCM(assistant: assistant, entity: cmAssistantEntity)
                    resultEntity?(cmAssistant)
                }
            }
        }
    }
}
