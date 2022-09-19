//
//  UploadImageRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/30/21.
//

import Foundation
public class UploadImageRequest : UploadFileRequest{
    
    public var xC : Int = 0
    public var yC : Int = 0
    public var hC : Int = 0
    public var wC : Int = 0
    
    public init(
                data:           Data,
                xC:             Int      = 0,
                yC:             Int      = 0,
                hC:             Int,
                wC:             Int,
                fileExtension:  String?  = nil,
                fileName:       String?  = nil,
                mimeType:       String?  = nil,
                originalName:   String?  = nil,
                userGroupHash:  String?  = nil,
                uniqueId:       String?  = nil,
                isPublic:       Bool?    = nil) {
        self.xC = xC
        self.yC = yC
        self.hC = hC
        self.wC = wC
        super.init(data: data,
                   fileExtension:fileExtension,
                   fileName:fileName,
                   isPublic: isPublic,
                   mimeType:mimeType,
                   originalName:originalName,
                   userGroupHash:userGroupHash,
                   uniqueId:uniqueId
                   )
    }
    
    
    private enum CodingKeys : String , CodingKey{
        case userGroupHash = "userGroupHash"
        case isPublic      = "isPublic"
        case filename      = "filename"
        case xC            = "xC"
        case yC            = "yC"
        case hC            = "hC"
        case wC            = "wC"
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? super.encode(to: encoder)
        try container.encode("\(xC)", forKey: .xC)
        try container.encode("\(yC)", forKey: .yC)
        try container.encode("\(hC)", forKey: .hC)
        try container.encode("\(wC)", forKey: .wC)
    }
    
}
