//
// ManageUploadRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class ManageUploadRequestHandler {
    class func handle(_ uniqueId: String,
                      _ action: DownloaUploadAction,
                      _: Bool,
                      _ completion: ((String, Bool) -> Void)? = nil)
    {
        if let task = Chat.sharedInstance.callbacksManager.getUploadTask(uniqueId: uniqueId) {
            switch action {
            case .cancel:
                task.cancel()
                completion?("upload task with uniqueId \(uniqueId) canceled.", true)
                Chat.sharedInstance.callbacksManager.removeUploadTask(uniqueId: uniqueId)
                CacheFactory.write(cacheType: .deleteQueue(uniqueId))
                CacheFactory.save()
            case .suspend:
                task.suspend()
                completion?("upload task with uniqueId \(uniqueId) suspend.", true)
            case .resume:
                task.resume()
                completion?("upload task with uniqueId \(uniqueId) resumed.", true)
            }
        } else {
            completion?("upload task with uniqueId \(uniqueId) failed or not found.", false)
        }
    }
}
