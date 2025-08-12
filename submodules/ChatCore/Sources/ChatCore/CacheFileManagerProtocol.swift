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

public protocol CacheFileManagerProtocol: Sendable {
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
    ///   - saveCompletion: Completion with url of the file on the disk, nil if something went wrong and saving has failed.
    func saveFile(url: URL, data: Data, saveCompletion: @escaping @Sendable (URL?) -> Void)
    
    /// Save the file asynchronously into the disk.
    /// - Parameters:
    ///   - url: The real HttpURL of the file.
    ///   - data: The data of the file to be saved.
    /// - Returns: Url of the file on the disk, nil if something went wrong and saving has failed.
    func saveFile(url: URL, data: Data) async -> URL?
    
    /// Move temp file to permanent directory.
    /// - Parameters:
    ///   - url: Server url file like https://www.podspace.com/file/XFRTSHJWIO
    ///   - tempDownloadFileURL: Disk temp folder url path like: /temp/myfile.jpg
    /// - Returns: Moved file disk url like: /Talk/documents/myfile.jpg
    func saveFile(url: URL, tempDownloadFileURL: URL) async -> URL?
    
    func deleteResumeDataFile(hashCode: String) throws
    
    func resumableData(for: String) -> Data?
    
    func moveAndSave(url: URL, fromPath: URL, saveCompletion: @escaping @Sendable (URL?) -> Void)

    /// Save the file asynchronously into the disk by making an md5 hash name for the uniqueness of the path.
    /// - Parameters:
    ///   - url: The string real HttpURL string.
    ///   - data: The data of the file to be saved.
    ///   - saveCompletion: Completion with url of the file on the disk for a group.
    func saveFileInGroup(url: URL, data: Data, saveCompletion: @escaping @Sendable (URL?) -> Void)
    
    /// Save the file asynchronously into the disk by making an md5 hash name for the uniqueness of the path.
    /// - Parameters:
    ///   - url: The string real HttpURL string.
    ///   - data: The data of the file to be saved.
    /// - Returns: Url of the file for the group on the disk, nil if something went wrong and saving has failed.
    func saveFileInGroup(url: URL, data: Data) async -> URL?

    /// Return the data of the file if it exists. Get data of the file asynchronously on the background thread.
    /// - Parameters:
    ///   - url: The HttpURL of the file.
    ///   - completion: Completion with url of the file on the disk.
    func getData(url: URL, completion: @escaping @Sendable (Data?) -> Void)
    
    /// Return the data of the file if it exists. Get data of the file asynchronously on the background thread.
    /// - Parameters:
    ///   - url: The HttpURL of the file.
    /// - Returns: Data of the file, or nil if something went wrong.
    func getData(url: URL) async -> Data?

    /// Return the data of the file a file in group if it exists. Get data of the a file in a group asynchronously on the background thread.
    /// - Parameters:
    ///   - url: The HttpURL of the file.
    ///   - completion: Completion with data of the file on the disk.
    func getDataInGroup(url: URL, completion: @escaping @Sendable (Data?) -> Void)
    
    /// Return the data of the file a file in group if it exists. Get data of the a file in a group asynchronously on the background thread.
    /// - Parameters:
    ///   - url: The HttpURL of the file.
    /// - Returns: Data of the file in the group, or nil if something went wrong.
    func getDataInGroup(url: URL) async -> Data?

    /// Return crosspondent file url for a HttpURL.
    /// - Parameters:
    ///   - url: The HttpURL of the file.
    /// - Returns: Return the filePath on the disk.
    func filePath(url: URL) -> URL?

    /// Return crosspondent file url for a HttpURL.
    /// - Parameters:
    ///   - url: The HttpURL of the file in a group containter.
    /// - Returns: Return the filePath on the disk container.
    func filePathInGroup(url: URL) -> URL?

    /// Delete a file at path.
    /// - Parameters:
    ///   - url: Path of the file or directory to delete.
    func deleteFile(at url: URL)

    /// Delete a folder at a path.
    /// - Parameters:
    ///   - url: Path to delete.
    func deleteFolder(url: URL)

    /// Check if the file exist in the path.
    /// - Parameters:
    ///   - url: The HttpUrl of the file.
    /// - Returns: True if the file exist on the disk.
    func isFileExist(url: URL) -> Bool

    /// Check if the file exist in the container path.
    /// - Parameters:
    ///   - url: The HttpUrl of the file.
    /// - Returns: True if the file exist on the disk.
    func isFileExistInGroup(url: URL) -> Bool

    /// Create group folder for sharing with other extensions.
    /// The group property should be fiiled if you are looking to work with this.
    func createGroupDirectory()
}
