//
// CacheFileManager.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Additive
import ChatCore
import Foundation
import Logger

public final class CacheFileManager: CacheFileManagerProtocol, @unchecked Sendable {
    public let fm: FileManagerProtocol
    public let logger: Logger?
    public let queue: DispatchQueueProtocol
    public let group: String?
    private let debug = ProcessInfo().environment["ENABLE_FILE_STORAGE_LOGGING"] == "1"
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

    public func saveFile(url: URL, data: Data, saveCompletion: @escaping @Sendable (URL?) -> Void) {
        queue.asyncWork { [weak self] in
            guard let self = self else { return }
            guard let filePath = filePath(url: url) else {
                saveCompletion(nil)
                log("File URL was nil for url: \(url.absoluteString)")
                return
            }
            createDirectory()
            do {
                try data.write(to: filePath)
                saveCompletion(filePath)
                log("File Saved at: \(filePath.absoluteString) for url: \(url.absoluteString)")
            } catch {
                log("Error saving the file at file path: \(filePath.absoluteString) for url: \(url.absoluteString) error: \(error.localizedDescription)")
                saveCompletion(nil)
            }
        }
    }
    
    public func saveFile(url: URL, data: Data) async -> URL? {
        typealias Result = CheckedContinuation<URL?, Never>
        return await withCheckedContinuation { [weak self] (continuation: Result) in
            self?.saveFile(url: url, data: data) { url in
                continuation.resume(with: .success(url))
            }
        }
    }

    public func saveFileInGroup(url: URL, data: Data, saveCompletion: @escaping @Sendable (URL?) -> Void) {
        queue.asyncWork { [weak self] in
            guard let self = self else { return }
            guard let groupFilePath = filePathInGroup(url: url) else {
                saveCompletion(nil)
                log("File Group URL was nil for url: \(url.absoluteString)")
                return
            }
            createGroupDirectory()
            do {
                try data.write(to: groupFilePath)
                saveCompletion(groupFilePath)
                log("File Group Saved at: \(groupFilePath.absoluteString) for url: \(url.absoluteString)")
            } catch {
                log("Error saving the group file at file path: \(groupFilePath.absoluteString) for url: \(url.absoluteString) error: \(error.localizedDescription)")
                saveCompletion(nil)
            }
        }
    }
    
    public func saveFileInGroup(url: URL, data: Data) async -> URL? {
        typealias Result = CheckedContinuation<URL?, Never>
        return await withCheckedContinuation { [weak self] (continuation: Result) in
            self?.saveFileInGroup(url: url, data: data) { url in
                continuation.resume(with: .success(url))
            }
        }
    }

    public func getData(url: URL, completion: @escaping @Sendable (Data?) -> Void) {
        queue.asyncWork { [weak self] in
            guard let self = self else { return }
            guard isFileExist(url: url), let filePath = filePath(url: url) else {
                completion(nil)
                log("Get Data filePath was nil for url: \(url.absoluteString)")
                return
            }
            do {
                let data = try Data(contentsOf: filePath)
                completion(data)
                log("Successfully got the data at file path: \(filePath.absoluteString) for url: \(url.absoluteString)")
            } catch {
                log("Error getting data at file path: \(filePath.absoluteString) for url: \(url.absoluteString) error: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    public func getData(url: URL) async -> Data? {
        typealias EntityResult = CheckedContinuation<Data?, Never>
        return await withCheckedContinuation { [weak self] (continuation: EntityResult) in
            self?.getData(url: url) { data in
                continuation.resume(with: .success(data))
            }
        }
    }

    public func getDataInGroup(url: URL, completion: @escaping @Sendable (Data?) -> Void) {
        guard isFileExistInGroup(url: url), let groupFilePath = filePathInGroup(url: url) else {
            completion(nil)
            return
        }
        getData(url: groupFilePath) { data in
            completion(data)
        }
    }
    
    public func getDataInGroup(url: URL) async -> Data? {
        typealias EntityResult = CheckedContinuation<Data?, Never>
        return await withCheckedContinuation { [weak self] (continuation: EntityResult) in
            self?.getDataInGroup(url: url) { data in
                continuation.resume(with: .success(data))
            }
        }
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
            do {
                try fm.removeItem(at: documentPath)
                log("Successfully deleted the file for url: \(url.absoluteString)")
            } catch {
                log("Failed to delete the file for url: \(url.absoluteString) error: \(error.localizedDescription)")
            }
        }

        if let groupPath = filePathInGroup(url: url) {
            do {
                try fm.removeItem(at: groupPath)
                log("Successfully deleted the file in group for url: \(url.absoluteString)")
            } catch {
                log("Failed to deleted the file in group for url: \(url.absoluteString) error: \(error.localizedDescription)")
            }
        }
    }

    public func deleteFolder(url: URL) {
        do {
            try fm.removeItem(at: url)
            log("Successfully deleted the foler for url: \(url.absoluteString)")
        } catch {
            log("Failed to delete the folder for url: \(url.absoluteString) error: \(error.localizedDescription)")
        }
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
            do {
                try fm.createDirectory(at: documentPath, withIntermediateDirectories: true, attributes: nil)
                log("Successfully created the folder at: \(documentPath.absoluteString)")
            } catch {
                log("Failed to carete directory for documentPath at: \(documentPath.absoluteString) error: \(error.localizedDescription)")
            }
        }
    }

    public func createGroupDirectory() {
        if let groupFolder = groupFolder {
            do {
                try fm.createDirectory(at: groupFolder, withIntermediateDirectories: true, attributes: nil)
                log("Successfully created a group folder at: \(groupFolder.absoluteString)")
            } catch {
                log("Failed to carete group directory for groupFolder: \(groupFolder.absoluteString) error: \(error.localizedDescription)")
            }
        }
    }
    
    private func log(_ message: String) {
#if DEBUG
        if debug {
            logger?.log(title: "Store File", message: message, persist: false, type: .internalLog)
        }
#endif
    }
}

/// Resumable upload/download folder
extension CacheFileManager {
    public func saveFile(url: URL, tempDownloadFileURL: URL) async -> URL? {
        typealias Result = CheckedContinuation<URL?, Never>
        return await withCheckedContinuation { [weak self] (continuation: Result) in
            self?.saveFile(url: url, tempDownloadFileURL: tempDownloadFileURL) { url in
                continuation.resume(with: .success(url))
            }
        }
    }
    
    public func saveFile(url: URL, tempDownloadFileURL: URL, saveCompletion: @escaping @Sendable (URL?) -> Void) {
        queue.asyncWork { [weak self] in
            guard let self = self else { return }
            guard let filePath = filePath(url: url) else {
                saveCompletion(nil)
                log("File URL was nil for url: \(url.absoluteString)")
                return
            }
            do {
                try createResumableDirectory()
                try (fm as? FileManager)?.moveItem(at: tempDownloadFileURL, to: filePath)
                saveCompletion(filePath)
                log("File Saved at: \(filePath.absoluteString) for url: \(url.absoluteString)")
            } catch {
                log("Error saving the file at file path: \(filePath.absoluteString) for url: \(url.absoluteString) error: \(error.localizedDescription)")
                saveCompletion(nil)
            }
        }
    }
    
    public func resumableData(for hashCode: String) -> Data? {
        if let resumableFilePath = resumableFilePath(hashCode: hashCode) {
            return try? Data(contentsOf: resumableFilePath)
        }
        return nil
    }
    
    public func deleteResumeDataFile(hashCode: String) throws {
        if let resumableFilePath = resumableFilePath(hashCode: hashCode) {
            try fm.removeItem(at: resumableFilePath)
        }
    }
    
    private func resumableFilePath(hashCode: String) -> URL? {
        return resumableDIR.appendingPathComponent(hashCode)
    }
    
    public func createResumableDirectory() throws {
        try fm.createDirectory(at: resumableDIR, withIntermediateDirectories: true, attributes: nil)
    }
    
    public var resumableDIR: URL {
        let docDIR = fm.urls(for: .documentDirectory, in: .userDomainMask).first
        return docDIR?.appendingPathComponent("resumable", isDirectory: true) ?? FileManager.default.temporaryDirectory
    }
}

extension CacheFileManager {
    public func moveAndSave(url: URL, fromPath: URL, saveCompletion: @escaping @Sendable (URL?) -> Void) {
        queue.asyncWork { [weak self] in
            guard let self = self, let newDiskFilePath = filePath(url: url) else { return }
            do {
                try FileManager.default.moveItem(atPath: fromPath.path, toPath: newDiskFilePath.path)
                try FileManager.default.removeItem(at: fromPath)
                saveCompletion(newDiskFilePath)
            } catch {
                log("Error moving the file from: \(fromPath.absoluteString) to url: \(newDiskFilePath.absoluteString) error: \(error.localizedDescription)")
                saveCompletion(nil)
            }
        }
    }
}
