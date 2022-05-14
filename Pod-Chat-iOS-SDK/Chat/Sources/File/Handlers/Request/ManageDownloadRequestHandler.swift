//
//  ManageDownloadRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 4/3/21.
//

import Foundation
class ManageDownloadRequestHandler{
    
    class func handle(_ uniqueId:String ,
                      _ action:DownloaUploadAction ,
                      _ isImage:Bool,
                      _ completion:((String,Bool)->())? = nil
                      ){
        if let task = Chat.sharedInstance.callbacksManager.getDownloadTask(uniqueId: uniqueId){
            switch action {
            case .cancel:
                task.cancel()
                completion?("download task with uniqueId \(uniqueId) canceled." ,true)
                Chat.sharedInstance.callbacksManager.removeDownloadTask(uniqueId: uniqueId)
                break
            case .suspend:
                task.suspend()
                completion?("download task with uniqueId \(uniqueId) suspend." ,true)
                break
            case .resume:
                task.resume()
                completion?("download task with uniqueId \(uniqueId) resumed." ,true)
                break
            }
        }else{
            completion?("download task with uniqueId \(uniqueId) failed or not found." ,false)
        }
    }
}
