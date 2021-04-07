//
//  AddParticipantsRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

@available(*,deprecated , message:"Removed in XX.XX.XX version.")
open class AddParticipantsRequest: RequestModelDelegates {
    
    public let contactIds:  [Int]?
    public let usernames:   [String]?
    public let coreUserIds: [Int]?
    public let threadId:    Int
    
    public let typeCode:    String?
    public let uniqueId:    String
    
    public init(contactIds: [Int],
                threadId:   Int,
                typeCode:   String?,
                uniqueId:   String?) {
        
        self.contactIds     = contactIds
        self.coreUserIds    = nil
        self.usernames      = nil
        self.threadId       = threadId
        
        self.typeCode   = typeCode
        self.uniqueId   = uniqueId ?? UUID().uuidString
    }
    
    public init(usernames:  [String],
                threadId:   Int,
                typeCode:   String?,
                uniqueId:   String?) {
        
        self.contactIds     = nil
        self.coreUserIds    = nil
        self.usernames      = usernames
        self.threadId       = threadId
        
        self.typeCode   = typeCode
        self.uniqueId   = uniqueId ?? UUID().uuidString
    }
    
    public init(coreUserIds:    [Int],
                threadId:       Int,
                typeCode:       String?,
                uniqueId:       String?) {
        
        self.contactIds     = nil
        self.coreUserIds    = coreUserIds
        self.usernames      = nil
        self.threadId       = threadId
        
        self.typeCode   = typeCode
        self.uniqueId   = uniqueId ?? UUID().uuidString
    }
    
    public func convertContentToJSONArray() -> [JSON] {
        var content: [JSON] = []
        
        if let contacts = contactIds {
            for item in contacts {
                content.append(JSON(item))
            }
        } else if let theUserNames = usernames {
            for username in theUserNames {
                var inviteeObjc: JSON = [:]
                inviteeObjc["id"] = JSON(username)
                inviteeObjc["idType"] = JSON(InviteeVoIdTypes.TO_BE_USER_USERNAME.intValue())
                content.append(inviteeObjc)
            }
        } else if let theCoreUserIds = coreUserIds {
            for coreUserId in theCoreUserIds {
                var inviteeObjc: JSON = [:]
                inviteeObjc["id"] = JSON(coreUserId)
                inviteeObjc["idType"] = JSON(InviteeVoIdTypes.TO_BE_USER_ID.intValue())
                content.append(inviteeObjc)
            }
        }
        
        return content
    }
    
    public func convertContentToJSON() -> JSON {
        return [:]
    }
    
}

/// MARK: -  this class will be deprecate. (use this class instead: 'AddParticipantsRequest')
@available(*,deprecated , message:"Removed in XX.XX.XX version.")
open class AddParticipantsRequestModel: AddParticipantsRequest {
    
}

