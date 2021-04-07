//
//  ImageRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 4/2/21.
//

import Foundation
public class ImageRequest: BaseRequest {
    
    public let hashCode                  :String
    public let forceToDownloadFromServer :Bool
    public let quality                   :Float?
    public let size                      :Int?
    public let crop                      :Bool?
    public let isThumbnail               :Bool
    
    public init(hashCode:String ,forceToDownloadFromServer:Bool = false , isThumbnail :Bool = false , quality:Float? = nil , size:Int? = nil , crop:Bool? = nil) {
        self.hashCode                  = hashCode
        self.forceToDownloadFromServer = forceToDownloadFromServer
        self.size                      = size
        self.crop                      = crop
        self.isThumbnail               = isThumbnail
        if isThumbnail{
            self.quality = 0.123
        }else{
            self.quality = quality
        }
    }
    
    private enum CodingKeys :String ,CodingKey{
        case hashCode = "hash"
        case size     = "size"
        case quality  = "quality"
        case crop     = "crop"
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(hashCode, forKey: .hashCode)
        try? container.encodeIfPresent(size, forKey: .size)
        try? container.encodeIfPresent(crop, forKey: .crop)
        try? container.encodeIfPresent(quality, forKey: .quality)
    }
}
