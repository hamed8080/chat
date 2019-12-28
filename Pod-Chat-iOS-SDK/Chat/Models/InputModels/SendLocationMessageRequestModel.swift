//
//  SendLocationMessageRequestModel.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 12/12/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//


import Foundation

import SwiftyJSON


open class SendLocationMessageRequestModel {
    
    public let mapStaticCenterLat:   Double
    public let mapStaticCenterLng:   Double
    public let mapStaticHeight:      Int
    public let mapStaticType:        String
    public let mapStaticWidth:       Int
    public let mapStaticZoom:        Int
    
    public let sendMessageImageName:   String?
    public let sendMessageXC:          String?
    public let sendMessageYC:          String?
    public let sendMessageHC:          String?
    public let sendMessageWC:          String?
    public let sendMessageThreadId:    Int
    
    public let sendMessageContent:     String?
    public let sendMessageMetadata:    JSON?
    public let sendMessageRepliedTo:   Int?
    public let sendMessageTypeCode:    String?
    
    public let typeCode:         String?
    public let uniqueId:         String?
    
    public init(mapStaticCenterLat:     Double,
                mapStaticCenterLng:     Double,
                mapStaticHeight:        Int?,
                mapStaticType:          String?,
                mapStaticWidth:         Int?,
                mapStaticZoom:          Int?,
                sendMessageImageName:   String?,
                sendMessageXC:          String?,
                sendMessageYC:          String?,
                sendMessageHC:          String?,
                sendMessageWC:          String?,
                sendMessageThreadId:    Int,
                sendMessageContent:     String?,
                sendMessageMetadata:    JSON?,
                sendMessageRepliedTo:   Int?,
                sendMessageTypeCode:    String?,
                typeCode:               String?,
                uniqueId:               String?) {
        
        self.mapStaticCenterLat     = mapStaticCenterLat
        self.mapStaticCenterLng     = mapStaticCenterLng
        self.mapStaticHeight        = mapStaticHeight ?? 500
        self.mapStaticType          = mapStaticType ?? "standard-night"
        self.mapStaticWidth         = mapStaticWidth ?? 800
        self.mapStaticZoom          = mapStaticZoom ?? 15
        
        self.sendMessageImageName   = sendMessageImageName
        self.sendMessageXC          = sendMessageXC
        self.sendMessageYC          = sendMessageYC
        self.sendMessageHC          = sendMessageHC
        self.sendMessageWC          = sendMessageWC
        self.sendMessageThreadId    = sendMessageThreadId
        
        self.sendMessageContent     = sendMessageContent
        self.sendMessageMetadata    = sendMessageMetadata
        self.sendMessageRepliedTo   = sendMessageRepliedTo
        self.sendMessageTypeCode    = sendMessageTypeCode
        self.typeCode               = typeCode
        self.uniqueId               = uniqueId
    }
    
}
