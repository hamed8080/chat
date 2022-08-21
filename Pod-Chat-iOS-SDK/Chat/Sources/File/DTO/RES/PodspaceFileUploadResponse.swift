//
//  PodspaceFileUploadResponse.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 8/30/21.
//

import Foundation
public struct PodspaceFileUploadResponse:Decodable{
    public let status    :Int
    public let path      :String?
    public let error     :String?
    /// For when a error rise and detail more
    public let message   :String?
    public let result    :UploadFileResponse?
    public let timestamp :String?
    public let reference :String?
    
    var errorType:FileUploadError?{
        return FileUploadError(rawValue: status)
    }
}
enum FileUploadError:Int{
    case NO_CONTENT         = 204
    case FILE_NOT_SENT      = 400
    case UNAUTHORIZED       = 401
    case INSUFFICIENT_SPACE = 402
    case FORBIDDEN          = 403
    case NOT_FOUND          = 404
}
