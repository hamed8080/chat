//
//  CMUser+extenstions.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/2/21.
//

import Foundation

extension CMUser{
    
    public static let crud = CoreDataCrud<CMUser>(entityName: "CMUser")
    
    public func getCodable() -> User{
        return User(cellphoneNumber: cellphoneNumber,
                    contactSynced:  contactSynced as? Bool,
                    coreUserId:     coreUserId as? Int,
                    email:          email,
                    id:             id as? Int,
                    image:          image,
                    lastSeen:       lastSeen as? Int,
                    name:           name,
                    receiveEnable:  receiveEnable as? Bool,
                    sendEnable:     sendEnable as? Bool,
                    username:       username,
                    ssoId:          ssoId,
                    firstName:      firstName,
                    lastName:       lastName,
                    chatProfileVO:  Profile(bio: bio, metadata: metadata))
    }
    
    public class func converUserToCM(user:User  ,entity:CMUser? = nil) -> CMUser{
        
        let model        = entity ?? CMUser()
        model.cellphoneNumber = user.cellphoneNumber
        model.contactSynced   = user.contactSynced as NSNumber
        model.coreUserId      = user.coreUserId as NSNumber?
        model.email           = user.email
        model.id              = user.id as NSNumber?
        model.image           = user.image
        model.lastSeen        = user.lastSeen as NSNumber?
        model.name            = user.name
        model.receiveEnable   = user.receiveEnable as NSNumber?
        model.sendEnable      = user.sendEnable as NSNumber?
        model.username        = user.username
        model.bio             = user.chatProfileVO?.bio
        model.metadata        = user.chatProfileVO?.metadata
        model.ssoId           = user.ssoId
        model.firstName       = model.firstName
        model.lastName        = user.lastName
        
        return model
    }
    
    public class func insertOrUpdate(user:User , resultEntity:((CMUser)->())? = nil){
        
        if let findedEntity = CMUser.crud.find(keyWithFromat: "id == %i", value: user.id!){
            let cmUser = converUserToCM(user: user, entity: findedEntity)
            resultEntity?(cmUser)
        }else{
            CMUser.crud.insert { cmUserEntity in
               let cmUser = converUserToCM(user: user, entity: cmUserEntity)
                resultEntity?(cmUser)
            }
        }
    }
}
