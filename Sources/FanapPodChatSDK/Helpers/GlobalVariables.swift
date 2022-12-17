//
// GlobalVariables.swift
// Copyright (c) 2022 FanapPodChatSDK
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
public typealias DownloadFileCompletionType = (Data?, FileModel?, ChatError?) -> Void
public typealias DownloadImageCompletionType = (Data?, ImageModel?, ChatError?) -> Void
public typealias OnSeenType = (MessageResponse?, String?, ChatError?) -> Void
public typealias OnDeliveryType = (MessageResponse?, String?, ChatError?) -> Void
public typealias OnSentType = (MessageResponse?, String?, ChatError?) -> Void
