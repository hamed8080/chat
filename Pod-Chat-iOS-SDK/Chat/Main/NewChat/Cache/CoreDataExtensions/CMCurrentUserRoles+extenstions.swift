//
//  CMCurrentUserRoles+extenstions.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/2/21.
//

import Foundation

extension CMCurrentUserRoles{
    
    public static let crud = CoreDataCrud<CMCurrentUserRoles>(entityName: "CMCurrentUserRoles")
    
    public func getCodable() -> [Roles]{
        return roles?.roles.compactMap{ Roles(rawValue: $0) } ?? []
    }
    
    public class func convertRoleToCM(roles:[Roles] , threadId:Int ,entity:CMCurrentUserRoles? = nil) -> CMCurrentUserRoles{
        
        let model        = entity ?? CMCurrentUserRoles()
        model.roles      = RolesArray(roles: roles)
        model.threadId   = NSNumber(value: threadId)
        return model
    }
    
    public class func insertOrUpdate(roles:[Roles] , threadId:Int, resultEntity:((CMCurrentUserRoles)->())? = nil){
        if let findedEntity = CMCurrentUserRoles.crud.find(keyWithFromat: "threadId == %i", value: threadId){
            let cmUserRoles = convertRoleToCM(roles: roles, threadId: threadId, entity: findedEntity)
            resultEntity?(cmUserRoles)
        }else{
            CMCurrentUserRoles.crud.insert { cmRolesEntity in
                let cmUserRoles = convertRoleToCM(roles: roles, threadId: threadId, entity: cmRolesEntity)
                resultEntity?(cmUserRoles)
            }
        }
    }
    
}
