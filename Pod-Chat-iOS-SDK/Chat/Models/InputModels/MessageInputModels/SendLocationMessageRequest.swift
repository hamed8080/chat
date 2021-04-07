//
//  SendLocationMessageRequest.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 12/12/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

@available(*,deprecated , message:"Removed in 0.10.5.0 version.")
open class SendLocationMessageRequest {
    
    public let mapCenter:       (lat: Double, lng: Double)
    public let mapHeight:       Int
    public let mapType:         String
    public let mapWidth:        Int
    public let mapZoom:         Int
    public let mapImageName:    String?
    
    public let repliedTo:       Int?
    public let systemMetadata:  String?
    public let textMessage:     String?
    public let threadId:        Int
    public let userGroupHash:   String
    
    public let messageType:     MessageType
    
    public let typeCode:         String?
    public let uniqueId:         String
    
    public init(mapCenter:      (Double, Double),
                mapHeight:      Int?,
                mapType:        String?,
                mapWidth:       Int?,
                mapZoom:        Int?,
                mapImageName:   String?,
                repliedTo:      Int?,
                systemMetadata: String?,
                textMessage:    String?,
                threadId:       Int,
                userGroupHash:  String,
                typeCode:       String?,
                uniqueId:       String?) {
        
        self.mapCenter      = mapCenter
        self.mapHeight      = mapHeight ?? 500
        self.mapType        = mapType ?? "standard-night"
        self.mapWidth       = mapWidth ?? 800
        self.mapZoom        = mapZoom ?? 15
        
        self.mapImageName   = mapImageName
        self.repliedTo      = repliedTo
        self.systemMetadata = systemMetadata
        self.textMessage    = textMessage
        self.threadId       = threadId
        self.userGroupHash  = userGroupHash
        
        self.messageType    = MessageType.PICTURE
        
        self.typeCode               = typeCode
        self.uniqueId               = uniqueId ?? UUID().uuidString
    }
    
    // this initializer will be deprecated soon
    public init(mapStaticCenterLat:     Double,
                mapStaticCenterLng:     Double,
                mapStaticHeight:        Int?,
                mapStaticType:          String?,
                mapStaticWidth:         Int?,
                mapStaticZoom:          Int?,
                sendMessageImageName:   String?,
                sendMessageXC:          Int?,
                sendMessageYC:          Int?,
                sendMessageHC:          Int?,
                sendMessageWC:          Int?,
                sendMessageThreadId:    Int,
                sendMessageContent:     String?,
                sendMessageMetadata:    String?,
                sendMessageRepliedTo:   Int?,
                sendMessageTypeCode:    String?,
                userGroupHash:          String,
                typeCode:               String?,
                uniqueId:               String?) {
        
        self.mapCenter  = (mapStaticCenterLat, mapStaticCenterLng)
        self.mapHeight  = mapStaticHeight ?? 500
        self.mapType    = mapStaticType ?? "standard-night"
        self.mapWidth   = mapStaticWidth ?? 800
        self.mapZoom    = mapStaticZoom ?? 15
        
        self.mapImageName   = sendMessageImageName
        self.threadId       = sendMessageThreadId
        self.userGroupHash  = userGroupHash
        
        self.textMessage    = sendMessageContent
        self.systemMetadata = sendMessageMetadata
        self.repliedTo      = sendMessageRepliedTo
        
        self.messageType    = MessageType.PICTURE
        
        self.typeCode               = typeCode
        self.uniqueId               = uniqueId ?? UUID().uuidString
    }
    
}


@available(*,deprecated , message:"Removed in 0.10.5.0 version.")
open class SendLocationMessageRequestModel: SendLocationMessageRequest {
    
}
