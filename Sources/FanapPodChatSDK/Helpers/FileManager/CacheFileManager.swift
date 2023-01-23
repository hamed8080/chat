//
// CacheFileManager.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public protocol FileManagerProtocol {
    func url(for directory: FileManager.SearchPathDirectory, in domain: FileManager.SearchPathDomainMask, appropriateFor url: URL?, create shouldCreate: Bool) throws -> URL
    func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL]
    func fileExists(atPath path: String) -> Bool
    func containerURL(forSecurityApplicationGroupIdentifier groupIdentifier: String) -> URL?
    func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey: Any]?) throws
    func removeItem(at URL: URL) throws
}

extension FileManager: FileManagerProtocol {}

public protocol CacheFileManagerProtocol {
    var fm: FileManagerProtocol { get }
    var logger: Logger? { get }
    var queue: DispatchQueueProtocol { get }
    var documentPath: URL? { get }
    var group: String? { get }
    var groupFolder: URL? { get }
    init(fileManager: FileManagerProtocol, group: String?, queue: DispatchQueueProtocol, logger: Logger?)

    /// Save the file asynchronously into the disk.
    /// - Parameters:
    ///   - url: The real HttpURL of the file.
    ///   - data: The data of the file to be saved.
    /// - Returns: Throw an exception if something went wrong and saving has failed.
    func saveFile(url: URL, data: Data, saveCompeletion: @escaping (URL?) -> Void)

    /// Save the file asynchronously into the disk by making an md5 hash name for the uniqueness of the path.
    /// - Parameters:
    ///   - url: The string real HttpURL string.
    ///   - data: The data of the file to be saved.
    /// - Returns: Throw an exception if something went wrong and saving has failed.
    func saveFileInGroup(url: URL, data: Data, saveCompeletion: @escaping (URL?) -> Void)

    /// Return the data of the file if it exists. Get data of the file asynchronously on the background thread.
    /// - Returns: Data of the file.
    /// - Parameter url: The HttpURL of the file.
    func getData(url: URL) -> Data?

    /// Return the data of the file a file in group if it exists. Get data of the a file in a group asynchronously on the background thread.
    /// - Returns: Data of the file.
    /// - Parameter url: The HttpURL of the file.
    func getDataInGroup(url: URL) -> Data?

    /// Return crosspondent file url for a HttpURL.
    /// - Parameter url: The HttpURL of the file.
    /// - Returns: Return the filePath on the disk.
    func filePath(url: URL) -> URL?

    /// Return crosspondent file url for a HttpURL.
    /// - Parameter url: The HttpURL of the file in a group containter.
    /// - Returns: Return the filePath on the disk container.
    func filePathInGroup(url: URL) -> URL?

    /// Delete a file at path.
    /// - Parameter at: Path of the file or directory to delete.
    func deleteFile(at url: URL)

    /// Delete a folder at a path.
    /// - Parameter url: Path to delete.
    func deleteFolder(url: URL)

    /// Check if the file exist in the path.
    /// - Parameter url: The HttpUrl of the file.
    /// - Parameter isDirectory: If you are checking to see if it is a directory pass this true.
    /// - Returns: True if the file exist on the disk.
    func isFileExist(url: URL) -> Bool

    /// Check if the file exist in the container path.
    /// - Parameter url: The HttpUrl of the file.
    /// - Parameter isDirectory: If you are checking to see if it is a directory pass this true.
    /// - Returns: True if the file exist on the disk.
    func isFileExistInGroup(url: URL) -> Bool

    /// Create group folder for sharing with other extensions.
    /// The group property should be fiiled if you are looking to work with this.
    func createGroupDirectory()
}

public class CacheFileManager: CacheFileManagerProtocol {
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
        queue.async {
            try? data.write(to: filePath)
            DispatchQueue.main.async {
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
        queue.async {
            try? data.write(to: url)
            DispatchQueue.main.async {
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
