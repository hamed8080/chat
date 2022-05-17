//
//  FileEventModel.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation

open class FileEventModel {
    
    public let type                 : FileEventType
    public let error                : ChatError?
    public let progress             : Int64?
    public let uniqueId             : String?
    public let downloadFileRequest  : FileRequest?
    public let downloadImageRequest : ImageRequest?
    public let uploadFileRequest    : UploadFileRequest?
    public let uploadImageRequest   : UploadImageRequest?
    
    
    init(type                : FileEventType,
         error               : ChatError?          = nil,
         downloadFileRequest : FileRequest?        = nil,
         downloadImageRequest: ImageRequest?       = nil,
         uploadFileRequest   : UploadFileRequest?  = nil,
         uploadImageRequest  : UploadImageRequest? = nil,
         uniqueId            : String?             = nil,
         progress            : Int64?              = nil
    ) {
        self.type                 = type
        self.error                = error
        self.progress             = progress
        self.uniqueId             = uniqueId
        self.downloadFileRequest  = downloadFileRequest
        self.downloadImageRequest = downloadImageRequest
        self.uploadFileRequest    = uploadFileRequest
        self.uploadImageRequest   = uploadImageRequest
    }
}

public enum FileEventType{
    case NOT_STARTED
    case DOWNLOADING
    case DOWNLOADED
    case DOWNLOAD_ERROR
    case UPLOADING
    case UPLOADED
    case UPLOAD_ERROR
}
