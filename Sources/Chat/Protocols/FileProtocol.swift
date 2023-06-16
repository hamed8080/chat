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
    func get(_ request: FileRequest)

    /// Downloading or getting an image from the Server / cache?.
    /// - Parameters:
    ///   - req: The request that contains Hashcode of image and a config to download from server or use cache?.
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
    ///   - req: The request that contains the data of file and other file properties.
    func upload(_ request: UploadFileRequest)

    /// Upload an image.
    /// - Parameters:
    ///   - req: The request that contains the data of an image and other image properties.
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
    func getData(_ url: URL) -> Data?

    /// Get data of a cache file in the correspondent URL inside a shared group.
    func getDataInGroup(_ url: URL) -> Data?

    /// Save a file inside the sandbox of the Chat SDK.
    func saveFile(url: URL, data: Data, completion: @escaping (URL?) -> Void)

    /// Save a file inside a shared group.
    func saveFileInGroup(url: URL, data: Data, completion: @escaping (URL?) -> Void)
}
