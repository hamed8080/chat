//
//  MultiPartFileStreamURL.swift
//  ChatTransceiver
//
//  Created by Hamed Hosseini on 7/19/25.
//

import Foundation

class MultiPartFileStreamURL {
    private let filePath: URL
    private let boundary: String
    private let fieldName: String
    private let mimeType: String
    private let extraFields: [String: String]
    let out: FileHandle
    let tempURL: URL
    
    init(filePath: URL, boundary: String, fieldName: String, mimeType: String, extraFields: [String: String] = [:]) throws {
        self.filePath = filePath
        self.boundary = boundary
        self.fieldName = fieldName
        self.mimeType = mimeType
        self.extraFields = extraFields
        tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("multipart-\(UUID().uuidString)")
        FileManager.default.createFile(atPath: tempURL.path, contents: nil)
        out = try FileHandle(forWritingTo: tempURL)
    }
    
    public func createMultipartFile() -> URL? {
        if #available(macOS 10.15.4, iOS 13.4, watchOS 6.2, tvOS 13.4, *) {
            return try? createMultipartFileURL()
        } else {
            return nil
        }
    }
    
    @available(macOS 10.15.4, iOS 13.4, watchOS 6.2, tvOS 13.4, *)
    func createMultipartFileURL() throws -> URL {
        defer { try? out.close() }

        // 1. Extra fields
        for (k, v) in extraFields {
            try write("--\(boundary)\r\n")
            try write("Content-Disposition: form-data; name=\"\(k)\"\r\n\r\n")
            try write("\(v)\r\n")
        }

        // 2. File part header
        let actualFileName = filePath.lastPathComponent
        try write("--\(boundary)\r\n")
        try write("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(actualFileName)\"\r\n")
        try write("Content-Type: \(mimeType)\r\n")
        try write("\r\n") // blank line ends headers

        // 3. File bytes
        let inFile = try FileHandle(forReadingFrom: filePath)
        defer { try? inFile.close() }

        while let chunk = try inFile.read(upToCount: 64 * 1024), !chunk.isEmpty {
            try out.write(contentsOf: chunk)
        }

        // 4. CRLF after file content then closing boundary
        try write("\r\n")
        try write("--\(boundary)--\r\n")

        return tempURL
    }
    
    @available(macOS 10.15.4, iOS 13.4, watchOS 6.2, tvOS 13.4, *)
    private func write(_ s: String) throws {
        try out.write(contentsOf: Data(s.utf8))
    }
}
