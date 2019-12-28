//
//  SendChatMessageVO.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/4/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


class SendChatMessageVO {
    
    let chatMessageVOType:  Int
    var content:            String? = nil
    var metadata:           String? = nil
    var repliedTo:          Int?    = nil
    var systemMetadata:     String? = nil
    var subjectId:          Int?    = nil
    let token:              String
    var tokenIssuer:        Int?    = nil
    var typeCode:           String? = nil
    var uniqueId:           String? = nil
    var uniqueIds:          [String]? = nil
    
    var isCreateThreadAndSendMessage: Bool
    
    init(chatMessageVOType: Int,
         content:           String?,
         metadata:          String?,
         repliedTo:         Int?,
         systemMetadata:    String?,
         subjectId:         Int?,
         token:             String,
         tokenIssuer:       Int?,
         typeCode:          String?,
         uniqueId:          String?,
         uniqueIds:         [String]?,
         isCreateThreadAndSendMessage: Bool?) {
        
        self.content            = content
        self.metadata           = metadata
        self.repliedTo          = repliedTo
        self.systemMetadata     = systemMetadata
        self.subjectId          = subjectId
        self.token              = token
        self.tokenIssuer        = tokenIssuer
        self.chatMessageVOType  = chatMessageVOType
        self.typeCode           = typeCode
        self.uniqueId           = uniqueId
        self.uniqueIds          = uniqueIds
        
        self.isCreateThreadAndSendMessage   = isCreateThreadAndSendMessage ?? false
        
        func generateUUID() -> String {
            return ""
        }
        
        self.uniqueId = ""
        if let uID = uniqueId {
            self.uniqueId = uID
        } else if (chatMessageVOType == chatMessageVOTypes.DELETE_MESSAGE.rawValue) {
            if let contentJSON = content?.convertToJSON() {
                if let x = contentJSON["ids"].arrayObject {
                    if (x.count <= 1) {
                        self.uniqueId = generateUUID()
                    }
                } else {
                    self.uniqueId = generateUUID()
                }
            }
        } else if (chatMessageVOType == chatMessageVOTypes.PING.rawValue) {
            self.uniqueId = generateUUID()
        }
        
    }
    
    init(content: JSON) {
        
        self.token              = content["token"].stringValue
        self.tokenIssuer        = content["tokenIssuer"].int ?? 1
        self.chatMessageVOType  = content["chatMessageVOType"].intValue
        
        if let myContent = content["content"].string {
            self.content = myContent
        }
        if let myMetadata = content["metadata"].string {
            self.metadata = myMetadata
        }
        if let myRepliedTo = content["repliedTo"].int {
            self.repliedTo = myRepliedTo
        }
        if let mySystemMetadata = content["systemMetadata"].string {
            self.systemMetadata = mySystemMetadata
        }
        if let mySubjectId = content["subjectId"].int {
            self.subjectId = mySubjectId
        }
        
        if let myTypeCode = content["typeCode"].string {
            self.typeCode = myTypeCode
        }
        
        self.isCreateThreadAndSendMessage   = content["isCreateThreadAndSendMessage"].bool ?? false
        
        func generateUUID() -> String {
            return ""
        }
        
        self.uniqueId = ""
        if let uIds = content["uniqueId"].string?.convertToJSON().arrayObject as? [String], (uIds.count > 0) {
            self.uniqueIds = uIds
        } else if let uID = content["uniqueId"].string {
            self.uniqueId = uID
        } else if (content["chatMessageVOType"].intValue == chatMessageVOTypes.DELETE_MESSAGE.rawValue) {
            if let x = content["content"]["ids"].arrayObject {
                if x.count <= 1 {
                    self.uniqueId = generateUUID()
                }
            } else {
                self.uniqueId = generateUUID()
            }
        } else if (content["chatMessageVOType"].intValue != chatMessageVOTypes.PING.rawValue) {
            self.uniqueId = generateUUID()
        }
        
    }
    
    
    func convertModelToJSON() -> JSON {
        var messageVO: JSON = ["token":         token,
                               "tokenIssuer":   tokenIssuer ?? 1,
                               "type":          chatMessageVOType]
        if let theMessage = content {
            messageVO["content"] = JSON(theMessage)
        }
        if let theMetadata = metadata {
            messageVO["metadata"] = JSON(theMetadata)
        }
        if let theRepliedTo = repliedTo {
            messageVO["repliedTo"] = JSON(theRepliedTo)
        }
        if let theSubjectId = subjectId {
            messageVO["subjectId"] = JSON(theSubjectId)
        }
        if let theSystemMetadata = systemMetadata {
            messageVO["systemMetadata"] = JSON(theSystemMetadata)
        }
        if let theTypeCode = typeCode {
            messageVO["typeCode"] = JSON(theTypeCode)
        }
        
        if let theUniqueIds = uniqueIds {
            messageVO["uniqueId"] = JSON("\(theUniqueIds)")
        } else if let theUniqueId = uniqueId {
            messageVO["uniqueId"] = JSON(theUniqueId)
        }
        
        return messageVO
    }
    
    func convertModelToString() -> String {
        return "\(convertModelToJSON())"
    }
    
}


