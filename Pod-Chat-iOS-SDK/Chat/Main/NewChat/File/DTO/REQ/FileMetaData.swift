//
//  FileMetaData.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/30/21.
//

import Foundation
public class FileMetaData:Encodable{

    let file     : FileDetail
    let fileHash : String?
    let hashCode : String?
    let name     : String?
    let id       : Int = 0
    
    public init(file: FileDetail, fileHash: String? , hashCode:String? , name: String?) {
        self.file     = file
        self.fileHash = fileHash
        self.name     = name
        self.hashCode = hashCode
    }
}

public class FileDetail:Encodable{
    
    let actualHeight    : Int?
    let actualWidth     : Int?
    let `extension`     : String?
    let link            : String
    let mimeType        : String
    let name            : String
    let originalName    : String
    let size            : Int64
    
    public init(fileExtension: String?, link: String, mimeType: String, name: String, originalName: String, size: Int64 , actualHeight: Int? = nil, actualWidth: Int? = nil) {
        self.actualHeight = actualHeight
        self.actualWidth  = actualWidth
        self.extension    = fileExtension
        self.link         = link
        self.mimeType     = mimeType
        self.name         = name
        self.originalName = originalName
        self.size         = size
    }
    
}
