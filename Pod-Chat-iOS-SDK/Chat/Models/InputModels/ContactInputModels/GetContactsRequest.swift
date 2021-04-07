//
//  GetContactsRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import FanapPodAsyncSDK
import SwiftyJSON

@available(*,deprecated , message:"Removed in XX.XX.XX version.")
open class GetContactsRequest {
    
    public let count:       Int?
    public let offset:      Int?
    
    public let contactId:       Int?
    public let cellphoneNumber: String?
    public let email:           String?
    public let order:           String?
    public let query:           String?
    public let summery:         Bool?
    
    public let typeCode:    String?
    public let uniqueId:    String
    
    public init(count:      Int?,
                offset:     Int?,
                query:      String?,
                typeCode:   String?,
                uniqueId:   String?) {
        
        self.count      = count
        self.offset     = offset
        
        self.contactId          = nil
        self.cellphoneNumber    = nil
        self.email              = nil
        self.order              = nil
        self.query              = query
        self.summery            = nil
        
        self.typeCode   = typeCode
        self.uniqueId   = uniqueId ?? UUID().uuidString
    }
    
    init(contactId:         Int?,
         count:             Int?,
         cellphoneNumber:   String?,
         email:             String?,
         offset:            Int?,
         order:             Ordering?,
         query:             String?,
         summery:           Bool?,
         typeCode:          String?,
         uniqueId:          String?) {
        
        self.count      = count
        self.offset     = offset
        
        self.contactId          = contactId
        self.cellphoneNumber    = cellphoneNumber
        self.email              = email
        self.order              = order?.rawValue ?? nil
        self.query              = query
        self.summery            = summery
        
        self.typeCode   = typeCode
        self.uniqueId   = uniqueId ?? UUID().uuidString
    }
    
//    public init(json: JSON) {
//        self.count      = json["count"].int
//        self.offset     = json["offset"].int
//        self.query      = json["query"].string
//
//        self.typeCode   = json["typeCode"].string
//        self.uniqueId   = json["uniqueId"].string ?? UUID().uuidString
//    }
    
    public func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        
        content["size"]     = JSON(self.count ?? 50)
        content["offset"]   = JSON(self.offset ?? 0)
        if let query = self.query {
            let theQuery = MakeCustomTextToSend(message: query).replaceSpaceEnterWithSpecificCharecters()
            content["query"] = JSON(theQuery)
        }
        if let contactId_ = self.contactId {
            content["id"] = JSON(contactId_)
        }
        if let cellphoneNumber_ = self.cellphoneNumber {
            content["cellphoneNumber"] = JSON(cellphoneNumber_)
        }
        if let email_ = self.email {
            content["email"] = JSON(email_)
        }
        if let order_ = self.order {
            content["order"] = JSON(order_)
        }
        if let summery_ = self.summery {
            content["summery"] = JSON(summery_)
        }
        
        return content
    }
    
    public func convertContentToJSONArray() -> [JSON] {
        return []
    }
    
}

/// MARK: -  this class will be deprecate (use this class instead: 'GetContactsRequest')
@available(*,deprecated , message:"Removed in XX.XX.XX version.")
open class GetContactsRequestModel: GetContactsRequest {
    
}

