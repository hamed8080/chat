//
//  GetThreadParticipantsRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import FanapPodAsyncSDK
import SwiftyJSON

open class GetThreadParticipantsRequest: RequestModelDelegates {
    
    public let admin:           Bool?   // if we want to only get admins, we'll send this parameter as "true"
    public let count:           Int?    // Count of objects to get
    public let name:            String? // Search in Participants list (LIKE in name, contactName, email)
    public let offset:          Int?    // Offset of select Query
    public let threadId:        Int     // Id of thread which you want to get participants of
    
    public let typeCode:        String?
    public let uniqueId:        String
    
    public init(admin:          Bool?,
                count:          Int?,
                name:           String?,
                offset:         Int?,
                threadId:       Int,
                typeCode:       String?,
                uniqueId:       String?) {
        
        self.admin          = admin
        self.count          = count
        self.name           = name
        self.offset         = offset
        self.threadId       = threadId
        self.typeCode       = typeCode
        self.uniqueId       = uniqueId ?? UUID().uuidString
    }
    
    public init(json: JSON) {
        self.admin          = json["admin"].bool
        self.count          = json["count"].int
        self.name           = json["name"].string
        self.offset         = json["offset"].int
        self.threadId       = json["threadId"].intValue
        
        self.typeCode       = json["typeCode"].string
        self.uniqueId       = json["uniqueId"].string ?? UUID().uuidString
    }
    
    // this initializer will be deprecated soon
    public init(admin:          Bool?,
                count:          Int?,
                firstMessageId: Int?,
                lastMessageId:  Int?,
                name:           String?,
                offset:         Int?,
                threadId:       Int,
                typeCode:       String?,
                uniqueId:       String?) {
        
        self.admin          = admin
        self.count          = count
        self.name           = name
        self.offset         = offset
        self.threadId       = threadId
        self.typeCode       = typeCode
        self.uniqueId       = uniqueId ?? UUID().uuidString
    }
    
    
    public func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        content["count"]    = JSON(self.count ?? 50)
        content["offset"]   = JSON(self.offset ?? 0)
        
        if let name = self.name {
            let theName = MakeCustomTextToSend(message: name).replaceSpaceEnterWithSpecificCharecters()
            content["name"]   = JSON(theName)
        }
        
        if let admin = self.admin {
            content["admin"]   = JSON(admin)
        }
        
        return content
    }
    
    public func convertContentToJSONArray() -> [JSON] {
        return []
    }
    
}


/// MARK: -  this class will be deprecate (use this class instead: 'GetThreadParticipantsRequest')
open class GetThreadParticipantsRequestModel: GetThreadParticipantsRequest {
    
}

