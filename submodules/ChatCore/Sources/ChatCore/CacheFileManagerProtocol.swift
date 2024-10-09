//
// CacheFileManagerProtocol.swift
// Copyright (c) 2022 ChatCore
//
// Created by Hamed Hosseini on 12/16/22

import Foundation
import Additive
import Logger

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
    func getData(url: URL, completion: @escaping (Data?) -> Void)

    /// Return the data of the file a file in group if it exists. Get data of the a file in a group asynchronously on the background thread.
    /// - Returns: Data of the file.
    /// - Parameter url: The HttpURL of the file.
    func getDataInGroup(url: URL, completion: @escaping (Data?) -> Void)

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
