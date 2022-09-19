//
//  CMImage+extenstions.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/2/21.
//

import Foundation

extension CMImage{
    
    public static let crud = CoreDataCrud<CMImage>(entityName: "CMImage")
    
    public func getCodable() -> ImageModel?{
        guard let hashCode = hashCode else {return nil}
        return ImageModel(actualHeight : actualHeight as? Int,
                          actualWidth  : actualWidth as? Int,
                          hashCode     : hashCode,
                          height       : height as? Int,
                          name         : name ?? "",
                          size         : size as? Int,
                          width        : width as? Int)
    }
    
    public class func convertToCM(request:ImageModel ,isThumbnail :Bool ,entity:CMImage? = nil) -> CMImage{

        let model          = entity ?? CMImage()
        model.actualHeight = request.actualHeight as NSNumber?
        model.actualWidth  = request.actualWidth as NSNumber?
        model.hashCode     = request.hashCode
        model.height       = request.height as NSNumber?
        model.isThumbnail  = NSNumber(value:isThumbnail)
        model.name         = request.name
        model.size         = request.size as NSNumber?
        model.width        = request.width as NSNumber?
        
        return model
    }

    public class func insert(request:ImageModel ,isThumbnail :Bool, resultEntity:((CMImage)->())? = nil){
        CMImage.crud.insert { cmEntity in
            let cmEntity = convertToCM(request: request, isThumbnail: isThumbnail , entity: cmEntity)
            resultEntity?(cmEntity)
        }
    }
    
}
