//
// DiskStatus.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/2/22

import ChatCore
import Foundation

public final class DiskStatus {
    // MARK: Get raw value

    public final class var totalDiskSpaceInBytes: Int64 {
        if let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String) {
            let space = (systemAttributes[FileAttributeKey.systemSize] as? NSNumber)?.int64Value
            return space!
        } else {
            return 0
        }
    }

    public final class var freeDiskSpaceInBytes: Int64 {
        if let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String) {
            let freeSpace = (systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.int64Value
            return freeSpace!
        } else {
            return 0
        }
    }

    public final class var usedDiskSpaceInBytes: Int64 {
        let usedSpace = (totalDiskSpaceInBytes - freeDiskSpaceInBytes)
        return usedSpace
    }

    // MARK: Get String Value

    public final class var totalDiskSpace: String {
        ByteCountFormatter.string(fromByteCount: totalDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.file)
    }

    public final class var freeDiskSpace: String {
        ByteCountFormatter.string(fromByteCount: freeDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.file)
    }

    public final class var usedDiskSpace: String {
        ByteCountFormatter.string(fromByteCount: usedDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.file)
    }

    // MARK: Formatter MB only

    public final class func MBFormatter(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = ByteCountFormatter.Units.useMB
        formatter.countStyle = ByteCountFormatter.CountStyle.decimal
        formatter.includesUnit = false
        return formatter.string(fromByteCount: bytes) as String
    }

    // MARK: Formatter GB only

    public final class func GBFormatter(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = ByteCountFormatter.Units.useGB
        formatter.countStyle = ByteCountFormatter.CountStyle.decimal
        formatter.includesUnit = false
        return formatter.string(fromByteCount: bytes) as String
    }

    @discardableResult
    final class func checkIfDeviceHasFreeSpace(needSpaceInMB: Int64, turnOffTheCache: Bool, delegate: ChatDelegate?) -> Bool {
        let availableSpace = DiskStatus.freeDiskSpaceInBytes
        if availableSpace < (needSpaceInMB * 1024 * 1024) {
            var message = "your disk space is less than \(DiskStatus.MBFormatter(DiskStatus.freeDiskSpaceInBytes))MB."
            if turnOffTheCache {
                message += " " + "so, the cache will be switch OFF!"
            }
            let error = ChatError(type: .outOfStorage, message: message)
            let errorResponse = ChatResponse(result: Any?.none, error: error, typeCode: nil)
            delegate?.chatEvent(event: .system(.error(errorResponse)))
            return false
        } else {
            return true
        }
    }
}
