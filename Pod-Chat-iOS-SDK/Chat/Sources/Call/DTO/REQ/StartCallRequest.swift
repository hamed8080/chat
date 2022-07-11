//
//  StartCallRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
public class StartCallRequest:BaseRequest{
    
    let threadId                : Int?
    let invitees                : [Invitee]?
    let type                    : CallType
    let client                  : SendClient
    let createCallThreadRequest : CreateCallThreadRequest?
    
    public init(client:SendClient,threadId: Int, type: CallType, uniqueId:String? = nil) {
        self.threadId                = threadId
        self.invitees                = nil
        self.type                    = type
        self.client                  = client
        self.createCallThreadRequest = nil
        super.init(uniqueId: uniqueId)
    }
    
    public init(client:SendClient, invitees: [Invitee], type: CallType, createCallThreadRequest:CreateCallThreadRequest? = nil, uniqueId:String? = nil) {
        self.threadId                = nil
        self.invitees                = invitees
        self.type                    = type
        self.client                  = client
        self.createCallThreadRequest = createCallThreadRequest
        super.init(uniqueId: uniqueId)
    }
    
    private enum CodingKeys:String ,CodingKey{
        case threadId                = "threadId"
        case invitees                = "invitees"
        case type                    = "type"
        case client                  = "creatorClientDto"
        case createCallThreadRequest = "createCallThreadRequest"
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(client, forKey: .client)
        try container.encodeIfPresent(threadId, forKey: .threadId)
        try container.encodeIfPresent(invitees, forKey: .invitees)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(createCallThreadRequest, forKey: .createCallThreadRequest)
    }
}
