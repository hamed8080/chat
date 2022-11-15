//
// GlobalVariables.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

public typealias CompletionTypeWithoutUniqueId<T> = (T?, ChatError?) -> Void
public typealias CompletionType<T> = (T?, String?, ChatError?) -> Void
public typealias PaginationCompletionType<T> = (T?, String?, Pagination?, ChatError?) -> Void
public typealias CacheResponseType<T> = (T?, String?, ChatError?) -> Void
public typealias PaginationCacheResponseType<T> = (T?, String?, Pagination?, ChatError?) -> Void
public typealias UploadFileProgressType = (UploadFileProgress?, ChatError?) -> Void
public typealias UploadCompletionType = (UploadFileResponse?, FileMetaData?, ChatError?) -> Void
public typealias UniqueIdResultType = (String) -> Void
public typealias UniqueIdsResultType = ([String]) -> Void
public typealias DownloadProgressType = (DownloadFileProgress) -> Void
public typealias DownloadFileCompletionType = (Data?, FileModel?, ChatError?) -> Void
public typealias DownloadImageCompletionType = (Data?, ImageModel?, ChatError?) -> Void
public typealias OnSeenType = (SeenMessageResponse?, String?, ChatError?) -> Void
public typealias OnDeliveryType = (DeliverMessageResponse?, String?, ChatError?) -> Void
public typealias OnSentType = (SentMessageResponse?, String?, ChatError?) -> Void
public typealias OnChatResponseType = (ChatResponse) -> Void
