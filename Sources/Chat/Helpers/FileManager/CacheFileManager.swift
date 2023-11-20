//
// CacheFileManager.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Additive
import ChatCore
import Foundation
import Logger

public final class CacheFileManager: CacheFileManagerProtocol {
    public let fm: FileManagerProtocol
    public let logger: Logger?
    public let queue: DispatchQueueProtocol
    public let group: String?
    public var groupFolder: URL? {
        if let group = group {
            return fm.containerURL(forSecurityApplicationGroupIdentifier: group)?
                .appendingPathComponent("Files", isDirectory: true)
        } else {
            return nil
        }
    }

    public var documentPath: URL? {
        fm.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent("Files", isDirectory: true)
    }

    public required init(fileManager: FileManagerProtocol = FileManager.default,
                         group: String? = nil,
                         queue: DispatchQueueProtocol = DispatchQueue.global(qos: .background),
                         logger: Logger? = nil)
    {
        fm = fileManager
        self.group = group
        self.queue = queue
        self.logger = logger
    }

    public func saveFile(url: URL, data: Data, saveCompeletion: @escaping (URL?) -> Void) {
        guard let filePath = filePath(url: url) else {
            saveCompeletion(nil)
            return
        }
        createDirectory()
        queue.asyncWork {
            try? data.write(to: filePath)
            DispatchQueue.global(qos: .background).async {
                saveCompeletion(filePath)
            }
        }
    }

    public func saveFileInGroup(url: URL, data: Data, saveCompeletion: @escaping (URL?) -> Void) {
        guard let groupFilePath = filePathInGroup(url: url) else {
            saveCompeletion(nil)
            return
        }
        createGroupDirectory()
        queue.asyncWork {
            try? data.write(to: url)
            DispatchQueue.global(qos: .background).async {
                saveCompeletion(groupFilePath)
            }
        }
    }

    public func getData(url: URL) -> Data? {
        guard isFileExist(url: url), let filePath = filePath(url: url) else { return nil }
        return try? Data(contentsOf: filePath)
    }

    public func getDataInGroup(url: URL) -> Data? {
        guard isFileExistInGroup(url: url), let groupFilePath = filePathInGroup(url: url) else { return nil }
        return getData(url: groupFilePath)
    }

    @discardableResult
    public func filePath(url: URL) -> URL? {
        guard let hash = md5(url: url), let documentPath = documentPath?.appendingPathComponent(hash, isDirectory: false) else { return nil }
        return documentPath
    }

    @discardableResult
    public func filePathInGroup(url: URL) -> URL? {
        guard let hash = md5(url: url), let groupFilePath = groupFolder?.appendingPathComponent(hash, isDirectory: false) else { return nil }
        return groupFilePath
    }

    private func md5(url: URL) -> String? {
        url.absoluteString.md5
    }

    public func deleteFile(at url: URL) {
        if let documentPath = filePath(url: url) {
            try? fm.removeItem(at: documentPath)
        }

        if let groupPath = filePathInGroup(url: url) {
            try? fm.removeItem(at: groupPath)
        }
    }

    public func deleteFolder(url: URL) {
        try? fm.removeItem(at: url)
    }

    public func isFileExist(url: URL) -> Bool {
        if let filePathURL = filePath(url: url) { return fm.fileExists(atPath: filePathURL.path) }
        return false
    }

    public func isFileExistInGroup(url: URL) -> Bool {
        if let groupPath = filePathInGroup(url: url) { return fm.fileExists(atPath: groupPath.path) }
        return false
    }

    public func createDirectory() {
        if let documentPath = documentPath {
            try? fm.createDirectory(at: documentPath, withIntermediateDirectories: true, attributes: nil)
        }
    }

    public func createGroupDirectory() {
        if let groupFolder = groupFolder {
            try? fm.createDirectory(at: groupFolder, withIntermediateDirectories: true, attributes: nil)
        }
    }
}
