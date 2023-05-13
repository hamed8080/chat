//
// ChatImplementation+Cache.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

// Request
public extension ChatImplementation {
    /// Delete a file in cache with exact file url on the disk.
    func deleteCacheFile(_ url: URL) {
        cacheFileManager?.deleteFile(at: url)
    }

    /// Return true if the file exist inside the sandbox of the ChatSDK application host.
    func isFileExist(_ url: URL) -> Bool {
        cacheFileManager?.isFileExist(url: url) ?? false
    }

    /// Return the url of the file if it exists inside the sandbox of the ChatSDK application host.
    func filePath(_ url: URL) -> URL? {
        cacheFileManager?.filePath(url: url)
    }

    /// Return the true of the file if it exists inside the share group.
    func isFileExistInGroup(_ url: URL) -> Bool {
        cacheFileManager?.isFileExistInGroup(url: url) ?? false
    }

    /// Return the url of the file if it exists inside the share group.
    func filePathInGroup(_ url: URL) -> URL? {
        cacheFileManager?.filePathInGroup(url: url)
    }

    /// Get data of a cache file in the correspondent URL.
    func getData(_ url: URL) -> Data? {
        cacheFileManager?.getData(url: url)
    }

    /// Get data of a cache file in the correspondent URL inside a shared group.
    func getDataInGroup(_ url: URL) -> Data? {
        cacheFileManager?.getDataInGroup(url: url)
    }

    /// Save a file inside the sandbox of the Chat SDK.
    func saveFile(url: URL, data: Data, completion: @escaping (URL?) -> Void) {
        cacheFileManager?.saveFile(url: url, data: data, saveCompeletion: completion)
    }

    /// Save a file inside a shared group.
    func saveFileInGroup(url: URL, data: Data, completion: @escaping (URL?) -> Void) {
        cacheFileManager?.saveFileInGroup(url: url, data: data, saveCompeletion: completion)
    }
}
