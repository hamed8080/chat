//
//  LocationMessageRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/31/21.
//

import Foundation
public class LocationMessageRequest : BaseRequest {
    
    public let mapCenter      : Cordinate
    public let mapHeight      : Int
    public let mapType        : String
    public let mapWidth       : Int
    public let mapZoom        : Int
    public let mapImageName   : String?
    
    public let repliedTo      : Int?
    public let systemMetadata : String?
    public let textMessage    : String?
    public let threadId       : Int
    public let userGroupHash  : String
    
    public let messageType:     MessageType
    
    public init(mapCenter      : Cordinate,
                threadId       : Int,
                userGroupHash  : String,
                mapHeight      : Int        = 500,
                mapType        : String     = "standard-night",
                mapWidth       : Int        = 800,
                mapZoom        : Int        = 15,
                mapImageName   : String?    = nil,
                repliedTo      : Int?       = nil,
                systemMetadata : String?    = nil,
                textMessage    : String?    = nil,
                typeCode       : String?    = nil,
                uniqueId       : String?    = nil) {
        
        self.mapCenter      = mapCenter
        self.mapHeight      = mapHeight
        self.mapType        = mapType
        self.mapWidth       = mapWidth
        self.mapZoom        = mapZoom
        
        self.mapImageName   = mapImageName
        self.repliedTo      = repliedTo
        self.systemMetadata = systemMetadata
        self.textMessage    = textMessage
        self.threadId       = threadId
        self.userGroupHash  = userGroupHash
        
        self.messageType    = MessageType.PICTURE
        super.init(uniqueId: uniqueId, typeCode: typeCode)
    }
}
