//
//  CMUserRole+extenstions.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/2/21.
//

import Foundation

extension CMUserRole{
    
    public static let crud = CoreDataCrud<CMUserRole>(entityName: "CMUserRole")
    
    public func getCodable() -> UserRole{
        return UserRole(userId: id as? Int ?? 0, name: name ?? "", roles: roles as? [String])
    }
    
    public class func convertToCM(userRole:UserRole  ,entity:CMUserRole? = nil) -> CMUserRole{
        let model        = entity ?? CMUserRole()
        model.name       = userRole.name
        model.id         = userRole.userId as NSNumber?
        model.roles      = userRole.roles as NSObject?
        
        return model
    }
    
    public class func insertOrUpdate(userRole:UserRole , resultEntity:((CMUserRole)->())? = nil){
        
        if let findedEntity = CMUserRole.crud.find(keyWithFromat: "id == %i", value: userRole.userId){
            let cmUserRole = convertToCM(userRole: userRole, entity: findedEntity)
            resultEntity?(cmUserRole)
        }else{
            CMUserRole.crud.insert { cmUserRoleEntity in
               let cmUserRole = convertToCM(userRole: userRole, entity: cmUserRoleEntity)
                resultEntity?(cmUserRole)
            }
        }
        
    }
}
