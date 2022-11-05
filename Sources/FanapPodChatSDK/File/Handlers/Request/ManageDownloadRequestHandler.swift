//
// ManageDownloadRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class ManageDownloadRequestHandler {
    class func handle(_ uniqueId: String,
                      _ action: DownloaUploadAction,
                      _: Bool,
                      _ completion: ((String, Bool) -> Void)? = nil)
    {
        if let task = Chat.sharedInstance.callbacksManager.getDownloadTask(uniqueId: uniqueId) {
            switch action {
            case .cancel:
                task.cancel()
                completion?("download task with uniqueId \(uniqueId) canceled.", true)
                Chat.sharedInstance.callbacksManager.removeDownloadTask(uniqueId: uniqueId)
            case .suspend:
                task.suspend()
                completion?("download task with uniqueId \(uniqueId) suspend.", true)
            case .resume:
                task.resume()
                completion?("download task with uniqueId \(uniqueId) resumed.", true)
            }
        } else {
            completion?("download task with uniqueId \(uniqueId) failed or not found.", false)
        }
    }
}
