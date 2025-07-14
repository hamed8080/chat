//
// DownloadEventTypes.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/2/22

import ChatCore
import ChatTransceiver
import Foundation

public enum DownloadEventTypes: Sendable {
    case file(ChatResponse<Data>, URL?)
    /// New version of of on download completion without data.
    case downloadFile(ChatResponse<URL>)
    case image(ChatResponse<Data>, URL?)
    /// New version of of on image completion without data.
    case downloadImage(ChatResponse<URL>)
    case canceled(uniqueId: String)
    case suspended(uniqueId: String)
    case resumed(uniqueId: String)
    case progress(uniqueId: String, progress: DownloadFileProgress?)
    case failed(uniqueId: String, error: ChatError?)
}
