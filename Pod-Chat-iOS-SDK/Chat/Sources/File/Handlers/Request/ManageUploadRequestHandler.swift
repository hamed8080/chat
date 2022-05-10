//
//  ManageUploadRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 4/3/21.
//

import Foundation
class ManageUploadRequestHandler{
    
    class func handle(_ uniqueId:String ,
                      _ action:DownloaUploadAction ,
                      _ isImage:Bool,
                      _ completion:((String,Bool)->())? = nil
                      ){
        if let task = Chat.sharedInstance.callbacksManager.getUploadTask(uniqueId: uniqueId){
            switch action {
            case .cancel:
                task.cancel()
                completion?("upload task with uniqueId \(uniqueId) canceled." ,true)
                Chat.sharedInstance.callbacksManager.removeUploadTask(uniqueId: uniqueId)
                if isImage{
                    CacheFactory.write(cacheType: .DELETE_UPLOAD_IMAGE_QUEUE(uniqueId))
                }else{
                    CacheFactory.write(cacheType: .DELETE_UPLOAD_FILE_QUEUE(uniqueId))
                }
                CacheFactory.save()
                break
            case .suspend:
                task.suspend()
                completion?("upload task with uniqueId \(uniqueId) suspend." ,true)
                break
            case .resume:
                task.resume()
                completion?("upload task with uniqueId \(uniqueId) resumed." ,true)
                break
            }
        }else{
            completion?("upload task with uniqueId \(uniqueId) failed or not found." ,false)
        }
    }
}
