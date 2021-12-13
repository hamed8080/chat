//
//  FileMetaData.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/30/21.
//

import Foundation
public class FileMetaData:Codable{

    public let file     : FileDetail?
    public let fileHash : String?
    public let hashCode : String?
    public let name     : String?
    
    public init(file: FileDetail, fileHash: String? = nil , hashCode:String? = nil , name: String? = nil) {
        self.file     = file
        self.fileHash = fileHash
        self.name     = name
        self.hashCode = hashCode
    }
}

public class FileDetail:Codable{
    
    public let actualHeight    : Int?
    public let actualWidth     : Int?
    public let `extension`     : String?
    public let link            : String
    public let mimeType        : String
    public let name            : String
    public let originalName    : String
    public let size            : Int64
    public let fileHash        : String?
    public let hashCode        : String?
    public let parentHash      : String?
    
    public init(fileExtension: String?, link: String, mimeType: String, name: String, originalName: String, size: Int64 ,fileHash:String? = nil,hashCode:String? = nil,parentHash:String? = nil , actualHeight: Int? = nil, actualWidth: Int? = nil) {
        self.actualHeight = actualHeight
        self.actualWidth  = actualWidth
        self.extension    = fileExtension
        self.link         = link
        self.mimeType     = mimeType
        self.name         = name
        self.originalName = originalName
        self.size         = size
        self.fileHash     = fileHash
        self.hashCode     = hashCode
        self.parentHash   = parentHash
    }
    
}
