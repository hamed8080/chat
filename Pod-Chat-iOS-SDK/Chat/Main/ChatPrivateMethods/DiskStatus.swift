//
//  DiskStatus.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 11/13/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import UIKit

open class DiskStatus {
    
    //MARK: Get raw value
    public class var totalDiskSpaceInBytes: Int64 {
        get {
            if let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String) {
                let space = (systemAttributes[FileAttributeKey.systemSize] as? NSNumber)?.int64Value
                return space!
            } else {
                return 0
            }
//            do {
//                let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String)
//                let space = (systemAttributes[FileAttributeKey.systemSize] as? NSNumber)?.int64Value
//                return space!
//            } catch {
//                return 0
//            }
        }
    }
    
    public class var freeDiskSpaceInBytes: Int64 {
        get {
            if let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String) {
                let freeSpace = (systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.int64Value
                return freeSpace!
            } else {
                return 0
            }
//            do {
//                let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String)
//                let freeSpace = (systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.int64Value
//                return freeSpace!
//            } catch {
//                return 0
//            }
        }
    }
    
    public class var usedDiskSpaceInBytes: Int64 {
        get {
            let usedSpace = (totalDiskSpaceInBytes - freeDiskSpaceInBytes)
            return usedSpace
        }
    }
    
    
    //MARK: Get String Value
    public class var totalDiskSpace: String {
        get {
            return ByteCountFormatter.string(fromByteCount: totalDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.file)
        }
    }
    
    public class var freeDiskSpace: String {
        get {
            return ByteCountFormatter.string(fromByteCount: freeDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.file)
        }
    }
    
    public class var usedDiskSpace: String {
        get {
            return ByteCountFormatter.string(fromByteCount: usedDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.file)
        }
    }
    
    
    
    //MARK: Formatter MB only
    public class func MBFormatter(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = ByteCountFormatter.Units.useMB
        formatter.countStyle = ByteCountFormatter.CountStyle.decimal
        formatter.includesUnit = false
        return formatter.string(fromByteCount: bytes) as String
    }
    
    //MARK: Formatter GB only
    public class func GBFormatter(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = ByteCountFormatter.Units.useGB
        formatter.countStyle = ByteCountFormatter.CountStyle.decimal
        formatter.includesUnit = false
        return formatter.string(fromByteCount: bytes) as String
    }
    
    class func checkIfDeviceHasFreeSpace(needSpaceInMB: Int64, turnOffTheCache: Bool , errorDelegate:ChatDelegates?) -> Bool {
        let availableSpace = DiskStatus.freeDiskSpaceInBytes
        if availableSpace < (needSpaceInMB * 1024 * 1024) {
            var message = "your disk space is less than \(DiskStatus.MBFormatter(DiskStatus.freeDiskSpaceInBytes))MB."
            if turnOffTheCache {
                message += " " + "so, the cache will be switch OFF!"
            }
            if Chat.sharedInstance.config?.useNewSDK == true{
                (errorDelegate as? NewChatDelegate)?.chatError(error: .init(code: .OUT_OF_STORAGE, message: "out of storage!"))
            }else{
                errorDelegate?.chatError(errorCode: 6401, errorMessage: message, errorResult: nil)
            }
            return false
        } else {
            return true
        }
    }
}
