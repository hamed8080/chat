//
//  GlobalVariables.swift
//  FanapPodChatSDK
//
//  Created by hamed on 7/20/22.
//

import Foundation

public typealias CompletionTypeWithoutUniqueId<T>   = ( T? , ChatError? )->()
public typealias CompletionType<T>                  = ( T? , String? , ChatError? )->()
public typealias PaginationCompletionType<T>        = ( T? , String? , Pagination? , ChatError? )->()
public typealias CacheResponseType<T>               = ( T? , String? , ChatError? )->()
public typealias PaginationCacheResponseType<T>     = ( T? , String? , Pagination? , ChatError? )->()
public typealias UploadFileProgressType             = (UploadFileProgress? , ChatError?)->()
public typealias UploadCompletionType               = (UploadFileResponse? , FileMetaData? , ChatError?)->()
public typealias UniqueIdResultType                 = ( (String)->() )?
public typealias UniqueIdsResultType                = ( ([String])->() )?
public typealias DownloadProgressType               = (DownloadFileProgress) -> ()
public typealias DownloadFileCompletionType         = (Data?, FileModel?  ,ChatError?)->()
public typealias DownloadImageCompletionType        = (Data?, ImageModel? ,ChatError?)->()
public typealias OnSeenType                         = ((SeenMessageResponse?    , String? , ChatError? ) -> ())?
public typealias OnDeliveryType                     = ((DeliverMessageResponse? , String? , ChatError? ) -> ())?
public typealias OnSentType                         = ((SentMessageResponse?    , String? , ChatError? ) -> ())?
