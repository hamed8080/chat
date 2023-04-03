//
// GlobalVariables.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public typealias CompletionTypeWithoutUniqueId<T> = (T?, ChatError?) -> Void
public typealias CompletionType<T: Decodable> = (ChatResponse<T>) -> Void
public typealias CompletionTypeNoneDecodeable<T> = (ChatResponse<T>) -> Void
public typealias CacheResponseType<T> = (ChatResponse<T>) -> Void
public typealias UploadFileProgressType = (UploadFileProgress?, ChatError?) -> Void
public typealias UploadCompletionType = (UploadFileResponse?, FileMetaData?, ChatError?) -> Void
public typealias UniqueIdResultType = (String) -> Void
public typealias UniqueIdsResultType = ([String]) -> Void
public typealias DownloadProgressType = (DownloadFileProgress) -> Void
public typealias DownloadFileCompletionType = (Data?, URL?, File?, ChatError?) -> Void
public typealias DownloadImageCompletionType = (Data?, URL?, Image?, ChatError?) -> Void
public typealias OnSentType = (ChatResponse<MessageResponse>) -> Void
public typealias OnDeliveryType = (ChatResponse<MessageResponse>) -> Void
public typealias OnSeenType = (ChatResponse<MessageResponse>) -> Void
