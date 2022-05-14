//
//  ImageRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 4/2/21.
//

import Foundation

public enum ImageSize:String,Encodable{
    case SMALL  = "SMALL"
    case MEDIUM = "MEDIUM"
    case LARG   = "LARG"
    case ACTUAL = "ACTUAL"
}

public class ImageRequest: BaseRequest {
    
    public let hashCode                  :String
    public var forceToDownloadFromServer :Bool
    public let quality                   :Float?
    public let size                      :ImageSize?
    public let crop                      :Bool?
    public let isThumbnail               :Bool
    public let checkUserGroupAccess      :Bool
    
    public init(hashCode:String,checkUserGroupAccess:Bool = true,forceToDownloadFromServer:Bool = false , isThumbnail :Bool = false , quality:Float? = nil , size:ImageSize? = nil , crop:Bool? = nil) {
        self.hashCode                  = hashCode
        self.forceToDownloadFromServer = forceToDownloadFromServer
        self.size                      = size
        self.crop                      = crop
        self.isThumbnail               = isThumbnail
        self.checkUserGroupAccess      = checkUserGroupAccess
        if isThumbnail{
            self.quality = 0.123
        }else{
            self.quality = quality
        }
    }
    
    private enum CodingKeys :String ,CodingKey{
        case size                 = "size"
        case quality              = "quality"
        case crop                 = "crop"
        case checkUserGroupAccess = "checkUserGroupAccess"
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encodeIfPresent(size, forKey: .size)
        try? container.encodeIfPresent(crop, forKey: .crop)
        try? container.encodeIfPresent(quality, forKey: .quality)
        try? container.encodeIfPresent(checkUserGroupAccess, forKey: .checkUserGroupAccess)
    }
}
