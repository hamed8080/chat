//
//  UploadFileRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/28/21.
//

import Foundation
import CoreServices
import UniformTypeIdentifiers

public class UploadFileRequest: BaseRequest {
    
    public var data                   : Data
    public var fileExtension          : String?  = nil
    public var fileName               : String   = ""
    public var fileSize               : Int64    = 0
    /// if  send file iniside the thread we need to set is isPublic to false
    public private (set) var isPublic : Bool?    = nil
    public var mimeType               : String   = ""
    public var originalName           : String   = ""
    public var userGroupHash          : String?  = nil
    public var description            : String?  = nil

    public init(data:           Data,
                fileExtension:  String?  = nil,
                fileName:       String?  = nil,
                description:    String?  = nil,
                isPublic:       Bool?    = nil,
                mimeType:       String?  = nil,
                originalName:   String?  = nil,
                userGroupHash:  String?  = nil,
                uniqueId:       String?  = nil) {
        self.data           = data
        self.fileExtension  = fileExtension
        let fileName        = fileName ?? "\(NSUUID().uuidString)"
        self.fileName       = fileName
        self.fileSize       = Int64(data.count)
        self.mimeType       = mimeType ?? UploadFileRequest.guessMimeType(fileExtension, fileName)
        self.userGroupHash  = userGroupHash
        self.originalName   = originalName ?? fileName + (fileExtension ?? "")
        self.isPublic       = userGroupHash != nil ? false : isPublic//if send file iniside the thread we need to set is isPublic to false
        super.init(uniqueId: uniqueId)
    }
    
    class func guessMimeType(_ fileExtension:String?, _ fileName:String?)->String{
        let ext = fileExtension ?? URL(fileURLWithPath: fileName ?? "").pathExtension
        var mimeType:String? = nil
        if #available(iOS 14.0, *){
            mimeType = UTType(filenameExtension: ext)?.preferredMIMEType
        } else if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext as NSString, nil)?.takeRetainedValue(){
            mimeType = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() as? String
        }
        return mimeType ?? "application/octet-stream"
    }
    
    private enum CodingKeys : String , CodingKey{
        case isPublic      = "isPublic"
        case filename      = "filename"
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent("\(isPublic != nil && isPublic  == true ? "true" : "false")", forKey: .isPublic)//dont send bool it crash when send and encode to dictionary
        try container.encodeIfPresent(fileName, forKey: .filename)
    }
}
