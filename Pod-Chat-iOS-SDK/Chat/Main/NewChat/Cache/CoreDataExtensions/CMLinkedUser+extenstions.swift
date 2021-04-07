//
//  CMLinkedUser+extenstions.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/2/21.
//

import Foundation

extension CMLinkedUser{
    
    public static let crud = CoreDataCrud<CMLinkedUser>(entityName: "CMLinkedUser")
    
    public func getCodable() -> LinkedUser{
        return LinkedUser(coreUserId: coreUserId as? Int,
                          image: image,
                          name: name,
                          nickname: nickname,
                          username: username)
    }
    
    public class func convertLinkUserToCM(linkedUser:LinkedUser  ,entity:CMLinkedUser? = nil) -> CMLinkedUser{
        
        let model        = entity ?? CMLinkedUser()
        model.coreUserId = linkedUser.coreUserId as NSNumber?
        model.image      = linkedUser.image
        model.name       = linkedUser.name
        model.nickname   = linkedUser.nickname
        model.username   = linkedUser.username
        
        return model
    }
    
    public class func insertOrUpdate(linkedUser:LinkedUser , resultEntity:((CMLinkedUser)->())? = nil){
        
		if let coreUserId = linkedUser.coreUserId, let findedEntity = CMLinkedUser.crud.find(keyWithFromat: "coreUserId == %i", value: coreUserId){
            let cmLinkedUser = convertLinkUserToCM(linkedUser: linkedUser, entity: findedEntity)
            resultEntity?(cmLinkedUser)
        }else{
            CMLinkedUser.crud.insert { cmLinkedUserEntity in
               let cmLinkedUser = convertLinkUserToCM(linkedUser: linkedUser, entity: cmLinkedUserEntity)
                resultEntity?(cmLinkedUser)
            }
        }
        
    }
}
