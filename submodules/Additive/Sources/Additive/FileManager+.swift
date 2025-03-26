//
// FileManager+.swift
// Copyright (c) 2022 Additive
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

public extension FileManager {
    func zipFile(urlPathToZip: URL, zipName: String, completion: @escaping (URL?) -> Void) {
        let fm = FileManager.default
        var archiveUrl: URL?
        var error: NSError?
        let coordinator = NSFileCoordinator()

        coordinator.coordinate(readingItemAt: urlPathToZip, options: [.forUploading], error: &error) { zipUrl in
            // zipUrl points to the zip file created by the coordinator
            // zipUrl is valid only until the end of this block, so we move the file to a temporary folder
            if let tmpUrl = try? fm.url(
                for: .itemReplacementDirectory,
                in: .userDomainMask,
                appropriateFor: zipUrl,
                create: true
            ).appendingPathComponent("\(zipName).zip") {
                try? fm.moveItem(at: zipUrl, to: tmpUrl)

                // store the URL so we can use it outside the block
                archiveUrl = tmpUrl
                completion(archiveUrl)
            }
        }
    }

    func deleteFile(urlPathToZip: URL) {
        try? FileManager.default.removeItem(at: urlPathToZip)
    }
}
