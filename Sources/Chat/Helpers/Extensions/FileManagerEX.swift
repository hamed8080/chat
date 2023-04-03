//
// FileManagerEX.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/2/22

import Foundation

extension FileManager {
    func appendToEndOfFile(data: Data, fileurl: URL) {
        if FileManager.default.fileExists(atPath: fileurl.path) {
            do {
                let fileHandle = try FileHandle(forWritingTo: fileurl)
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            } catch {
                print("Can't open file to append\(error.localizedDescription)")
            }
        }
    }
}
