//
//  QueueOfFileMessages.swift
//  Chat
//
//  Created by hamed on 1/5/23.
//
//

import CoreData
import Foundation

open class QueueOfFileMessages: Codable, Hashable, Identifiable {
    public static func == (lhs: QueueOfFileMessages, rhs: QueueOfFileMessages) -> Bool {
        lhs.uniqueId == rhs.uniqueId
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(uniqueId)
    }

    public var fileExtension: String?
    public var fileName: String?
    public var isPublic: Bool?
    public var messageType: MessageType?
    public var metadata: String?
    public var mimeType: String?
    public var originalName: String?
    public var repliedTo: Int?
    public var textMessage: String?
    public var threadId: Int?
    public var typeCode: String?
    public var uniqueId: String?
    public var userGroupHash: String?
    public var hC: Int?
    public var wC: Int?
    public var xC: Int?
    public var yC: Int?
    public var fileToSend: Data?
    public var imageToSend: Data?

    private enum CodingKeys: String, CodingKey {
        case fileExtension
        case fileName
        case fileToSend
        case hC
        case imageToSend
        case isPublic
        case messageType
        case metadata
        case mimeType
        case originalName
        case repliedTo
        case textMessage
        case threadId
        case typeCode
        case uniqueId
        case userGroupHash
        case wC
        case xC
        case yC
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fileExtension = try container.decodeIfPresent(String.self, forKey: .fileExtension)
        fileName = try container.decodeIfPresent(String.self, forKey: .fileName)
        fileToSend = try container.decodeIfPresent(Data.self, forKey: .fileToSend)
        imageToSend = try container.decodeIfPresent(Data.self, forKey: .imageToSend)
        isPublic = try container.decodeIfPresent(Bool.self, forKey: .isPublic)
        messageType = try container.decodeIfPresent(MessageType.self, forKey: .messageType)
        metadata = try container.decodeIfPresent(String.self, forKey: .metadata)
        mimeType = try container.decodeIfPresent(String.self, forKey: .mimeType)
        originalName = try container.decodeIfPresent(String.self, forKey: .originalName)
        repliedTo = try container.decodeIfPresent(Int.self, forKey: .repliedTo)
        textMessage = try container.decodeIfPresent(String.self, forKey: .textMessage)
        threadId = try container.decodeIfPresent(Int.self, forKey: .threadId)
        typeCode = try container.decodeIfPresent(String.self, forKey: .typeCode)
        uniqueId = try container.decodeIfPresent(String.self, forKey: .uniqueId)
        userGroupHash = try container.decodeIfPresent(String.self, forKey: .userGroupHash)
        hC = try container.decodeIfPresent(Int.self, forKey: .hC)
        wC = try container.decodeIfPresent(Int.self, forKey: .wC)
        xC = try container.decodeIfPresent(Int.self, forKey: .xC)
        yC = try container.decodeIfPresent(Int.self, forKey: .yC)
    }

    public init(
        fileExtension: String? = nil,
        fileName: String? = nil,
        isPublic: Bool? = nil,
        messageType: MessageType? = nil,
        metadata: String? = nil,
        mimeType: String? = nil,
        originalName: String? = nil,
        repliedTo: Int? = nil,
        textMessage: String? = nil,
        threadId: Int? = nil,
        typeCode: String? = nil,
        uniqueId: String? = nil,
        userGroupHash: String? = nil,
        hC: Int? = nil,
        wC: Int? = nil,
        xC: Int? = nil,
        yC: Int? = nil,
        fileToSend: Data? = nil,
        imageToSend: Data? = nil
    ) {
        self.fileExtension = fileExtension
        self.fileName = fileName
        self.isPublic = isPublic
        self.messageType = messageType
        self.metadata = metadata
        self.mimeType = mimeType
        self.originalName = originalName
        self.repliedTo = repliedTo
        self.textMessage = textMessage
        self.threadId = threadId
        self.typeCode = typeCode
        self.uniqueId = uniqueId
        self.userGroupHash = userGroupHash
        self.hC = hC
        self.wC = wC
        self.xC = xC
        self.yC = yC
        self.fileToSend = fileToSend
        self.imageToSend = imageToSend
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(fileExtension, forKey: .fileExtension)
        try container.encodeIfPresent(fileName, forKey: .fileName)
        try container.encodeIfPresent(isPublic, forKey: .isPublic)
        try container.encodeIfPresent(messageType, forKey: .messageType)
        try container.encodeIfPresent(metadata, forKey: .metadata)
        try container.encodeIfPresent(mimeType, forKey: .mimeType)
        try container.encodeIfPresent(originalName, forKey: .originalName)
        try container.encodeIfPresent(repliedTo, forKey: .repliedTo)
        try container.encodeIfPresent(textMessage, forKey: .textMessage)
        try container.encodeIfPresent(threadId, forKey: .threadId)
        try container.encodeIfPresent(typeCode, forKey: .typeCode)
        try container.encodeIfPresent(uniqueId, forKey: .uniqueId)
        try container.encodeIfPresent(userGroupHash, forKey: .userGroupHash)
        try container.encodeIfPresent(hC, forKey: .hC)
        try container.encodeIfPresent(wC, forKey: .wC)
        try container.encodeIfPresent(xC, forKey: .xC)
        try container.encodeIfPresent(yC, forKey: .yC)
    }

    init(req: SendTextMessageRequest?, uploadFile: UploadFileRequest) {
        if let req = req {
            messageType = req.messageType
            metadata = req.metadata
            repliedTo = req.repliedTo
            textMessage = req.textMessage
            threadId = req.threadId
            typeCode = req.typeCode
            uniqueId = req.uniqueId
        }
        mimeType = uploadFile.mimeType
        originalName = uploadFile.originalName
        userGroupHash = uploadFile.userGroupHash
        fileToSend = uploadFile.data
    }

    init(req: SendTextMessageRequest?, imageRequest: UploadImageRequest) {
        if let req = req {
            messageType = req.messageType
            metadata = req.metadata
            repliedTo = req.repliedTo
            textMessage = req.textMessage
            threadId = req.threadId
            typeCode = req.typeCode
            uniqueId = req.uniqueId
        }
        mimeType = imageRequest.mimeType
        originalName = imageRequest.originalName
        userGroupHash = imageRequest.userGroupHash
        hC = imageRequest.hC
        wC = imageRequest.wC
        xC = imageRequest.xC
        yC = imageRequest.yC
        imageToSend = imageRequest.data
    }

    var request: (UploadFileRequest, SendTextMessageRequest) {
        let text = SendTextMessageRequest(threadId: threadId ?? -1,
                                          textMessage: textMessage ?? "",
                                          messageType: messageType ?? .unknown,
                                          metadata: metadata,
                                          repliedTo: repliedTo,
                                          systemMetadata: nil,
                                          uniqueId: uniqueId)
        let file = UploadFileRequest(data: fileToSend ?? Data(),
                                     fileExtension: fileExtension,
                                     fileName: fileName,
                                     description: "",
                                     isPublic: isPublic,
                                     mimeType: mimeType,
                                     originalName: originalName,
                                     userGroupHash: userGroupHash,
                                     uniqueId: uniqueId)
        return (file, text)
    }
}
