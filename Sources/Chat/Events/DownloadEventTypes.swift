//
// DownloadEventTypes.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/2/22

import ChatCore
import ChatTransceiver
import Foundation

public enum DownloadEventTypes {
    case file(ChatResponse<Data>, URL?)
    case image(ChatResponse<Data>, URL?)
    case canceled(uniqueId: String)
    case suspended(uniqueId: String)
    case resumed(uniqueId: String)
    case progress(uniqueId: String, progress: DownloadFileProgress?)
    case failed(uniqueId: String, error: ChatError?)
}
