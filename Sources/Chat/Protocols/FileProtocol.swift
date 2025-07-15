//
// FileProtocol.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import Foundation

@ChatGlobalActor
public protocol FileProtocol: AnyObject {
    /// Downloading or getting a file from the Server / cache?.
    /// - Parameters:
    ///   - request: The request that contains Hashcode of a file and a config to either download from the server or cache.
    func get(_ request: FileRequest)

    /// Downloading or getting an image from the Server / cache?.
    /// - Parameters:
    ///   - request: The request that contains Hashcode of a image and a config to eihter download from server or  cache.
    func get(_ request: ImageRequest)

    /// Manage a downloading file or an image.
    /// - Parameters:
    ///   - uniqueId: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - action: Action to pause, resume or cancel.
    func manageDownload(uniqueId: String, action: DownloaUploadAction)

    /// Manage a uploading file or an image.
    /// - Parameters:
    ///   - uniqueId: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - action: Action to pause, resume or cancel.
    func manageUpload(uniqueId: String, action: DownloaUploadAction)

    /// Upload a file.
    /// - Parameters:
    ///   - request: The request that contains the data of a file and other file properties.
    func upload(_ request: UploadFileRequest)

    /// Upload an image.
    /// - Parameters:
    ///   - request: The request that contains the data of an image and other image properties.
    func upload(_ request: UploadImageRequest)

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
    func getData(_ url: URL, completion: @escaping @Sendable (Data?) -> Void)

    /// Get data of a cache file in the correspondent URL inside a shared group.
    func getDataInGroup(_ url: URL, completion: @escaping @Sendable (Data?) -> Void)

    /// Save a file inside the sandbox of the Chat SDK.
    func saveFile(url: URL, data: Data, completion: @escaping @Sendable (URL?) -> Void)

    /// Save a file inside a shared group.
    func saveFileInGroup(url: URL, data: Data, completion: @escaping @Sendable (URL?) -> Void)
    
    /// Resumable downloader.
    /// - Parameter request: A request that contains hashcode of a flag to either download from the server or fetch it from the local disk cache.
    ///
    /// It will automatically resume the download if there is a buffer of the file on the disk.
    func download(_ request: FileRequest) throws
    
    /// Pause a resumable download.
    /// - Parameter hashCode: HashCode of the FileRequest you send to the download method ``FileReqeust.hashCode``.
    func pauseResumableDownload(hashCode: String) throws
    
    /// Resume an pauesed download.
    /// - Parameter hashCode: HashCode that you pass to the ``download`` method ``FileReqeust.hashCode``.
    func resumeDownload(hashCode: String) throws
    
    /// Cancel a resumable download file.
    /// - Parameter hashCode: Hashcode that you pass to the ``download`` method ``FileReqeust.hashCode``.
    func cancel(hashCode: String) throws
}

@ChatGlobalActor
protocol InternalFileProtocol: AnyObject {
    // Try to add the user to the user group then retry the download.
    func handleUserGroupAccessError(_ params: DownloadManagerParameters)
}
