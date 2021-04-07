//
//  NewUploadFileRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/28/21.
//

import Foundation
public class NewUploadFileRequest: BaseRequest {
    
    public var data                : Data
    public var fileExtension       : String? = nil
    public var fileName            : String  = ""
    public var fileSize            : Int64   = 0
    public var isPublic            : Bool?   = nil
    public var mimeType            : String  = ""
    public var originalName        : String  = ""
    public var userGroupHash       : String? = nil

    public init(data:           Data,
                fileExtension:  String?  = nil,
                fileName:       String?  = nil,
                mimeType:       String?  = nil,
                originalName:   String?  = nil,
                userGroupHash:  String?  = nil,
                typeCode:       String?  = nil,
                uniqueId:       String?  = nil) {
        self.data           = data
        self.fileExtension  = fileExtension
        let fileName        = fileName ?? "\(NSUUID().uuidString)"
        self.fileName       = fileName
        self.fileSize       = Int64(data.count)
        self.mimeType       = mimeType ?? ""
        self.userGroupHash  = userGroupHash
        self.originalName   = originalName ?? fileName + (fileExtension ?? "")
        isPublic            = userGroupHash != nil
        super.init(uniqueId: uniqueId, typeCode: typeCode)
    }
    
    private enum CodingKeys : String , CodingKey{
        case userGroupHash = "userGroupHash"
        case isPublic      = "isPublic"
        case filename      = "filename"
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(userGroupHash, forKey: .userGroupHash)
        try container.encodeIfPresent("\(isPublic != nil ? 1 : 0)", forKey: .isPublic)
        try container.encodeIfPresent(fileName, forKey: .filename)
    }
}
