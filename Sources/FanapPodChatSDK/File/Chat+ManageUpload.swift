//
// Chat+ManageUpload.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
extension Chat {
    func requestManageUpload(_ uniqueId: String, _ action: DownloaUploadAction, _ completion: ((String, Bool) -> Void)? = nil) {
        if let task = callbacksManager.getUploadTask(uniqueId: uniqueId) {
            switch action {
            case .cancel:
                task.cancel()
                completion?("upload task with uniqueId \(uniqueId) canceled.", true)
                callbacksManager.removeUploadTask(uniqueId: uniqueId)
                cache.write(cacheType: .deleteQueue(uniqueId))
                cache.save()
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
