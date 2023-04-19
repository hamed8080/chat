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
    case downloaded(ChatResponse<Data?>)
    case imageDownloaded(ChatResponse<Data?>)
    case downloadError(ChatResponse<String>)
    case uploading(ChatResponse<String>)
    case uploaded(ChatResponse<String>)
    case uploadError(ChatResponse<String>)
}
