//
// FileProtocol.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import Foundation

public protocol FileProtocol {
    /// Downloading or getting a file from the Server / cache?.
    /// - Parameters:
    ///   - req: The request that contains Hashcode of file and a config to download from server or use cache?.
    ///   - downloadProgress: The progress of download.
    ///   - completion: The completion block tells you whether the file was successfully downloaded or not. The URL of the file cached is nil if you set ``ChatConfig/enableCache`` to false.
    ///   - cacheResponse: The path of the file. The data is nill because it is up to client to how to read data from disk.
    ///    As an example there are times you want to read part of a file in a stream format so it would be overhead for system to read whole unuesd data.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getFile(_ request: FileRequest,
                 downloadProgress: @escaping DownloadProgressType,
                 completion: @escaping DownloadFileCompletionType,
                 cacheResponse: DownloadFileCompletionType?,
                 uniqueIdResult: UniqueIdResultType?)

    /// Downloading or getting an image from the Server / cache?.
    /// - Parameters:
    ///   - req: The request that contains Hashcode of image and a config to download from server or use cache?.
    ///   - downloadProgress: The progress of download.
    ///   - completion: The completion block tells you whether the image was successfully downloaded or not. The URL of the image cached is nil if you set ``ChatConfig/enableCache`` to false.
    ///   - cacheResponse: The path of the image. The data is nill because it is up to client to how to read data from disk.
    ///    As an example there are times you want to read part of an image  in a stream format so it would be overhead for system to read whole unuesd data.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getImage(_ request: ImageRequest,
                  downloadProgress: @escaping DownloadProgressType,
                  completion: @escaping DownloadImageCompletionType,
                  cacheResponse: DownloadImageCompletionType?,
                  uniqueIdResult: UniqueIdResultType?)

    /// Manage a downloading file or an image.
    /// - Parameters:
    ///   - uniqueId: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - action: Action to pause, resume or cancel.
    ///   - isImage: Distinguish between file or image.
    ///   - completion: The result of aciton.
    func manageDownload(uniqueId: String, action: DownloaUploadAction, completion: ((String, Bool) -> Void)?)

    /// Manage a uploading file or an image.
    /// - Parameters:
    ///   - uniqueId: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - action: Action to pause, resume or cancel.
    ///   - isImage: Distinguish between file or image.
    ///   - completion: The result of aciton.
    func manageUpload(uniqueId: String, action: DownloaUploadAction, completion: ((String, Bool) -> Void)?)

    /// Send a file message.
    /// - Parameters:
    ///   - textMessage: A text message with a threadId.
    ///   - uploadFile: The progress of uploading file.
    ///   - uploadProgress: The progress of uploading file.
    ///   - onSent: Is called when a message sent successfully.
    ///   - onSeen: Is called when a message, have seen by a participant successfully.
    ///   - onDeliver: Is called when a message, have delivered to a participant successfully.
    ///   - uploadUniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - messageUniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func sendFileMessage(textMessage: SendTextMessageRequest,
                         uploadFile: UploadFileRequest,
                         uploadProgress: UploadFileProgressType?,
                         onSent: OnSentType?,
                         onSeen: OnSeenType?,
                         onDeliver: OnDeliveryType?,
                         uploadUniqueIdResult: UniqueIdResultType?,
                         messageUniqueIdResult: UniqueIdResultType?)

    /// Reply to a mesaage inside a thread with a file.
    /// - Parameters:
    ///   - replyMessage: The request that contains the threadId and a text message an id of an message you want to reply.
    ///   - uploadFile: The request that contains the data of file and other file properties
    ///   - uploadProgress: The progress of uploading file.
    ///   - onSent: Is called when a message sent successfully.
    ///   - onSeen: Is called when a message, have seen by a participant successfully.
    ///   - onDeliver: Is called when a message, have delivered to a participant successfully.
    ///   - uploadUniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - messageUniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func replyFileMessage(replyMessage: ReplyMessageRequest,
                          uploadFile: UploadFileRequest,
                          uploadProgress: UploadFileProgressType?,
                          onSent: OnSentType?,
                          onSeen: OnSeenType?,
                          onDeliver: OnDeliveryType?,
                          uploadUniqueIdResult: UniqueIdResultType?,
                          messageUniqueIdResult: UniqueIdResultType?)

    func requestSendImageTextMessage(textMessage: SendTextMessageRequest,
                                     req: UploadImageRequest,
                                     onSent: OnSentType?,
                                     onSeen: OnSeenType?,
                                     onDeliver: OnDeliveryType?,
                                     uploadProgress: UploadFileProgressType?,
                                     uploadUniqueIdResult: UniqueIdResultType?,
                                     messageUniqueIdResult: UniqueIdResultType?)

    /// Upload a file.
    /// - Parameters:
    ///   - req: The request that contains the data of file and other file properties.
    ///   - uploadUniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - uploadProgress: The progress of uploading file.
    ///   - uploadCompletion: The result shows whether the upload was successful or not.
    func uploadFile(_ request: UploadFileRequest,
                    uploadUniqueIdResult: UniqueIdResultType?,
                    uploadProgress: UploadFileProgressType?,
                    uploadCompletion: UploadCompletionType?)

    /// Upload an image.
    /// - Parameters:
    ///   - req: The request that contains the data of an image and other image properties.
    ///   - uploadUniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - uploadProgress: The progress of uploading the image.
    ///   - uploadCompletion: The result shows whether the upload was successful or not.
    func uploadImage(_ request: UploadImageRequest,
                     uploadUniqueIdResult: UniqueIdResultType?,
                     uploadProgress: UploadFileProgressType?,
                     uploadCompletion: UploadCompletionType?)

    /// Delete a file in cache with exact file url on the disk.
    func deleteCacheFile(_ url: URL)

    /// Return true if the file exist inside the sandbox of the ChatSDK application host.
    func isFileExist(_ url: URL) -> Bool

    /// Return the url of the file if it exists inside the sandbox of the ChatSDK application host.
    func filePath(_ url: URL) -> URL?

    /// Return the true of the file if it exists inside the share group.
    func isFileExistInGroup(_ url: URL) -> Bool

    /// Return the url of the file if it exists inside the share group.
    func filePathInGroup(_ url: URL) -> URL?

    /// Get data of a cache file in the correspondent URL.
    func getData(_ url: URL) -> Data?

    /// Get data of a cache file in the correspondent URL inside a shared group.
    func getDataInGroup(_ url: URL) -> Data?

    /// Save a file inside the sandbox of the Chat SDK.
    func saveFile(url: URL, data: Data, completion: @escaping (URL?) -> Void)

    /// Save a file inside a shared group.
    func saveFileInGroup(url: URL, data: Data, completion: @escaping (URL?) -> Void)
}

public extension FileProtocol {
    /// Downloading or getting a file from the Server / cache?.
    /// - Parameters:
    ///   - req: The request that contains Hashcode of file and a config to download from server or use cache?.
    ///   - downloadProgress: The progress of download.
    ///   - completion: The completion block tells you whether the file was successfully downloaded or not. The URL of the file cached is nil if you set ``ChatConfig/enableCache`` to false.
    ///   - cacheResponse: The path of the file. The data is nill because it is up to client to how to read data from disk.
    ///    As an example there are times you want to read part of a file in a stream format so it would be overhead for system to read whole unuesd data.
    func getFile(_ request: FileRequest, downloadProgress: @escaping DownloadProgressType, completion: @escaping DownloadFileCompletionType, cacheResponse: DownloadFileCompletionType?) {
        getFile(request,
                downloadProgress: downloadProgress,
                completion: completion,
                cacheResponse: cacheResponse,
                uniqueIdResult: nil)
    }

    /// Downloading or getting an image from the Server / cache?.
    /// - Parameters:
    ///   - req: The request that contains Hashcode of image and a config to download from server or use cache?.
    ///   - downloadProgress: The progress of download.
    ///   - completion: The completion block tells you whether the image was successfully downloaded or not. The URL of the image cached is nil if you set ``ChatConfig/enableCache`` to false.
    ///   - cacheResponse: The path of the image. The data is nill because it is up to client to how to read data from disk.
    ///    As an example there are times you want to read part of an image  in a stream format so it would be overhead for system to read whole unuesd data.
    func getImage(_ request: ImageRequest,
                  downloadProgress: @escaping DownloadProgressType,
                  completion: @escaping DownloadImageCompletionType,
                  cacheResponse: DownloadImageCompletionType?)
    {
        getImage(request,
                 downloadProgress: downloadProgress,
                 completion: completion,
                 cacheResponse: cacheResponse,
                 uniqueIdResult: nil)
    }

    /// Send a file message.
    /// - Parameters:
    ///   - textMessage: A text message with a threadId.
    ///   - uploadFile: The progress of uploading file.
    ///   - uploadProgress: The progress of uploading file.
    ///   - onSent: Is called when a message sent successfully.
    ///   - onSeen: Is called when a message, have seen by a participant successfully.
    ///   - onDeliver: Is called when a message, have delivered to a participant successfully.
    func sendFileMessage(textMessage: SendTextMessageRequest,
                         uploadFile: UploadFileRequest,
                         uploadProgress: UploadFileProgressType?,
                         onSent: OnSentType?,
                         onSeen: OnSeenType?,
                         onDeliver: OnDeliveryType?)
    {
        sendFileMessage(textMessage: textMessage,
                        uploadFile: uploadFile,
                        uploadProgress: uploadProgress,
                        onSent: onSent,
                        onSeen: onSeen,
                        onDeliver: onDeliver,
                        uploadUniqueIdResult: nil,
                        messageUniqueIdResult: nil)
    }

    /// Reply to a mesaage inside a thread with a file.
    /// - Parameters:
    ///   - replyMessage: The request that contains the threadId and a text message an id of an message you want to reply.
    ///   - uploadFile: The request that contains the data of file and other file properties
    ///   - uploadProgress: The progress of uploading file.
    ///   - onSent: Is called when a message sent successfully.
    ///   - onSeen: Is called when a message, have seen by a participant successfully.
    ///   - onDeliver: Is called when a message, have delivered to a participant successfully.
    func replyFileMessage(replyMessage: ReplyMessageRequest,
                          uploadFile: UploadFileRequest,
                          uploadProgress: UploadFileProgressType?,
                          onSent: OnSentType?,
                          onSeen: OnSeenType?,
                          onDeliver: OnDeliveryType?)
    {
        replyFileMessage(replyMessage: replyMessage,
                         uploadFile: uploadFile,
                         uploadProgress: uploadProgress,
                         onSent: onSent,
                         onSeen: onSeen,
                         onDeliver: onDeliver,
                         uploadUniqueIdResult: nil,
                         messageUniqueIdResult: nil)
    }

    func requestSendImageTextMessage(textMessage: SendTextMessageRequest,
                                     req: UploadImageRequest,
                                     onSent: OnSentType?,
                                     onSeen: OnSeenType?,
                                     onDeliver: OnDeliveryType?,
                                     uploadProgress: UploadFileProgressType?)
    {
        requestSendImageTextMessage(textMessage: textMessage,
                                    req: req,
                                    onSent: onSent,
                                    onSeen: onSeen,
                                    onDeliver: onDeliver,
                                    uploadProgress: uploadProgress,
                                    uploadUniqueIdResult: nil,
                                    messageUniqueIdResult: nil)
    }

    /// Upload a file.
    /// - Parameters:
    ///   - req: The request that contains the data of file and other file properties.
    ///   - uploadProgress: The progress of uploading file.
    ///   - uploadCompletion: The result shows whether the upload was successful or not.
    func uploadFile(_ request: UploadFileRequest, uploadProgress: UploadFileProgressType?, uploadCompletion: UploadCompletionType?) {
        uploadFile(request,
                   uploadUniqueIdResult: nil,
                   uploadProgress: uploadProgress,
                   uploadCompletion: uploadCompletion)
    }

    /// Upload an image.
    /// - Parameters:
    ///   - req: The request that contains the data of an image and other image properties.
    ///   - uploadProgress: The progress of uploading the image.
    ///   - uploadCompletion: The result shows whether the upload was successful or not.
    func uploadImage(_ request: UploadImageRequest, uploadProgress: UploadFileProgressType?, uploadCompletion: UploadCompletionType?) {
        uploadImage(request,
                    uploadUniqueIdResult: nil,
                    uploadProgress: uploadProgress,
                    uploadCompletion: uploadCompletion)
    }
}
