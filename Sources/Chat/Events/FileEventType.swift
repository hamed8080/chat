//
// FileEventType.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/2/22

import ChatCore
import Foundation

public enum FileEventType {
    case notStarted
    case downloading(ChatResponse<String>)
    case fileDownloaded(ChatResponse<Data>, URL?)
    case imageDownloaded(ChatResponse<Data>, URL?)
    case uploading(ChatResponse<String>)
    case uploaded(ChatResponse<String>)
    case uploadError(ChatResponse<String>)
    case canceledDownload(uniqueId: String)
    case suspendedDownload(uniqueId: String)
    case resumedDownload(uniqueId: String)
    case canceledUpload(uniqueId: String)
    case suspendedUpload(uniqueId: String)
    case resumedUpload(uniqueId: String)
    case failed(uniqueId: String)
    case uploadProgress(String, UploadFileProgress?, ChatError?)
    case uploadCompletion(uniqueId: String, Data?, Error?)
    case downloadProgress(uniqueId: String, progress: DownloadFileProgress?)
}
