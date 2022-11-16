//
// UpdateContactRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

public class UpdateContactRequest: UniqueIdManagerRequest, RestAPIProtocol, BodyRequestProtocol {
    static var config = Chat.sharedInstance.config!
    var url: String = "\(config.platformHost)\(Routes.updateContacts.rawValue)"
    var urlString: String { url }
    var headers: [String: String] = ["_token_": config.token, "_token_issuer_": "1"]
    var bodyData: Data? { getParameterData() }
    var method: HTTPMethod = .post

    public let cellphoneNumber: String
    public let email: String
    public let firstName: String
    public let id: Int
    public let lastName: String
    public let username: String

    public init(cellphoneNumber: String,
                email: String,
                firstName: String,
                id: Int,
                lastName: String,
                username: String,
                uniqueId: String? = nil)
    {
        self.cellphoneNumber = cellphoneNumber
        self.email = email
        self.firstName = firstName
        self.id = id
        self.lastName = lastName
        self.username = username
        super.init(uniqueId: uniqueId)
    }

    private enum CodingKeys: String, CodingKey {
        case cellphoneNumber
        case email
        case firstName
        case id
        case lastName
        case username
        case typeCode
        case uniqueId
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(cellphoneNumber, forKey: .cellphoneNumber)
        try container.encode(email, forKey: .email)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(id, forKey: .id)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(username, forKey: .username)
        try container.encode(Chat.sharedInstance.config?.typeCode, forKey: .typeCode)
        try container.encode(uniqueId, forKey: .uniqueId)
    }
}
