//
// UploadFileRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

#if canImport(CoreServices)
import CoreServices
#endif
#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif
import Foundation

public struct UploadFileRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol, Sendable {
    public var data: Data
    public var fileExtension: String?
    public var fileName: String = ""
    public var fileSize: Int64 = 0
    /// if  send file iniside the thread we need to set is isPublic to false
    public private(set) var isPublic: Bool?
    public var mimeType: String = ""
    public var originalName: String = ""
    public var userGroupHash: String?
    public var description: String?
    public var typeCodeIndex: Index
    public let uniqueId: String
    public var dataToSend: Data? { data }

    public init(data: Data,
                fileExtension: String? = nil,
                fileName: String? = nil,
                description: String? = nil,
                isPublic: Bool? = nil,
                mimeType: String? = nil,
                originalName: String? = nil,
                userGroupHash: String? = nil,
                typeCodeIndex: TypeCodeIndexProtocol.Index = 0
    )
    {
        self.data = data
        self.fileExtension = fileExtension
        let fileName = fileName ?? "\(NSUUID().uuidString)"
        self.fileName = fileName
        fileSize = Int64(data.count)
        self.mimeType = mimeType ?? UploadFileRequest.guessMimeType(fileExtension, fileName)
        self.userGroupHash = userGroupHash
        self.originalName = originalName ?? fileName + (fileExtension ?? "")
        self.isPublic = userGroupHash != nil ? false : isPublic // if send file iniside the thread we need to set is isPublic to false
        self.uniqueId = UUID().uuidString
        self.description = description
        self.typeCodeIndex = typeCodeIndex
    }

    internal init(data: Data,
                fileExtension: String? = nil,
                fileName: String? = nil,
                description: String? = nil,
                isPublic: Bool? = nil,
                mimeType: String? = nil,
                originalName: String? = nil,
                userGroupHash: String? = nil,
                uniqueId: String,
                typeCodeIndex: TypeCodeIndexProtocol.Index = 0)
    {
        self.data = data
        self.fileExtension = fileExtension
        let fileName = fileName ?? "\(NSUUID().uuidString)"
        self.fileName = fileName
        fileSize = Int64(data.count)
        self.mimeType = mimeType ?? UploadFileRequest.guessMimeType(fileExtension, fileName)
        self.userGroupHash = userGroupHash
        self.originalName = originalName ?? fileName + (fileExtension ?? "")
        self.isPublic = userGroupHash != nil ? false : isPublic // if send file iniside the thread we need to set is isPublic to false
        self.uniqueId = uniqueId
        self.description = description
        self.typeCodeIndex = typeCodeIndex
    }

    static func guessMimeType(_ fileExtension: String?, _ fileName: String?) -> String {
        let ext = fileExtension ?? URL(fileURLWithPath: fileName ?? "").pathExtension
        #if canImport(UniformTypeIdentifiers)
        if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
            return UTType(filenameExtension: ext)?.preferredMIMEType ?? "application/octet-stream"
        }
        #endif
        #if canImport(CoreServices)
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext as NSString, nil)?.takeRetainedValue() {
            return UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() as? String ?? "application/octet-stream"
        }
        #endif
        return "application/octet-stream"
    }

    private enum CodingKeys: String, CodingKey {
        case isPublic
        case filename
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent("\(isPublic != nil && isPublic == true ? "true" : "false")", forKey: .isPublic) // dont send bool it crash when send and encode to dictionary
        try container.encodeIfPresent(fileName, forKey: .filename)
    }
}
