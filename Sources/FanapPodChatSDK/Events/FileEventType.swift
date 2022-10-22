//
// FileEventType.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

public enum FileEventType {
    case notStarted
    case downloading(uniqueId: String)
    case downloaded(FileRequest)
    case imageDownloaded(ImageRequest)
    case downloadError(ChatError)
    case uploading(uniqueId: String)
    case uploaded(UploadFileRequest)
    case uploadError(ChatError)
}
