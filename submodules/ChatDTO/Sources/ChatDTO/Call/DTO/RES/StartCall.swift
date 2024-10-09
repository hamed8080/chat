//
// StartCall.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

public struct StartCall: Codable {
    public let certificateFile: String?
    public let clientDTO: ClientDTO
    public let otherClientDtoList: [ClientDTO]?
    public let chatDataDto: ChatDataDTO
    public let callName: String?
    public let callImage: String?
    public var callId: Int?

    public init(certificateFile: String? = nil, clientDTO: ClientDTO, otherClientDtoList: [ClientDTO]? = nil, chatDataDto: ChatDataDTO, callName: String?, callImage: String?, callId: Int? = nil) {
        self.certificateFile = certificateFile
        self.clientDTO = clientDTO
        self.otherClientDtoList = otherClientDtoList
        self.chatDataDto = chatDataDto
        self.callName = callName
        self.callImage = callImage
        self.callId = callId
    }

    private enum CodingKeys: String, CodingKey {
        case certificateFile = "cert_file"
        case clientDTO
        case otherClientDtoList
        case callName
        case callImage
        case chatDataDto
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.certificateFile, forKey: .certificateFile)
        try container.encode(self.clientDTO, forKey: .clientDTO)
        try container.encodeIfPresent(self.otherClientDtoList, forKey: .otherClientDtoList)
        try container.encodeIfPresent(self.callName, forKey: .callName)
        try container.encodeIfPresent(self.callImage, forKey: .callImage)
        try container.encode(self.chatDataDto, forKey: .chatDataDto)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.certificateFile = try container.decodeIfPresent(String.self, forKey: .certificateFile)
        self.clientDTO = try container.decode(ClientDTO.self, forKey: .clientDTO)
        self.otherClientDtoList = try container.decodeIfPresent([ClientDTO].self, forKey: .otherClientDtoList)
        self.callName = try container.decodeIfPresent(String.self, forKey: .callName)
        self.callImage = try container.decodeIfPresent(String.self, forKey: .callImage)
        self.chatDataDto = try container.decode(ChatDataDTO.self, forKey: .chatDataDto)
    }
}
