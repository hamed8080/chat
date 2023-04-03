//
// Chat+ManageDownload.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
public extension Chat {
    /// Manage a downloading file or an image.
    /// - Parameters:
    ///   - uniqueId: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - action: Action to pause, resume or cancel.
    ///   - isImage: Distinguish between file or image.
    ///   - completion: The result of aciton.
    func manageDownload(uniqueId: String, action: DownloaUploadAction, completion: ((String, Bool) -> Void)? = nil) {
        if let task = callbacksManager.getDownloadTask(uniqueId: uniqueId) {
            switch action {
            case .cancel:
                task.cancel()
                completion?("download task with uniqueId \(uniqueId) canceled.", true)
                callbacksManager.removeDownloadTask(uniqueId: uniqueId)
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
