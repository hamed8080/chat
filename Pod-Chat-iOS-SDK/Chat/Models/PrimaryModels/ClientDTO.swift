//
//  ClientDTO.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 9/4/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class ClientDTO {
    
    public var clientId:        String?
    public var topicReceive:    String?
    public var topicSend:       String?
    public var brokerAddress:   String?
    public var desc:            String?
    public var sendKey:         String?
    
    public init(messageContent: JSON) {
        self.clientId       = messageContent["clientId"].string
        self.topicReceive   = messageContent["topicReceive"].string
        self.topicSend      = messageContent["topicSend"].string
        self.brokerAddress  = messageContent["brokerAddress"].string
        self.desc           = messageContent["desc"].string
        self.sendKey        = messageContent["sendKey"].string
    }
    
    public init(clientId:       String,
                topicReceive:   String,
                topicSend:      String,
                brokerAddress:  String,
                desc:           String,
                sendKey:        String) {
        self.clientId       = clientId
        self.topicReceive   = topicReceive
        self.topicSend      = topicSend
        self.brokerAddress  = brokerAddress
        self.desc           = desc
        self.sendKey        = sendKey
    }
    
    public init(theClientDTO: ClientDTO) {
        self.clientId       = theClientDTO.clientId
        self.topicReceive   = theClientDTO.topicReceive
        self.topicSend      = theClientDTO.topicSend
        self.brokerAddress  = theClientDTO.brokerAddress
        self.desc           = theClientDTO.desc
        self.sendKey        = theClientDTO.sendKey
    }
    
    public func formatToJSON() -> JSON {
        let result: JSON = ["clientId":         clientId ?? NSNull(),
                            "topicReceive":     topicReceive ?? NSNull(),
                            "topicSend":        topicSend ?? NSNull(),
                            "brokerAddress":    brokerAddress ?? NSNull(),
                            "desc":             desc ?? NSNull(),
                            "sendKey":          sendKey ?? NSNull()]
        return result
    }
    
}
