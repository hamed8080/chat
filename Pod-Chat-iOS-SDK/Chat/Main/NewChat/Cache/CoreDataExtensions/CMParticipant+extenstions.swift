//
//  CMParticipant+extenstions.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/2/21.
//

import Foundation

extension CMParticipant{
    
    public static let crud = CoreDataCrud<CMParticipant>(entityName: "CMParticipant")
	
	public func getCodable() -> Participant{
		
		return Participant(admin:           admin as? Bool,
						   auditor:         auditor as? Bool,
						   blocked:         blocked as? Bool,
						   cellphoneNumber:  cellphoneNumber,
						   contactFirstName: contactFirstName,
						   contactId:       contactId as? Int,
						   contactName:     contactName,
						   contactLastName: contactLastName,
						   coreUserId:      coreUserId as? Int,
						   email:           email,
						   firstName:       firstName,
						   id:              id as? Int,
						   image:           image,
						   keyId:           keyId,
						   lastName:        lastName,
						   myFriend:        myFriend as? Bool,
						   name:            name,
						   notSeenDuration: notSeenDuration as? Int,
						   online:          online as? Bool,
						   receiveEnable:   receiveEnable as? Bool,
						   roles:           roles,
						   sendEnable:      sendEnable as? Bool,
						   username:        username,
						   chatProfileVO:   Profile(bio: bio, metadata: metadata))
	}
    
	public class func convertParticipantToCM(participant:Participant ,threadId:Int? ,entity:CMParticipant? = nil) -> CMParticipant{
        let model        = entity ?? CMParticipant()
      
		model.admin            = participant.admin as NSNumber?
		model.auditor          = participant.auditor as NSNumber?
		model.blocked          = participant.blocked as NSNumber?
		model.cellphoneNumber  = participant.cellphoneNumber
		model.contactFirstName = participant.contactFirstName
		model.contactId        = participant.contactId as NSNumber?
		model.contactName      = participant.contactName
		model.contactLastName  = participant.contactLastName
		model.coreUserId       = participant.coreUserId as NSNumber?
		model.email            = participant.email
		model.firstName        = participant.firstName
		model.id               = participant.id as NSNumber?
		model.image            = participant.image
		model.keyId            = participant.keyId
		model.lastName         = participant.lastName
		model.myFriend         = participant.myFriend as NSNumber?
		model.name             = participant.name
		model.notSeenDuration  = participant.notSeenDuration as NSNumber?
		model.online           = participant.online as NSNumber?
		model.receiveEnable    = participant.receiveEnable as NSNumber?
		model.roles            = participant.roles
		model.sendEnable       = participant.sendEnable as NSNumber?
		if let threadId = threadId{
			model.threadId    =  NSNumber(value:threadId)
		}
		model.time             = Int(Date().timeIntervalSince1970) as NSNumber?
		model.username         = participant.username
		
		model.bio              = participant.chatProfileVO?.bio
		model.metadata         = participant.chatProfileVO?.metadata
        
        return model
    }
    
	public class func insertOrUpdate(participant:Participant ,threadId:Int? , resultEntity:((CMParticipant)->())? = nil){
        
		if let id = participant.id, let findedEntity = CMParticipant.crud.find(keyWithFromat: "id == %i", value: id){
			let cmParticipant = convertParticipantToCM(participant: participant, threadId: threadId, entity: findedEntity)
            resultEntity?(cmParticipant)
        }else{
            CMParticipant.crud.insert { cmLinkedUserEntity in
				let cmParticipant = convertParticipantToCM(participant: participant, threadId: threadId, entity: cmLinkedUserEntity)
                resultEntity?(cmParticipant)
            }
        }
        
    }
    
    public class func insertOrUpdateParicipants(participants:[Participant]? ,threadId:Int? , resultEntity:((CMParticipant)->())? = nil){
        participants?.forEach { participant in
            insertOrUpdate(participant: participant, threadId: threadId, resultEntity: resultEntity)
        }
    }
    
    public class func deleteParticipants(participants:[Participant]? , threadId:Int?){
        guard let participants = participants ,let threadId = threadId else{return}
        crud.fetchWith(NSPredicate(format: "threadId == %i" , threadId))?.forEach({ cmParticipant in
            if (participants.contains{$0.id == cmParticipant.id as? Int}){
                crud.delete(entity: cmParticipant)
            }
        })
    }
}
