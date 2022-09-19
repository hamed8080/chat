//
//  CMFile+extenstions.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/2/21.
//

import Foundation

extension CMFile{
    
    public static let crud = CoreDataCrud<CMFile>(entityName: "CMFile")
    
    public func getCodable() -> FileModel?{
        guard let hashCode = hashCode else {return nil}
        return FileModel(hashCode: hashCode, name: name, size: size as? Int, type: type)
    }
    
    public class func convertToCM(request:FileModel  ,entity:CMFile? = nil) -> CMFile{

        let model            = entity ?? CMFile()
        model.hashCode       = request.hashCode
        model.name           = request.name
        model.size           = request.size as NSNumber?
        model.type           = request.type

        return model
    }

    public class func insert(request:FileModel , resultEntity:((CMFile)->())? = nil){
        CMFile.crud.insert { cmEntity in
            let cmEntity = convertToCM(request: request, entity: cmEntity)
            resultEntity?(cmEntity)
        }
    }
    
}
