//
//  FileEventType.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation

public enum FileEventType{
    case NOT_STARTED
    case DOWNLOADING(uniqueId:String)
    case DOWNLOADED(FileRequest)
    case IMAGE_DOWNLOADED(ImageRequest)
    case DOWNLOAD_ERROR(ChatError)
    case UPLOADING(uniqueId:String)
    case UPLOADED(UploadFileRequest)
    case UPLOAD_ERROR(ChatError)
}
